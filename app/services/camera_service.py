import cv2
import requests
import os
import time
from app.utils.config import config

camera_active = {}  # מעקב אחרי מצב המצלמות
camera_urls = {}  # שמירת כתובות ה-ESP32 לכל משתמש

def start_camera_service(user_id, camera_url):
    """שומר את כתובת ה-ESP32 ומפעיל את המצלמה"""
    camera_active[user_id] = True
    camera_urls[user_id] = camera_url
    return True  # אין צורך בהרצה לולאתית, כי השידור מגיע משרת ה-ESP32

def stop_camera_service(user_id):
    """עוצר את המצלמה בכך שמפסיק לשמור תמונות"""
    if user_id in camera_active:
        camera_active[user_id] = False
        del camera_urls[user_id]

def get_camera_status_service(user_id):
    """בודק אם המצלמה פעילה"""
    return camera_active.get(user_id, False)

def capture_frame_service(user_id):
    """לוקח תמונה אחת מזרם ה-ESP32-CAM ושומר אותה"""
    if user_id not in camera_urls:
        return None

    camera_url = camera_urls[user_id]
    frame_url = f"{camera_url}/capture"  # ברוב הקושחות יש `http://ESP_IP/capture`
    
    try:
        response = requests.get(frame_url, timeout=5)
        if response.status_code == 200:
            frame_path = os.path.join(config.UPLOAD_DIR, f"{user_id}_frame.jpg")
            with open(frame_path, "wb") as f:
                f.write(response.content)
            return frame_path
        else:
            return None
    except requests.RequestException:
        return None
