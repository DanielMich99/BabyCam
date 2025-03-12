from fastapi.testclient import TestClient
import io
from main import app

client = TestClient(app)

def get_auth_headers():
    """מבצע התחברות ומחזיר טוקן Authorization"""
    register_data = {
        "username": "testuser",
        "password": "123456",
        "email": "test@email.com"
    }
    login_data = {
        "username": "testuser",
        "password": "123456"
    }

    client.post("/auth/register", params=register_data)  # שים לב ל-data
    response = client.post("/auth/login", data=login_data)  # שים לב ל-data

    print(response.json())  # debug
    assert response.status_code == 200
    access_token = response.json().get("access_token")
    return {"Authorization": f"Bearer {access_token}"}

def test_upload_valid_file():
    headers = get_auth_headers()
    file_data = io.BytesIO(b"dummy image data")
    response = client.post("/files/upload/testuser", files={"file": ("test_image.jpg", file_data, "image/jpeg")}, headers=headers)

    print(response.json())  # debug
    assert response.status_code == 200
    assert "filename" in response.json()
    assert response.json()["message"] == "File uploaded successfully!"

def test_upload_invalid_file_type():
    headers = get_auth_headers()
    file_data = io.BytesIO(b"dummy text data")
    response = client.post("/files/upload/testuser", files={"file": ("test.txt", file_data, "text/plain")}, headers=headers)

    print(response.json())  # debug
    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid file type. Only images are allowed."

def test_upload_empty_file():
    headers = get_auth_headers()
    file_data = io.BytesIO(b"")
    response = client.post("/files/upload/testuser", files={"file": ("empty.jpg", file_data, "image/jpeg")}, headers=headers)

    print(response.json())  # debug
    assert response.status_code == 400
    assert response.json()["detail"] == "Uploaded file is empty"
