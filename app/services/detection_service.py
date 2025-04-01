import cv2
import numpy as np
import os
from sqlalchemy.orm import Session
from app.models.detection_result_model import DetectionResult
from fastapi import HTTPException
from app.utils.config import config

# הגדרת נתיבים לקובצי YOLO
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # יוצא מהתיקייה services
YOLO_WEIGHTS_PATH = os.path.join(BASE_DIR, "yolov3.weights")
YOLO_CFG_PATH = os.path.join(BASE_DIR, "yolov3.cfg")
COCO_NAMES_PATH = os.path.join(BASE_DIR, "coco.names")

# וידוא שהקבצים קיימים
if not os.path.exists(YOLO_WEIGHTS_PATH):
    raise FileNotFoundError(f"yolov3.weights not found at {YOLO_WEIGHTS_PATH}")
if not os.path.exists(YOLO_CFG_PATH):
    raise FileNotFoundError(f"yolov3.cfg not found at {YOLO_CFG_PATH}")
if not os.path.exists(COCO_NAMES_PATH):
    raise FileNotFoundError(f"coco.names not found at {COCO_NAMES_PATH}")

# טעינת המודל של YOLO
net = cv2.dnn.readNet(YOLO_WEIGHTS_PATH, YOLO_CFG_PATH)
layer_names = net.getLayerNames()
output_layers = [layer_names[i - 1] for i in net.getUnconnectedOutLayers()]

# טעינת רשימת האובייקטים מ-coco.names
with open(COCO_NAMES_PATH, "r") as f:
    classes = [line.strip() for line in f.readlines()]

# ✅ **1. זיהוי אובייקטים ושמירתם ב-DB**
def detect_objects(db: Session, user_id: int):
    """מפעיל זיהוי אובייקטים על התמונה האחרונה של המשתמש"""
    image_path = os.path.join(config.UPLOAD_DIR, str(user_id), "last_frame.jpg")
    
    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="No image found for this user")

    image = cv2.imread(image_path)
    height, width, _ = image.shape

    # עיבוד התמונה עם YOLO
    blob = cv2.dnn.blobFromImage(image, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
    net.setInput(blob)
    detections = net.forward(output_layers)

    detected_objects = []

    for output in detections:
        for detection in output:
            scores = detection[5:]
            class_id = np.argmax(scores)
            confidence = scores[class_id]

            if confidence > 0.5:  # סף זיהוי
                detected_objects.append(classes[class_id])

    # ✅ שמירת תוצאות הזיהוי ב-DB
    for obj in detected_objects:
        new_detection = DetectionResult(user_id=user_id, detected_object=obj, confidence=int(confidence * 100))
        db.add(new_detection)
    db.commit()
    return detected_objects

# ✅ **2. שליפת תוצאות זיהוי אחרונות מה-DB**
def get_last_detection_results(db: Session, user_id: int):
    """מחזיר את תוצאות הזיהוי האחרונות מה-DB"""
    results = db.query(DetectionResult).filter(DetectionResult.user_id == user_id).all()
    if not results:
        raise HTTPException(status_code=404, detail="No detection results found")

    return {"detected_objects": [result.detected_object for result in results]}
