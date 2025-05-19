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

# 📌 פונקציה שטוענת את כל המודלים **לפני יצירת טבלאות**
def import_models():
    import app.models.user_model
    import app.models.file_model
    import app.models.baby_profile_model
    import app.models.detection_result_model

# פונקציה ליצירת כל הטבלאות במסד הנתונים
def init_db():
    print("📌 טוען מודלים ויוצר טבלאות...")

    # 🚀 טוען את כל המודלים
    import_models()

    print("🔍 טבלאות ש-SQLAlchemy מזהה:", Base.metadata.tables.keys())

    # יצירת כל הטבלאות במסד הנתונים
    Base.metadata.create_all(bind=engine)

    print("✅ טבלאות נוצרו בהצלחה!")

# ✅ פונקציה ליצירת חיבור למסד הנתונים בכל בקשה
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# אם הקובץ מורץ ישירות, נבצע יצירת טבלאות
if __name__ == "__main__":
    init_db()
