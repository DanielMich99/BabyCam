from app.models.base import Base
from database.database import engine
from sqlalchemy.orm import Session

# ✅ יצירת טבלאות במסד הנתונים
def init_db():
    print("📌 יצירת טבלאות במסד הנתונים...")
    Base.metadata.create_all(bind=engine)
    print("✅ טבלאות נוצרו בהצלחה!")
