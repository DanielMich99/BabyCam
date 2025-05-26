
import httpx
import time

def test_camera_connection_real_flow_against_server():
    baby_profile_id = 1
    camera_type = "head_camera"

    # החלף ל-IP של המחשב שמריץ את השרת
    url = "http://192.168.1.206:8000"

    print("🟡 שולח בקשת התחברות לשרת האמיתי...")
    def connect_request():
        return httpx.post(f"{url}/camera/connect", json={
            "baby_profile_id": baby_profile_id,
            "camera_type": camera_type
        }, timeout=70)

    print("🟢 עכשיו אפשר לחבר את המצלמה לחשמל (יש כ-60 שניות)")
    response = connect_request()

    assert response.status_code == 200, f"❌ התחברות נכשלה: {response.text}"
    assert response.json()["status"] == "connected"
    print("✅ מצלמה התחברה בהצלחה.")
