from fastapi import Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.services.auth_service import (
    register_user as auth_register_user,
    create_refresh_token,
    authenticate_user,
)
from app.schemas.auth_schemas import LoginRequest

def register_user(db: Session, username: str, password: str, email: str):
    return auth_register_user(db, username, password, email)

def login_user(login_data: LoginRequest, db: Session):
    return authenticate_user(db, login_data.username, login_data.password)

def refresh_access_token(refresh_token: str):
    return create_refresh_token(refresh_token)
