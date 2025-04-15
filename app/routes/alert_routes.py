from fastapi import APIRouter
from app.controllers.alert_controller import create_alert, get_alerts

router = APIRouter()

# שליחת התראה למערכת
router.post("/send_alert/{user_id}")(create_alert)

# קבלת כל ההתראות של המשתמש
router.get("/alerts/{user_id}")(get_alerts)
