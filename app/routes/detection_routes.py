from fastapi import APIRouter
from app.controllers.detection_controller import process_detection, get_last_detection

router = APIRouter()

# אנדפוינט לעיבוד תמונה
router.post("/process/{user_id}")(process_detection)

# אנדפוינט לקבלת תוצאות הזיהוי האחרונות
router.get("/last/{user_id}")(get_last_detection)
