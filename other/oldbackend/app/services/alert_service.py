from sqlalchemy.orm import Session
from app.models.alert_model import Alert
from fastapi import HTTPException

# ✅ **1. שמירת התראה חדשה ב-DB**
def save_alert(db: Session, baby_profile_id: int, objects_detected: list, description: str):
    """שומר התראה חדשה ב-DB"""
    new_alert = Alert(
        baby_profile_id=baby_profile_id,
        objects_detected=objects_detected,
        description=description
    )
    db.add(new_alert)
    db.commit()
    db.refresh(new_alert)
    return {"message": "Alert saved successfully"}

# ✅ **2. שליפת כל ההתראות של המשתמש מה-DB**
def fetch_alerts(db: Session, baby_profile_id: int):
    """מחזיר את כל ההתראות של המשתמש מה-DB"""
    alerts = db.query(Alert).filter(Alert.baby_profile_id == baby_profile_id).all()
    if not alerts:
        return []
    return [{"description": alert.description} for alert in alerts]
