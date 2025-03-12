import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_register():
    """בודק האם ניתן לרשום משתמש חדש בהצלחה"""
    response = client.post("/auth/register", params={
        "username": "testuser",
        "password": "123456",
        "email": "test@email.com"
    })
    print(response.json())  # debug
    assert response.status_code == 200
    assert response.json()["message"] == "User registered successfully"

def test_register_duplicate_user():
    """בודק שלא ניתן לרשום את אותו משתמש פעמיים"""
    client.post("/auth/register", params={  # שינוי ל-data
        "username": "testuser",
        "password": "123456",
        "email": "test@email.com"
    })
    response = client.post("/auth/register", params={
        "username": "testuser",
        "password": "123456",
        "email": "test@email.com"
    })
    print(response.json())  # debug
    assert response.status_code == 400
    assert response.json()["detail"] == "Username already exists"

def test_login():
    """בודק האם ניתן להתחבר עם משתמש קיים"""
    client.post("/auth/register", params={  # שינוי ל-data
        "username": "testuser",
        "password": "123456",
        "email": "test@email.com"
    })
    response = client.post("/auth/login", data={  # שינוי ל-data
        "username": "testuser",
        "password": "123456"
    })
    print(response.json())  # debug
    assert response.status_code == 200
    assert "access_token" in response.json()
