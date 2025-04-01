import os
import requests
import shutil
from sqlalchemy.orm import Session
from app.models.camera_model import Camera
from fastapi import HTTPException
from app.utils.config import config

# ✅ **1. הפעלת מצלמה ושמירת ה-URL ב-DB**
def start_camera_service(db: Session, profile_id: int, camera_url: str):
    camera = db.query(Camera).filter(Camera.profile_id == profile_id).first()
    
    if camera:
        camera.active = True
        camera.url = camera_url
    else:
        camera = Camera(profile_id=profile_id, url=camera_url, active=True)
        db.add(camera)
    
    db.commit()
    db.refresh(camera)
    return {"message": "Camera activated successfully"}


# ✅ **2. עצירת המצלמה ועדכון הסטטוס ב-DB**
def stop_camera_service(db: Session, profile_id: int):
    camera = db.query(Camera).filter(Camera.profile_id == profile_id).first()
    
    if camera:
        camera.active = False
        camera.url = None
        db.commit()
        return {"message": "Camera stopped successfully"}
    else:
        raise HTTPException(status_code=404, detail="Camera not found")

# ✅ **3. שליפת סטטוס המצלמה מה-DB**
def get_camera_status_service(db: Session, profile_id: int):
    camera = db.query(Camera).filter(Camera.profile_id == profile_id).first()
    if not camera:
        return False
    return camera.active

# ✅ **4. צילום תמונה ושמירתה בנתיב**
def capture_frame_service(db: Session, profile_id: int):
    camera = db.query(Camera).filter(Camera.profile_id == profile_id, Camera.active == True).first()
    
    if not camera or not camera.url:
        raise HTTPException(status_code=404, detail="Camera not found or inactive")

    frame_url = f"{camera.url}/capture"  # כתובת ה-Capture מה-ESP32
    
    try:
        response = requests.get(frame_url, timeout=5)
        if response.status_code == 200:
            profile_dir = os.path.join(config.UPLOAD_DIR, str(profile_id))
            os.makedirs(profile_dir, exist_ok=True)

            frame_path = os.path.join(profile_dir, f"{profile_id}_frame.jpg")
            with open(frame_path, "wb") as f:
                f.write(response.content)
            return frame_path
        else:
            raise HTTPException(status_code=500, detail="Failed to capture frame from camera")
    except requests.RequestException:
        raise HTTPException(status_code=500, detail="Unable to connect to camera")
