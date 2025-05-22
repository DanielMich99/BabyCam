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
YOLO_MODEL_PATH = os.path.join(BASE_DIR,"uploads", "training_data", "1", "head_camera", "1_head_camera_model.pt")  # הנחתי שזה השם

#model = YOLO(YOLO_MODEL_PATH)

# שמות הקלאסים לפי סדר האימון
#CLASSES = ['knife', 'scissors', 'window', 'pill', 'toilet']
CLASSES = ['pen']

def detect_objects(db: Session, baby_profile_id: int):
    global model

    # טען את המודל רק אם עדיין לא נטען
    if model is None:
        if not os.path.exists(YOLO_MODEL_PATH):
            raise HTTPException(status_code=500, detail="YOLO model file not found")
        try:
            model = YOLO(YOLO_MODEL_PATH)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to load YOLO model: {str(e)}")

    image_path = os.path.join(config.UPLOAD_DIR, str(baby_profile_id), "last_frame.jpg")
    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="No image found for this baby profile")

    results = model(image_path)

    output_dir = os.path.join(config.UPLOAD_DIR, str(baby_profile_id))
    os.makedirs(output_dir, exist_ok=True)

    output_path = os.path.join(output_dir, "last_frame_box.jpg")
    results[0].save(filename=output_path)

    detections = results[0].boxes
    detected_objects = []
    for box in detections:
        class_id = int(box.cls[0])
        confidence = float(box.conf[0])
        obj_name = CLASSES[class_id]
        detected_objects.append(obj_name)

    return {"detected_objects": detected_objects}



# ✅ **2. שליפת תוצאות זיהוי אחרונות מה-DB**
def get_last_detection_results(db: Session, baby_profile_id: int):
    """מחזיר את תוצאות הזיהוי האחרונות מה-DB"""
    results = db.query(DetectionResult).filter(DetectionResult.baby_profile_id == baby_profile_id).all()
    if not results:
        raise HTTPException(status_code=404, detail="No detection results found")

    return {"detected_objects": [result.detected_object for result in results]}
