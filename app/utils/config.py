import os
from dotenv import load_dotenv

# טוען משתנים מקובץ .env (אם קיים)
if not load_dotenv():
    print("⚠️  Warning: .env file not found or could not be loaded!")

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "supersecretkey")
    ALGORITHM = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
    REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7))

    UPLOAD_DIR = os.getenv("UPLOAD_DIR", "uploads")
    ALLOWED_EXTENSIONS = {".png", ".jpg", ".jpeg"}
    FCM_SERVER_KEY = os.getenv("FCM_SERVER_KEY")
    GOOGLE_CREDENTIALS_PATH = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    FIREBASE_PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID")

config = Config()

# בדיקה שהמשתנים נטענו בהצלחה
if config.SECRET_KEY == "supersecretkey":
    print("⚠️  Warning: SECRET_KEY is using the default value! Make sure .env is configured correctly.")

