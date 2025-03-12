from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base 
from app.utils.config import config

# יצירת חיבור למסד הנתונים
engine = create_engine(config.DATABASE_URL, connect_args={"check_same_thread": False} if "sqlite" in config.DATABASE_URL else {})

# יצירת מחלקת בסיס לכל המודלים
Base = declarative_base()

# ניהול סשן חיבור ל-DB
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# פונקציה ליצירת טבלת המודלים במסד הנתונים
def init_db():
    Base.metadata.create_all(bind=engine)
