from fastapi import APIRouter
from app.controllers.detection_controller import process_detection, get_last_detection

router = APIRouter()

# אנדפוינט לעיבוד תמונה
router.post("/process/{baby_profile_id}")(process_detection)

# אנדפוינט לקבלת תוצאות הזיהוי האחרונות
router.get("/last/{baby_profile_id}")(get_last_detection)
