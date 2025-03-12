from fastapi import HTTPException, Query
from app.services.camera_service import start_camera_service, stop_camera_service, get_camera_status_service, capture_frame_service

def start_camera(user_id: str, camera_url: str = Query(..., description="ESP32-CAM streaming URL")):
    """אנדפוינט שמפעיל חיבור למצלמת ESP32-CAM"""
    if get_camera_status_service(user_id):
        raise HTTPException(status_code=400, detail="Camera is already running")
    
    success = start_camera_service(user_id, camera_url)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to connect to camera")

    return {"message": "Camera registered", "camera_url": camera_url}

def stop_camera(user_id: str):
    """אנדפוינט שעוצר את המצלמה"""
    if not get_camera_status_service(user_id):
        raise HTTPException(status_code=400, detail="Camera is not running")
    
    stop_camera_service(user_id)
    return {"message": "Camera unregistered"}

def get_camera_status(user_id: str):
    """בודק אם המצלמה פועלת כרגע"""
    status = get_camera_status_service(user_id)
    return {"camera_active": status}

def get_camera_frame(user_id: str):
    """לוקח תמונה מזרם ה-ESP32-CAM"""
    frame_path = capture_frame_service(user_id)
    if not frame_path:
        raise HTTPException(status_code=500, detail="Failed to capture frame")
    return {"frame_path": frame_path}
