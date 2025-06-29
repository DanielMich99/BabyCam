import os
import time
import threading
import asyncio
from datetime import datetime, timezone
from app.utils.google_drive_service import GoogleDriveService
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from app.utils.config import config
from app.utils.websocket_broadcast import broadcast_detection  # שימוש בחדש לפי המימוש שלך
from app.utils.fcm_push import send_push_notifications
from app.models.user_model import User, UserFCMToken
from app.models.baby_profile_model import BabyProfile
from sqlalchemy.orm import Session
from database.database import SessionLocal

# יצירת אובייקט שירות ל־Drive
drive_service = GoogleDriveService()

# רשימת אימונים פעילים למעקב
pending_trainings = []

def register_pending_training(user_id: int, baby_profile_id: int, camera_type: str):
    pending_trainings.append({
        "user_id": user_id,
        "baby_profile_id": baby_profile_id,
        "camera_type": camera_type,
        "start_time": time.time()
    })

def polling_loop():
    while True:
        try:
            db: Session = SessionLocal()

            for training in pending_trainings[:]:  # נ iterate על עותק כדי לאפשר הסרה תוך כדי ריצה
                user_id = training["user_id"]
                baby_profile_id = training["baby_profile_id"]
                camera_type = training["camera_type"]
                start_time = training["start_time"]

                if check_and_download_model(baby_profile_id, camera_type, start_time):
                    print(f"[TRAINING MONITOR] Model ready for {baby_profile_id} - {camera_type}")

                    event = {
                        "type": "model_training_completed",
                        "baby_profile_id": baby_profile_id,
                        "camera_type": camera_type
                    }
                    asyncio.run(broadcast_detection(user_id, event))

                    # שליחת פוש
                    user = db.query(User).filter_by(id=user_id).first()
                    if user:
                        tokens = [t.token for t in db.query(UserFCMToken).filter_by(user_id=user.id).all()]
                        if tokens:
                            baby = db.query(BabyProfile).filter_by(id=baby_profile_id).first()
                            send_push_notifications(
                                tokens,
                                {
                                    "message": {
                                        "notification": {
                                            "title": "Model Ready",
                                            "body": f"New {camera_type} model for {baby.name} is ready!"
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
                                                        "title": "Model Ready",
                                                        "body": f"New {camera_type} model for {baby.name} is ready!"
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


                    pending_trainings.remove(training)

            db.close()
            time.sleep(10)
        except Exception as e:
            print(f"[ERROR] Training polling error: {e}")
            time.sleep(5)

def start_monitoring_thread():
    thread = threading.Thread(target=polling_loop, daemon=True)
    thread.start()
    
def check_and_download_model(baby_profile_id: int, camera_type: str, start_time: float) -> bool:
    file_name = f"{baby_profile_id}_{camera_type}_model.pt"
    local_path = os.path.join("uploads", "training_data", str(baby_profile_id), camera_type, file_name)

    # מוודא שהמבנה של התיקיות קיים בדרייב
    root_folder_id = drive_service.get_or_create_folder("babycam_data")
    profile_folder_id = drive_service.get_or_create_folder(str(baby_profile_id), root_folder_id)
    model_folder_id = drive_service.get_or_create_folder(camera_type, profile_folder_id)

    # בודק אם קובץ קיים עם createdTime
    query = f"'{model_folder_id}' in parents and name='{file_name}' and trashed=false"
    results = drive_service.service.files().list(q=query, fields="files(id, name, createdTime)").execute().get('files', [])

    if not results:
        return False

    file_metadata = results[0]
    created_time_str = file_metadata['createdTime']
    created_time = datetime.fromisoformat(created_time_str.replace("Z", "+00:00"))
    start_dt = datetime.fromtimestamp(start_time, tz=timezone.utc)

    if created_time < start_dt:
        print(f"[SKIP] Found old model created at {created_time}, waiting for new model...")
        return False

    # מוריד את הקובץ
    file_id = file_metadata['id']
    os.makedirs(os.path.dirname(local_path), exist_ok=True)
    drive_service.download_file(file_id, local_path)

    db: Session = SessionLocal()
    profile = db.query(BabyProfile).filter(BabyProfile.id == baby_profile_id).first()
    if profile:
        if camera_type == "head_camera":
            profile.head_camera_model_last_updated_time = datetime.now()
        else:
            profile.static_camera_model_last_updated_time = datetime.now()
        db.commit()
    db.close()

    return True