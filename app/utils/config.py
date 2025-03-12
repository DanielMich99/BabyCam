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

    # הגדרת DB (כרגע SQLite באופן זמני, נחליף אותו בענן בהמשך)
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./app.db")

config = Config()

# בדיקה שהמשתנים נטענו בהצלחה
if config.SECRET_KEY == "supersecretkey":
    print("⚠️  Warning: SECRET_KEY is using the default value! Make sure .env is configured correctly.")

if config.DATABASE_URL.startswith("sqlite") and "app.db" in config.DATABASE_URL:
    print("ℹ️  Info: Using SQLite. This should be replaced with a cloud DB in production.")
