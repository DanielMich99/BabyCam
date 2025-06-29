import os
import urllib.parse
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
from app.models.base import Base  # מייבאים רק את Base בלי המודלים האחרים

# טוען משתני סביבה
load_dotenv()

# קידוד הסיסמה אם היא מכילה תווים מיוחדים
password = urllib.parse.quote_plus(os.getenv("DB_PASSWORD"))

# יצירת URL תקין לחיבור למסד הנתונים
DATABASE_URL = f"postgresql://{os.getenv('DB_USERNAME')}:{password}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"

print("🔧 DATABASE_URL =", DATABASE_URL)

# יצירת מנוע SQLAlchemy
engine = create_engine(DATABASE_URL)

# יצירת מחבר הסשן
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# ✅ פונקציה ליצירת חיבור למסד הנתונים בכל בקשה
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# אם הקובץ מורץ ישירות, נבצע יצירת טבלאות
if __name__ == "__main__":
    pass