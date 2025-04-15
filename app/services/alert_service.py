from sqlalchemy.orm import Session
from app.models.alert_model import Alert
from fastapi import HTTPException

# ✅ **1. שמירת התראה חדשה ב-DB**
def save_alert(db: Session, user_id: int, alert_type: str, description: str):
    """שומר התראה חדשה ב-DB"""
    new_alert = Alert(
        user_id=user_id,
        alert_type=alert_type,
        description=description
    )
    db.add(new_alert)
    db.commit()
    db.refresh(new_alert)
    return {"message": "Alert saved successfully"}

# ✅ **2. שליפת כל ההתראות של המשתמש מה-DB**
def fetch_alerts(db: Session, user_id: int):
    """מחזיר את כל ההתראות של המשתמש מה-DB"""
    alerts = db.query(Alert).filter(Alert.user_id == user_id).all()
    if not alerts:
        return []
    return [{"type": alert.alert_type, "description": alert.description} for alert in alerts]
