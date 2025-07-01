import os
from ultralytics import YOLO
import cv2
import asyncio
from datetime import datetime
from app.models.detection_result_model import DetectionResult
from app.models.class_model import ClassObject
from app.utils.fcm_push import send_push_notifications
from app.models.user_model import User, UserFCMToken
from app.models.baby_profile_model import BabyProfile
from app.utils.config import config
from app.utils.websocket_broadcast import broadcast_detection
from app.utils.esp32_stream_buffer import ESP32StreamBuffer
from database.database import SessionLocal

# Dictionary to track currently running detection tasks per camera
running_tasks = {}

# Dictionary to avoid sending repeated alerts for same class within short period
last_detection_time = {}  # key: profile_camera_class, value: datetime

# Dictionary to hold active frame buffers from ESP32 streams
stream_buffers = {}  # key: profile_id_camera_type, value: ESP32StreamBuffer

# Start the detection loop for a given baby profile and camera
async def start_detection_loop(profile_id: int, camera_type: str, ip: str, user_id: int, model_path: str, db, camera_profiles):
    model = YOLO(model_path)
    stream_url = f"http://{ip}/stream"
    should_stop = False
    buffer_key = f"{profile_id}_{camera_type}"

    # Reuse existing stream buffer or create a new one
    stream_buffer = stream_buffers.get(buffer_key)
    if stream_buffer is None:
        stream_buffer = ESP32StreamBuffer(stream_url)
        stream_buffer.start()
        stream_buffers[buffer_key] = stream_buffer

    # Main detection loop
    async def detect():
        nonlocal should_stop
        read_fail_count = 0
        open_fail_count = 0
        max_read_fail_count = 10
        max_open_fail_count = 3 
        try:
            while True:
                try:
                    frame = stream_buffer.get_latest_frame()

                    # Handle frame read failure
                    if frame is None:
                        read_fail_count += 1
                        print(f"[WARNING] Failed to read frame ({(read_fail_count * open_fail_count) + read_fail_count} time(s))")

                        if read_fail_count >= max_read_fail_count:
                            if open_fail_count < max_open_fail_count:
                                open_fail_count += 1
                                print("[RECONNECT] VideoCapture not opened, retrying...")
                                stream_buffer.restart()
                                read_fail_count = 0
                                continue
                            else:
                                print(f"[DISCONNECTED] Camera for Profile {profile_id} - {camera_type}")
                                await notify_disconnection_and_stop(profile_id, camera_type, user_id, camera_profiles, db)
                                break
                        await asyncio.sleep(0.5)
                        continue
                    else:
                        read_fail_count = 0
                        open_fail_count = 0

                    # Run YOLO detection on the frame
                    results = model(frame)[0]
                    now = datetime.utcnow()

                    for xyxy, conf, cls in zip(results.boxes.xyxy, results.boxes.conf, results.boxes.cls):
                        if conf > 0.5:
                            class_id = int(cls)
                            key = f"{profile_id}_{camera_type}_{class_id}"
                            last_time = last_detection_time.get(key)

                            # Avoid duplicate detections within 5 seconds
                            if not last_time or (now - last_time).total_seconds() > 5:
                                last_detection_time[key] = now

                                # Fetch class metadata from DB
                                class_obj = db.query(ClassObject).filter_by(
                                    baby_profile_id=profile_id,
                                    camera_type=camera_type,
                                    model_index=class_id
                                ).first()
                                class_name = class_obj.name if class_obj else "unknown"
                                risk_level = class_obj.risk_level if class_obj else "unknown"
                                conf_value = float(conf.item()) if hasattr(conf, 'item') else float(conf)

                                print(f"[DETECTED] Profile {profile_id}, Class {class_id}, Confidence {conf_value:.2f}")
                                
                                # Save detection image and update DB
                                base_path = "uploads/detections"
                                relative_path = save_detection_image(base_path, profile_id, camera_type, class_name, class_obj.id, xyxy, conf_value, frame)

                                detection = DetectionResult(
                                    baby_profile_id=profile_id,
                                    class_id=class_obj.id,
                                    class_name=class_name,
                                    confidence=conf_value,
                                    camera_type=camera_type,
                                    image_path=relative_path
                                )
                                db.add(detection)
                                db.commit()

                                # Send WebSocket alert to frontend
                                await broadcast_detection(
                                    user_id,
                                    {
                                        "type": "hazard_detected",
                                        "baby_profile_id": profile_id,
                                        "camera_type": camera_type,
                                        "class_id": class_id,
                                        "class_name": class_name,
                                        "risk_level": risk_level.value,
                                        "confidence": conf_value,
                                        "detection_id": detection.id,
                                        "timestamp": datetime.now().isoformat()
                                    }
                                )

                                # Send FCM push notification to mobile
                                if user_id:
                                    try:
                                        fresh_db = SessionLocal()
                                        try:
                                            tokens = [t.token for t in fresh_db.query(UserFCMToken).filter_by(user_id=user_id).all()]
                                            if tokens:
                                                await asyncio.to_thread(
                                                    send_push_notifications,
                                                    tokens,
                                                    {
                                                        "message": {
                                                            "notification": {
                                                                "title": "⚠️ Hazard Detected",
                                                                "body": f"Object detected: {class_name} ({camera_type}) - Risk Level: {risk_level.value}"
                                                            },
                                                            "android": {
                                                                "priority": "high",
                                                                "notification": {
                                                                    "channel_id": "high_importance_channel",
                                                                    "default_sound": True,
                                                                    "default_vibrate_timings": True,
                                                                    "default_light_settings": True
                                                                }
                                                            },
                                                            "apns": {
                                                                "payload": {
                                                                    "aps": {
                                                                        "sound": "notification_sound.aiff",
                                                                        "badge": 1,
                                                                        "alert": {
                                                                            "title": "⚠️ Hazard Detected",
                                                                            "body": f"Object detected: {class_name} ({camera_type}) - Risk Level: {risk_level.value}"
                                                                        }
                                                                    }
                                                                }
                                                            },
                                                            "data": {
                                                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                                                "type": "detection_alert"
                                                            }
                                                        }
                                                    },
                                                    config.FIREBASE_PROJECT_ID,
                                                    config.GOOGLE_CREDENTIALS_PATH
                                                )
                                        finally:
                                            fresh_db.close()
                                    except Exception as e:
                                        print(f"[WARNING] Failed to send push notifications: {e}")
                                        import traceback
                                        print(f"[DEBUG] Full traceback: {traceback.format_exc()}")

                    await asyncio.sleep(0.5)

                    if should_stop:
                        print(f"[STOPPING] Gracefully exiting detect loop for {profile_id}-{camera_type}")
                        break
                except asyncio.CancelledError:
                    should_stop = True
                    print(f"[CANCEL RECEIVED] Marked detect loop for graceful exit")

        except Exception as e:
            print(f"[ERROR] Detection loop failed: {e}")
        finally:
            print(f"[STOPPED] Detection for Profile {profile_id} - {camera_type}")

    # Track this detection loop as an active task
    task_id = f"{profile_id}_{camera_type}"
    running_tasks[task_id] = asyncio.create_task(detect())
    return task_id

