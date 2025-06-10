import os
from ultralytics import YOLO
import cv2
import asyncio
#import httpx
from datetime import datetime
#from app.services.monitoring_service import stop_monitoring_service
from app.models.detection_result_model import DetectionResult
from app.models.class_model import ClassObject
from app.utils.fcm_push import send_push_notifications
from app.models.user_model import User, UserFCMToken
from app.models.baby_profile_model import BabyProfile
from app.utils.config import config
from app.utils.websocket_broadcast import broadcast_detection

running_tasks = {}
last_detection_time = {}  # key: profile_camera_class, value: datetime

async def start_detection_loop(profile_id: int, camera_type: str, ip: str, current_user: User, model_path: str, db, camera_profiles, origin: str):
    model = YOLO(model_path)
    stream_url = f"http://{ip}:81/stream"
    should_stop = False

    async def detect():
        nonlocal should_stop
        read_fail_count = 0
        open_fail_count = 0
        max_read_fail_count = 10
        max_open_fail_count = 3 
        cap = cv2.VideoCapture(stream_url)
        baby_profile = db.query(BabyProfile).filter_by(id=profile_id).first()
        #user = db.query(User).filter_by(id=baby_profile.user_id).first()
        try:
            while cap.isOpened():
                try:
                    ret, frame = cap.read()
                    if not ret or frame is None:
                        read_fail_count += 1
                        print(f"[WARNING] Failed to read frame ({(read_fail_count * open_fail_count) + read_fail_count} time(s))")

                        if read_fail_count >= max_read_fail_count:
                            if open_fail_count < max_open_fail_count:
                                open_fail_count += 1
                                print("[RECONNECT] VideoCapture not opened, retrying...")
                                cap.release()
                                await asyncio.sleep(3)
                                cap = cv2.VideoCapture(stream_url)
                                read_fail_count = 0
                                continue
                            else:
                                print(f"[DISCONNECTED] Camera for Profile {profile_id} - {camera_type}")
                                await notify_disconnection_and_stop(profile_id, camera_type, current_user, origin, camera_profiles, db)
                                break

                        await asyncio.sleep(0.5)
                        continue
                    else:
                        read_fail_count = 0
                        open_fail_count = 0

                    results = model(frame)[0]
                    now = datetime.utcnow()

                    # baby_profile = db.query(BabyProfile).filter_by(id=profile_id).first()
                    # user = db.query(User).filter_by(id=baby_profile.user_id).first()

                    for result in results.boxes:
                        if result.conf > 0.1:
                            class_id = int(result.cls)
                            key = f"{profile_id}_{camera_type}_{class_id}"
                            last_time = last_detection_time.get(key)

                            if not last_time or (now - last_time).total_seconds() > 5:
                                last_detection_time[key] = now

                                class_obj = db.query(ClassObject).filter_by(
                                    baby_profile_id=profile_id,
                                    camera_type=camera_type,
                                    model_index=class_id
                                ).first()
                                class_name = class_obj.name if class_obj else "unknown"
                                risk_level = class_obj.risk_level if class_obj else "unknown"
                                conf = float(result.conf.item()) if hasattr(result.conf, 'item') else float(result.conf)
                                print(f"[DETECTED] Profile {profile_id}, Class {class_id}, Confidence {conf:.2f}")
                                # עכשיו שומרים את התמונה ומעדכנים את ה-db
                                base_path = "uploads/detections"
                                relative_path = save_detection_image(base_path, profile_id, camera_type, class_name, class_obj.id, result, frame)

                                detection = DetectionResult(
                                    baby_profile_id=profile_id,
                                    class_id=class_obj.id,
                                    class_name=class_name,
                                    confidence=float(result.conf),
                                    camera_type=camera_type,
                                    image_path=relative_path
                                )
                                db.add(detection)
                                db.commit()

                                # שליחה ל-WebSocket עם detection_id
                                await broadcast_detection(
                                    baby_profile.user_id,
                                    {
                                        "type": "hazard_detected",
                                        "baby_profile_id": profile_id,
                                        "camera_type": camera_type,
                                        "class_id": class_id,
                                        "class_name": class_name,
                                        "risk_level": risk_level,
                                        "confidence": float(result.conf),
                                        "detection_id": detection.id,
                                        "timestamp": datetime.utcnow().isoformat()
                                    }
                                )

                                # שליחת push notifications
                                if current_user:
                                    try:
                                        tokens = [t.token for t in db.query(UserFCMToken).filter_by(user_id=current_user.id).all()]
                                        if tokens:
                                            message = f"Object detected: {class_name} ({camera_type}) - Risk Level: {risk_level}"
                                            await asyncio.to_thread(
                                                send_push_notifications,
                                                tokens,
                                                "⚠️ Hazard Detected",
                                                message,
                                                config.FIREBASE_PROJECT_ID,
                                                config.GOOGLE_CREDENTIALS_PATH
                                            )
                                    except Exception as e:
                                        print(f"[WARNING] Failed to send push notifications: {e}")

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
            cap.release()
            print(f"[STOPPED] Detection for Profile {profile_id} - {camera_type}")

    task_id = f"{profile_id}_{camera_type}"
    running_tasks[task_id] = asyncio.create_task(detect())
    return task_id

