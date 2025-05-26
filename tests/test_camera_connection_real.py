import threading
from fastapi.testclient import TestClient
import sys
import os
import time

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/..")

from main import app
from database.database import SessionLocal
from app.models.baby_profile_model import BabyProfile

client = TestClient(app)

def test_camera_connection_real_flow():
    baby_profile_id = 1
    camera_type = "head_camera"
    response_container = {}

    def call_connect():
        response = client.post("/camera/connect", json={
            "baby_profile_id": baby_profile_id,
            "camera_type": camera_type
        })
        response_container["response"] = response

    print("🟡 שולח בקשת התחברות לשרת ברקע...")
    thread = threading.Thread(target=call_connect)
    thread.start()

    print("🟢 עכשיו אפשר לחבר את המצלמה לחשמל (יש כ-60 שניות להתחברות)")
    
    # ממתין שקריאת השרת תסתיים
    thread.join()

    response = response_container["response"]
    assert response.status_code == 200, f"❌ התחברות נכשלה: {response.text}"
    assert response.json()["status"] == "connected"

    db = SessionLocal()
    profile = db.query(BabyProfile).get(baby_profile_id)
    assert profile.head_camera_ip is not None
    print("✅ Camera connected with IP:", profile.head_camera_ip)
    db.close()