# Stop a running detection task and clean up
async def stop_detection_loop(profile_id: int, camera_type: str):
    keys_to_remove = [key for key in last_detection_time if key.startswith(f"{profile_id}_{camera_type}_")]
    for key in keys_to_remove:
        del last_detection_time[key]

    task_id = f"{profile_id}_{camera_type}"
    task = running_tasks.pop(task_id, None)
    if task:
        task.cancel()
        print(f"[CANCELLED] Detection task for {task_id}")

    buffer_key = f"{profile_id}_{camera_type}"
    stream_buffer = stream_buffers.pop(buffer_key, None)
    if stream_buffer:
        stream_buffer.stop()

# Handle camera disconnection: notify, clean up, and stop monitoring
async def notify_disconnection_and_stop(profile_id: int, camera_type: str, user_id: int, camera_profiles, db):
    try:
        from app.services.monitoring_service import stop_monitoring_service

        baby_profile = db.query(BabyProfile).filter_by(id=profile_id).first()
        if baby_profile:
            await broadcast_detection(
                user_id,
                {
                    "type": "camera_disconnected",
                    "baby_profile_id": profile_id,
                    "camera_type": camera_type,
                    "timestamp": datetime.now().isoformat()
                }
            )

            if user_id:
                fresh_db = SessionLocal()
                try:
                    tokens = [t.token for t in fresh_db.query(UserFCMToken).filter_by(user_id=user_id).all()]
                    if tokens:
                        await asyncio.to_thread(
                            send_push_notifications,
                            tokens,
                            {
                                "message": {
                                    "notification": {
                                        "title": "📷 Camera Disconnected",
                                        "body": f"{camera_type.replace('_', ' ').title()} for '{baby_profile.name}' has been disconnected"
                                    },
                                    "android": {
                                        "priority": "high",
                                        "notification": {
                                            "channel_id": "high_importance_channel",
                                            "default_sound": True,
                                            "default_vibrate_timings": True,
                                            "default_light_settings": True
                                        }
                                    },
                                    "apns": {
                                        "payload": {
                                            "aps": {
                                                "sound": "notification_sound.aiff",
                                                "badge": 1,
                                                "alert": {
                                                    "title": "📷 Camera Disconnected",
                                                    "body": f"{camera_type.replace('_', ' ').title()} for '{baby_profile.name}' has been disconnected"
                                                }
                                            }
                                        }
                                    },
                                    "data": {
                                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                        "type": "Camera_Disconnection"
                                    }
                                }
                            },
                            config.FIREBASE_PROJECT_ID,
                            config.GOOGLE_CREDENTIALS_PATH
                        )
                finally:
                    fresh_db.close()

        await stop_detection_loop(profile_id, camera_type)

        # If no other cameras are active for this profile, stop monitoring service
        active_sessions = [key for key in running_tasks.keys() if key.startswith(f"{profile_id}_")]
        if not active_sessions:
            print(f"[INFO] All cameras for Profile {profile_id} disconnected. Stopping monitoring.")
            await stop_monitoring_service(camera_profiles, db)

    except Exception as e:
        print(f"[ERROR] Failed to handle disconnection and stop detection: {e}")

# Save an annotated image of the detection
def save_detection_image(base_path, baby_profile_id, camera_type, class_name, class_id, xyxy_tensor, confidence, frame):
    folder = os.path.join(base_path, str(baby_profile_id), camera_type)
    os.makedirs(folder, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    conf_str = f"{confidence:.2f}"
    filename = f"{timestamp}_class_id_{class_id}_{class_name}_conf_{conf_str}.jpg"
    file_path = os.path.join(folder, filename)

    xyxy = xyxy_tensor.cpu().numpy().astype(int)
    x1, y1, x2, y2 = xyxy

    # Draw bounding box and label on the image
    label_text = f"{class_name} ({conf_str})"
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 0.6
    thickness = 2
    text_size, _ = cv2.getTextSize(label_text, font, font_scale, thickness)

    cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
    cv2.rectangle(frame, (x1, y1), (x1 + text_size[0] + 10, y1 + text_size[1] + 10), (0, 255, 0), cv2.FILLED)
    cv2.putText(frame, label_text, (x1 + 5, y1 + text_size[1] + 5), font, font_scale, (0, 0, 0), thickness)

    cv2.imwrite(file_path, frame)

    relative_path = os.path.join("detections", str(baby_profile_id), camera_type, filename)
    return relative_path
