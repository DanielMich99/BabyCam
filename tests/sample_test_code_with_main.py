
# Sample Test Code for User Stories

import requests
import sys

# -------------------------------
# User Account Management
# -------------------------------

def test_register_user():
    url = "http://localhost:8000/auth/register"
    data = {"username": "test123", "email": "test123@example.com", "password": "test123"}
    response = requests.post(url, json=data)
    print(response)
    assert response.status_code == 201

def test_login_logout_user():
    login_url = "http://localhost:8000/auth/login"
    logout_url = "http://localhost:8000/auth/logout"
    credentials = {"username": "test123", "password": "test123"}
    login_res = requests.post(login_url, json=credentials)
    print(login_res.json())
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    logout_res = requests.post(logout_url, json={"baby_profile_ids": [], "fcm_token": "mock_token"}, headers=headers)
    print(logout_res.json())
    assert logout_res.status_code == 200

def test_delete_account():
    login_url = "http://localhost:8000/auth/login"
    login_credentials = {"username": "test123", "password": "test123"}
    login_res = requests.post(login_url, json=login_credentials)
    print(login_res.json())
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    url = "http://localhost:8000/user/delete"
    headers = {"Authorization": f"Bearer {token}"}
    res = requests.delete(url, headers=headers)
    assert res.status_code == 200

# def test_update_account():
#     token = "your_jwt_here"
#     url = "http://localhost:8000/user/update"
#     headers = {"Authorization": f"Bearer {token}"}
#     data = {"email": "updated@example.com"}
#     res = requests.put(url, headers=headers, json=data)
#     assert res.status_code == 200

# -------------------------------
# Baby Profiles Management
# -------------------------------

def test_create_baby_profile():
    login_url = "http://localhost:8000/auth/login"
    login_credentials = {"username": "test123", "password": "test123"}
    login_res = requests.post(login_url, json=login_credentials)
    print(login_res.json())
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    url = "http://localhost:8000/baby_profiles/"
    headers = {"Authorization": f"Bearer {token}"}
    data = {"name": "baby"}
    res = requests.post(url, headers=headers, json=data)
    print(res.json())
    assert res.status_code == 200

# -------------------------------
# Model Training & Class Management
# -------------------------------

# def test_upload_training_data():
#     token = "your_jwt_here"
#     url = "http://localhost:8000/upload/to-temp"
#     headers = {"Authorization": f"Bearer {token}"}
#     files = {
#         "file": ("test.jpg", open("test.jpg", "rb"), "image/jpeg"),
#         "baby_profile_id": (None, "1"),
#         "class_name": (None, "knife"),
#         "camera_type": (None, "head_camera"),
#     }
#     res = requests.post(url, headers=headers, files=files)
#     assert res.status_code == 201

# def test_start_model_training():
#     token = "your_jwt_here"
#     url = "http://localhost:8000/model/update"
#     headers = {"Authorization": f"Bearer {token}"}
#     payload = {
#         "baby_profile_id": 1,
#         "model_type": "head_camera",
#         "new_classes": [],
#         "updated_classes": [],
#         "deleted_classes": []
#     }
#     res = requests.post(url, headers=headers, json=payload)
#     assert res.status_code == 200

# -------------------------------
# Detection System & Camera
# -------------------------------

# def test_start_detection():
#     token = "your_jwt_here"
#     url = "http://localhost:8000/detection/start"
#     headers = {"Authorization": f"Bearer {token}"}
#     data = {"baby_profile_id": 1, "camera_type": "head_camera"}
#     res = requests.post(url, headers=headers, json=data)
#     assert res.status_code == 200

# def test_stop_detection():
#     token = "your_jwt_here"
#     url = "http://localhost:8000/detection/stop"
#     headers = {"Authorization": f"Bearer {token}"}
#     data = {"baby_profile_id": 1, "camera_type": "head_camera"}
#     res = requests.post(url, headers=headers, json=data)
#     assert res.status_code == 200

# def test_receive_alert():
#     import websocket
#     def on_message(ws, message):
#         print(f"ALERT: {message}")
#         ws.close()

#     ws = websocket.WebSocketApp("ws://localhost:8000/ws/alerts/1/head_camera", on_message=on_message)
#     ws.run_forever()

# -------------------------------
# Alert History
# -------------------------------

def test_alert_history():
    login_url = "http://localhost:8000/auth/login"
    login_credentials = {"username": "test123", "password": "test123"}
    login_res = requests.post(login_url, json=login_credentials)
    print(login_res.json())
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    url = f"http://localhost:8000/detection_results/my"
    headers = {"Authorization": f"Bearer {token}"}
    res = requests.get(url, headers=headers)
    assert res.status_code == 200
    assert isinstance(res.json(), list)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python sample_test_code_with_main.py <test_function_name>")
    else:
        test_name = sys.argv[1]
        try:
            globals()[test_name]()
            print(f"{test_name} PASSED")
        except AssertionError:
            print(f"{test_name} FAILED")
        except Exception as e:
            print(f"{test_name} ERROR: {e}")
