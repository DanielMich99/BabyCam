from fastapi import HTTPException
from app.services.alert_service import save_alert, fetch_alerts

def create_alert(baby_profile_id: int, objects_detected: list, description: str):
    """שולח התראה על אירוע מסוכן"""
    success = save_alert(baby_profile_id, objects_detected, description)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to save alert")
    return {"message": "Alert sent successfully"}

def get_alerts(baby_profile_id: int):
    """מציג את כל ההתראות שנשלחו למשתמש"""
    alerts = fetch_alerts(baby_profile_id)
    return {"alerts": alerts}
