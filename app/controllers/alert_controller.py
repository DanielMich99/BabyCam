from fastapi import HTTPException
from app.services.alert_service import save_alert, fetch_alerts

def create_alert(user_id: str, alert_type: str, description: str):
    """שולח התראה על אירוע מסוכן"""
    success = save_alert(user_id, alert_type, description)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to save alert")
    return {"message": "Alert sent successfully"}

def get_alerts(user_id: str):
    """מציג את כל ההתראות שנשלחו למשתמש"""
    alerts = fetch_alerts(user_id)
    return {"alerts": alerts}
