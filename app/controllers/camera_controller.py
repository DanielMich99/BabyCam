from fastapi import HTTPException, Query
from sqlalchemy.orm import Session
from app.services.camera_service import start_camera_service, stop_camera_service, get_camera_status_service, capture_frame_service

def start_camera(db: Session, profile_id: int, camera_url: str = Query(..., description="ESP32-CAM streaming URL")):
    """אנדפוינט שמפעיל חיבור למצלמת ESP32-CAM"""
    status = get_camera_status_service(db, profile_id)
    if status:
        raise HTTPException(status_code=400, detail="Camera is already running")

    success = start_camera_service(db, profile_id, camera_url)
    return success

def stop_camera(db: Session, profile_id: int):
    """אנדפוינט שעוצר את המצלמה"""
    status = get_camera_status_service(db, profile_id)
    if not status:
        raise HTTPException(status_code=400, detail="Camera is not running")

    return stop_camera_service(db, profile_id)

def get_camera_status(db: Session, profile_id: int):
    """בודק אם המצלמה פועלת כרגע"""
    status = get_camera_status_service(db, profile_id)
    return {"camera_active": status}

def get_camera_frame(db: Session, profile_id: int):
    """לוקח תמונה מזרם ה-ESP32-CAM ושומר אותה לפי הפרופיל"""
    frame_path = capture_frame_service(db, profile_id)
    if not frame_path:
        raise HTTPException(status_code=500, detail="Failed to capture frame")
    return {"frame_path": frame_path}
