from sqlalchemy.orm import declarative_base

# יצירת מחלקת בסיס לכל המודלים
Base = declarative_base()

# ייבוא כל המודלים כדי ש-Alembic יזהה אותם
from app.models import (
    user_model,
    baby_profile_model,
    detection_result_model,
    class_model
)
