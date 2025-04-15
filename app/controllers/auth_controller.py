from fastapi import Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.services.auth_service import (
    register_user as auth_register_user,
    create_refresh_token,
    authenticate_user,
)

def register_user(db: Session, username: str, password: str, email: str):
    return auth_register_user(db, username, password, email)

def login_user(form_data: OAuth2PasswordRequestForm, db: Session):
    return authenticate_user(db, form_data.username, form_data.password)

def refresh_access_token(refresh_token: str):
    return create_refresh_token(refresh_token)