async def stop_detection_loop(profile_id: int, camera_type: str):
    # ניקוי זיכרון זמני של זיהויים אחרונים למניעת חסימת זיהויים עתידיים
    keys_to_remove = [key for key in last_detection_time if key.startswith(f"{profile_id}_{camera_type}_")]
    for key in keys_to_remove:
        del last_detection_time[key]
    task_id = f"{profile_id}_{camera_type}"
    task = running_tasks.pop(task_id, None)
    if task:
        task.cancel()
        print(f"[CANCELLED] Detection task for {task_id}")

'''async def notify_frontend_camera_disconnected(profile_id: int, camera_type: str, origin: str, db):
    try:
        async with httpx.AsyncClient() as client:
            await client.post(f"{origin}/api/camera/disconnected", json={
                "baby_profile_id": profile_id,
                "camera_type": camera_type,
                "reason": "disconnected"
            })
    except Exception as e:
        print(f"[WARNING] Failed to notify frontend: {e}")

    # גם נשלח ל־WebSocket
    baby_profile = db.query(BabyProfile).filter_by(id=profile_id).first()
    if baby_profile:
        await broadcast_detection(
            baby_profile.user_id,
            {
                "type": "camera_disconnected",
                "baby_profile_id": profile_id,
                "camera_type": camera_type,
                "timestamp": datetime.utcnow().isoformat()
            }
        )'''

'''async def notify_frontend_detection(profile_id: int, camera_type: str, class_id: int, class_name: str, risk_level: str, confidence: float, origin: str):
    try:
        async with httpx.AsyncClient() as client:
            await client.post(f"{origin}/api/detection/notify", json={
                "baby_profile_id": profile_id,
                "camera_type": camera_type,
                "class_id": class_id,
                "class_name": class_name,
                "risk_level": risk_level,
                "confidence": confidence,
                "timestamp": datetime.utcnow().isoformat()
            })
    except Exception as e:
        print(f"[WARNING] Failed to notify frontend of detection: {e}")'''

'''async def notify_disconnection_and_stop(profile_id: int, camera_type: str, origin: str, camera_profiles, db):
    try:
        from app.services.monitoring_service import stop_monitoring_service  # 👈 ייבוא דינמי לשבירת הלולאה
        await notify_frontend_camera_disconnected(profile_id, camera_type, origin)
        await stop_monitoring_service(camera_profiles, db)
    except Exception as e:
        print(f"[ERROR] Failed to handle disconnection and stop monitoring: {e}")'''

async def notify_disconnection_and_stop(profile_id: int, camera_type: str, current_user: User, origin: str, camera_profiles, db):
    try:
        from app.services.monitoring_service import stop_monitoring_service

        # נשלח רק ל־WebSocket
        baby_profile = db.query(BabyProfile).filter_by(id=profile_id).first()
        if baby_profile:
            await broadcast_detection(
                baby_profile.user_id,
                {
                    "type": "camera_disconnected",
                    "baby_profile_id": profile_id,
                    "camera_type": camera_type,
                    "timestamp": datetime.utcnow().isoformat()
                }
            )

            # שליחת התראה ב־Push Notification
            #user = db.query(User).filter_by(id=baby_profile.user_id).first()
            if current_user:
                tokens = [t.token for t in db.query(UserFCMToken).filter_by(user_id=current_user.id).all()]
                if tokens:
                    title = "📷 Camera Disconnected"
                    body = f"{camera_type.replace('_', ' ').title()} for '{baby_profile.name}' has been disconnected"
                    await asyncio.to_thread(
                        send_push_notifications,
                        tokens,
                        title,
                        body,
                        config.FIREBASE_PROJECT_ID,
                        config.GOOGLE_CREDENTIALS_PATH
                    )

        await stop_detection_loop(profile_id, camera_type)

        active_sessions = [key for key in running_tasks.keys() if key.startswith(f"{profile_id}_")]
        if not active_sessions:
            print(f"[INFO] All cameras for Profile {profile_id} disconnected. Stopping monitoring.")
            await stop_monitoring_service(camera_profiles, db)

    except Exception as e:
        print(f"[ERROR] Failed to handle disconnection and stop detection: {e}")

# פונקציה חדשה לשמירה של התמונות
def save_detection_image(base_path, baby_profile_id, camera_type, class_name, class_id, result, frame):
    folder = os.path.join(base_path, str(baby_profile_id), camera_type)
    os.makedirs(folder, exist_ok=True)

    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S_%f")
    filename = f"{timestamp}_class_id_{class_id}_{class_name}.jpg"
    file_path = os.path.join(folder, filename)

    for box in result.boxes:
        if int(box.cls) == int(result.cls):
            xyxy = box.xyxy[0].cpu().numpy().astype(int)
            cv2.rectangle(frame, (xyxy[0], xyxy[1]), (xyxy[2], xyxy[3]), (0, 255, 0), 2)
            cv2.putText(frame, class_name, (xyxy[0], xyxy[1]-10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)

    cv2.imwrite(file_path, frame)

    relative_path = os.path.join("detections", str(baby_profile_id), camera_type, filename)
    return relative_path



