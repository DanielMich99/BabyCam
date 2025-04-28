from fastapi import APIRouter
from app.controllers.alert_controller import create_alert, get_alerts

router = APIRouter()

# שליחת התראה למערכת
router.post("/send_alert/{baby_profile_id}")(create_alert)

# קבלת כל ההתראות של המשתמש
router.get("/alerts/{baby_profile_id}")(get_alerts)
