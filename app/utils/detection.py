from ultralytics import YOLO
import cv2
import asyncio
import httpx
from datetime import datetime
from app.services.monitoring_service import stop_monitoring_service
from app.models.detection_result_model import DetectionResult
from app.models.class_model import ClassObject

running_tasks = {}
last_detection_time = {}  # key: profile_camera_class, value: datetime

async def start_detection_loop(profile_id: int, camera_type: str, ip: str, model_path: str, db, camera_profiles, origin: str):
    model = YOLO(model_path)
    stream_url = f"http://{ip}/stream"

    async def detect():
        cap = cv2.VideoCapture(stream_url)
        try:
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    print(f"[DISCONNECTED] Camera for Profile {profile_id} - {camera_type}")
                    await notify_frontend_camera_disconnected(profile_id, camera_type, origin)
                    await stop_monitoring_service(camera_profiles, db)
                    break

                results = model(frame)[0]
                now = datetime.utcnow()

                for result in results.boxes:
                    if result.conf > 0.5:
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

                            print(f"[DETECTED] Profile {profile_id}, Class {class_id}, Confidence {result.conf:.2f}")

                            detection = DetectionResult(
                                baby_profile_id=profile_id,
                                class_id=class_id,
                                class_name=class_name,
                                confidence=float(result.conf),
                                camera_type=camera_type
                            )
                            db.add(detection)
                            db.commit()

                            class_obj = db.query(ClassObject).filter_by(
                                baby_profile_id=profile_id,
                                camera_type=camera_type,
                                model_index=class_id
                            ).first()
                            class_name = class_obj.name if class_obj else "unknown"
                            risk_level = class_obj.risk_level if class_obj else "unknown"

                            await notify_frontend_detection(profile_id, camera_type, class_id, class_name, risk_level, float(result.conf), origin)
                await asyncio.sleep(0.5)
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

async def notify_frontend_camera_disconnected(profile_id: int, camera_type: str, origin: str):
    try:
        async with httpx.AsyncClient() as client:
            await client.post(f"{origin}/api/camera/disconnected", json={
                "baby_profile_id": profile_id,
                "camera_type": camera_type,
                "reason": "disconnected"
            })
    except Exception as e:
        print(f"[WARNING] Failed to notify frontend: {e}")

async def notify_frontend_detection(profile_id: int, camera_type: str, class_id: int, class_name: str, risk_level: int, confidence: float, origin: str):
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
        print(f"[WARNING] Failed to notify frontend of detection: {e}")
