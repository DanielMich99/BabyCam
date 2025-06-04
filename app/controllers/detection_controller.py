from fastapi import HTTPException, Depends, UploadFile, File
from sqlalchemy.orm import Session
from app.models.baby_profile_model import BabyProfile
from app.services.detection_service import detect_objects, get_last_detection_results
#from app.services.baby_profile_service import get_profile_dangerous_objects_static
from app.services.alert_service import save_alert
from database.database import get_db
from app.utils.config import config
import os


def process_detection(baby_profile_id: str, file: UploadFile = File(...), db: Session = Depends(get_db)):
    """מריץ זיהוי על התמונה האחרונה שנשמרה למשתמש"""
    # שמור את התמונה
    save_path = os.path.join(config.UPLOAD_DIR, str(baby_profile_id), "last_frame.jpg")
    os.makedirs(os.path.dirname(save_path), exist_ok=True)
    with open(save_path, "wb") as buffer:
        buffer.write(file.file.read())

    detected_objects = detect_objects(db, baby_profile_id)
    
    if not detected_objects:
        raise HTTPException(status_code=404, detail="No objects detected")

    profile = db.query(BabyProfile).filter(BabyProfile.id == baby_profile_id).first()

    # if not profile:
    #     raise HTTPException(status_code=404, detail="Baby profile not found")

    # קבלת חפצים מסוכנים מומלצים מה-AI על פי מאפייני התינוק
    #dangerous_objects = get_profile_dangerous_objects_static(db, profile.id)

    # בדיקת התאמה בין מה שזוהה לבין החפצים המסוכנים
    # detected_dangerous = [
    # obj for obj in dangerous_objects
    # if obj["name"] in detected_objects]


    # if detected_dangerous:
    #     save_alert(baby_profile_id, detected_dangerous, f"Detected dangerous objects: {', '.join(detected_dangerous)}")

    #return {"detected_objects": detected_objects, "dangerous_objects": detected_dangerous}
    return {"detected_objects": detected_objects}

def get_last_detection(baby_profile_id: str, db: Session = Depends(get_db)):
    """מחזיר את תוצאות הזיהוי האחרונות של המשתמש"""
    return get_last_detection_results(db, baby_profile_id)
