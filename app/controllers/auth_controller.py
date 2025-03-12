from fastapi import HTTPException, Depends, status
from fastapi.security import OAuth2PasswordRequestForm
from app.services.auth_service import register_user as auth_register_user, create_access_token, create_refresh_token, authenticate_user

def register_user(username: str, password: str, email: str):
    return auth_register_user(username, password, email)

def login_user(form_data: OAuth2PasswordRequestForm = Depends()):
    return authenticate_user(form_data.username, form_data.password)

def refresh_access_token(refresh_token: str):
    return create_refresh_token(refresh_token)
