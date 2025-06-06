import os
import time
import threading
import asyncio
from app.utils.google_drive_service import GoogleDriveService
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from app.utils.config import config
from app.utils.websocket_broadcast import broadcast_detection  # שימוש בחדש לפי המימוש שלך
from app.utils.fcm_push import send_push_notification, send_push_notifications
from app.models.user_model import User, UserFCMToken
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

                if check_and_download_model(user_id, camera_type):
                    print(f"[TRAINING MONITOR] Model ready for {user_id} - {camera_type}")

                    # שליחת סוקט - לפי המימוש שלך: broadcast_detection(user_id, event_data)
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
                            send_push_notifications(
                                tokens,
                                "Model Ready",
                                f"New model for {camera_type} is ready!",
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

'''def check_and_download_model(user_id: int, camera_type: str) -> bool:
    gauth = GoogleAuth()
    gauth.LocalWebserverAuth()
    drive = GoogleDrive(gauth)

    file_name = f"{user_id}_{camera_type}_model.pt"
    local_path = os.path.join("uploads", "training_data", str(user_id), camera_type, file_name)

    folders = drive.ListFile({'q': "mimeType='application/vnd.google-apps.folder' and trashed=false"}).GetList()
    root = next((f for f in folders if f['title'] == "babycam_data"), None)
    if not root:
        return False

    profile_query = f"'{root['id']}' in parents and title = '{user_id}'"
    profiles = drive.ListFile({'q': profile_query}).GetList()
    if not profiles:
        return False

    model_query = f"'{profiles[0]['id']}' in parents and title = '{camera_type}'"
    models = drive.ListFile({'q': model_query}).GetList()
    if not models:
        return False

    file_query = f"'{models[0]['id']}' in parents and title = '{file_name}' and trashed=false"
    results = drive.ListFile({'q': file_query}).GetList()
    if not results:
        return False

    results[0].GetContentFile(local_path)
    return True'''

def check_and_download_model(user_id: int, camera_type: str) -> bool:
    file_name = f"{user_id}_{camera_type}_model.pt"
    local_path = os.path.join("uploads", "training_data", str(user_id), camera_type, file_name)

    # מוודא שהמבנה של התיקיות קיים בדרייב
    root_folder_id = drive_service.get_or_create_folder("babycam_data")
    profile_folder_id = drive_service.get_or_create_folder(str(user_id), root_folder_id)
    model_folder_id = drive_service.get_or_create_folder(camera_type, profile_folder_id)

    # בודק האם הקובץ קיים בתיקיה
    query = f"'{model_folder_id}' in parents and name='{file_name}' and trashed=false"
    results = drive_service.service.files().list(q=query, fields="files(id, name)").execute().get('files', [])

    if not results:
        return False

    # מוריד את הקובץ
    file_id = results[0]['id']
    request = drive_service.service.files().get_media(fileId=file_id)
    os.makedirs(os.path.dirname(local_path), exist_ok=True)

    with open(local_path, 'wb') as f:
        downloader = drive_service.MediaIoBaseDownload(f, request)
        done = False
        while not done:
            status, done = downloader.next_chunk()
            print(f"[DOWNLOAD] Download {int(status.progress() * 100)}%")

    return True
