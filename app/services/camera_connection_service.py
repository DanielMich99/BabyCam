import asyncio
import time
import socket
import http.client
from typing import Dict, Tuple, Optional

from sqlalchemy.orm import Session
from app.models.baby_profile_model import BabyProfile
from database.database import SessionLocal
from app.utils.esp32_stream_buffer import ESP32StreamBuffer
from app.utils.detection import stream_buffers  # ודא שזה import נכון לפי איפה שזה מוגדר אצלך


class CameraConnectionManager:
    def __init__(self):
        self._waiting_connections: Dict[str, Tuple[int, str]] = {}  # ip -> (baby_profile_id, camera_type)

    def register_waiting_connection(self, baby_profile_id: int, camera_type: str):
        key = f"{baby_profile_id}:{camera_type}"
        self._waiting_connections[key] = None  # אין עדיין IP
        print(f"📡 [SERVER] מחכה למצלמה עבור baby_profile_id={baby_profile_id}, camera_type={camera_type}")

    def register_camera_ip(self, ip: str):
        print("📬 [SERVER] התקבל IP:", ip)
        print("📦 [SERVER] מצבים נוכחיים שמחכים:", self._waiting_connections)
        for key in self._waiting_connections:
            if self._waiting_connections[key] is None:
                self._waiting_connections[key] = ip
                return key  # נחזיר את הקישור שמצאנו
        return None

    async def wait_for_camera(self, baby_profile_id: int, camera_type: str, timeout: int = 60) -> bool:
        self.register_waiting_connection(baby_profile_id, camera_type)
        key = f"{baby_profile_id}:{camera_type}"
        start = time.time()

        while time.time() - start < timeout:
            ip = self._waiting_connections.get(key)
            if ip:
                if await self._is_camera_alive(ip):
                    await self._update_baby_profile_connection(baby_profile_id, camera_type, ip, True)
                    del self._waiting_connections[key]
                    return f"http://{ip}/stream"
                else:
                    print(f"Camera at {ip} not responding.")    
            await asyncio.sleep(1)

        del self._waiting_connections[key]
        return None

    async def _is_camera_alive(self, ip: str) -> bool:
        try:
            conn = http.client.HTTPConnection(ip, timeout=2)
            conn.request("GET", "/")
            response = conn.getresponse()
            return response.status == 200
        except Exception:
            return False

    async def _update_baby_profile_connection(self, baby_profile_id: int, camera_type: str, ip: str, is_connected: bool):
        db: Session = SessionLocal()
        profile = db.query(BabyProfile).filter(BabyProfile.id == baby_profile_id).first()
        if not profile:
            db.close()
            return
        
        if camera_type == "head_camera":
            profile.head_camera_ip = ip if is_connected else None
            profile.head_camera_on = is_connected
        else:
            profile.static_camera_ip = ip if is_connected else None
            profile.static_camera_on = is_connected
        
        db.commit()
        db.close()

    def disconnect_camera(self, baby_profile_id: int, camera_type: str):
        db: Session = SessionLocal()
        profile = db.query(BabyProfile).filter(BabyProfile.id == baby_profile_id).first()

        if not profile:
            db.close()
            return False

        if camera_type == "head_camera":
            profile.head_camera_ip = None
            profile.head_camera_on = False
        elif camera_type == "static_camera":
            profile.static_camera_ip = None
            profile.static_camera_on = False
        else:
            db.close()
            return False

        db.commit()
        db.close()
        return True
    
    def reset_all_camera_ips_for_user(self, user_id: int) -> int:
        db: Session = SessionLocal()
        profiles = db.query(BabyProfile).filter(BabyProfile.user_id == user_id).all()
        
        if not profiles:
            db.close()
            return 0

        for profile in profiles:
            profile.head_camera_ip = None
            profile.static_camera_ip = None
            profile.head_camera_on = False
            profile.static_camera_on = False

        db.commit()
        db.close()
        return len(profiles)  # נחזיר כמה פרופילים עודכנו

camera_manager = CameraConnectionManager()