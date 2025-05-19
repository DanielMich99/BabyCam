from ultralytics import YOLO
import os
from sqlalchemy.orm import Session
from app.models.detection_result_model import DetectionResult
from fastapi import HTTPException
from app.utils.config import config
from datetime import datetime
import shutil
import glob

# טען את המודל המאומן
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
YOLO_MODEL_PATH = os.path.join(BASE_DIR, "2_head_camera_model.pt")  # הנחתי שזה השם
model = YOLO(YOLO_MODEL_PATH)

# שמות הקלאסים לפי סדר האימון
#CLASSES = ['knife', 'scissors', 'window', 'pill', 'toilet']
CLASSES = ['pen']

def detect_objects(db: Session, baby_profile_id: int):
    image_path = os.path.join(config.UPLOAD_DIR, str(baby_profile_id), "last_frame.jpg")
    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="No image found for this baby profile")

    results = model(image_path)

    # שמירת תמונה עם תיבות לתוך תיקיית המשתמש
    output_dir = os.path.join(config.UPLOAD_DIR, str(baby_profile_id))
    os.makedirs(output_dir, exist_ok=True)

    # שמור את התמונה עם bounding boxes בשם קבוע
    output_path = os.path.join(output_dir, "last_frame_box.jpg")
    results[0].save(filename=output_path)

    detections = results[0].boxes
    # if detections is None or detections.shape[0] == 0:
        # raise HTTPException(status_code=404, detail="No objects detected")

    detected_objects = []
    for box in detections:
        class_id = int(box.cls[0])
        confidence = float(box.conf[0])
        obj_name = CLASSES[class_id]

        detected_objects.append(obj_name)

    #     detection_record = DetectionResult(
    #         baby_profile_id=baby_profile_id,
    #         detected_object=obj_name,
    #         confidence=int(confidence * 100),
    #         timestamp=datetime.utcnow()
    #     )
    #     db.add(detection_record)

    # db.commit()
    return {"detected_objects": detected_objects}


# ✅ **2. שליפת תוצאות זיהוי אחרונות מה-DB**
def get_last_detection_results(db: Session, baby_profile_id: int):
    """מחזיר את תוצאות הזיהוי האחרונות מה-DB"""
    results = db.query(DetectionResult).filter(DetectionResult.baby_profile_id == baby_profile_id).all()
    if not results:
        raise HTTPException(status_code=404, detail="No detection results found")

    return {"detected_objects": [result.detected_object for result in results]}
