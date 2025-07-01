import os
from dotenv import load_dotenv

# Load environment variables from a .env file
if not load_dotenv():
    print("⚠️  Warning: .env file not found or could not be loaded!")

# Configuration class holding application settings from environment
class Config:
    # JWT authentication settings
    SECRET_KEY = os.getenv("SECRET_KEY", "supersecretkey")
    ALGORITHM = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
    REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7))

    # File upload settings
    UPLOAD_DIR = os.getenv("UPLOAD_DIR", "uploads")
    ALLOWED_EXTENSIONS = {".png", ".jpg", ".jpeg"}

    # Firebase & Google Cloud credentials
    FCM_SERVER_KEY = os.getenv("FCM_SERVER_KEY")
    GOOGLE_CREDENTIALS_PATH = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    FIREBASE_PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID")

# Instantiate the config for use across the application
config = Config()

# Warn the developer if default secret is used
if config.SECRET_KEY == "supersecretkey":
    print("⚠️  Warning: SECRET_KEY is using the default value! Make sure .env is configured correctly.")
