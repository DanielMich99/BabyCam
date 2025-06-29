from sqlalchemy.orm import Session

from app.models.user_model import User
from app.schemas.auth_schemas import LoginRequest, RegisterRequest, LogoutRequest
from app.services.auth_service import (
    register_user as auth_register_user,
    authenticate_user,
    add_fcm_token_to_user,
    delete_fcm_token,
    refresh_access_token as refresh_access_token_service,
    process_logout
)

from fastapi import Request


# Register a new user (delegates to auth service)
def register_user(db: Session, register_data: RegisterRequest):
    return auth_register_user(db, register_data)


# Authenticate user and return access token if credentials are valid
def login_user(login_data: LoginRequest, db: Session):
    return authenticate_user(db, login_data.username, login_data.password)


# Refresh a JWT access token using a refresh token
def refresh_access_token(refresh_token: str):
    return refresh_access_token_service(refresh_token)


# Save the user's FCM token for push notifications
def save_fcm_token(token: str, db: Session, current_user: User):
    username = current_user.username
    return add_fcm_token_to_user(db, username, token)


# Delete the user's FCM token
def delete_fcm_token_controller(token: str, db: Session, current_user: User):
    return delete_fcm_token(token, db, current_user)

async def logout_user_controller(db: Session, user: User, data: LogoutRequest, request: Request):
    return await process_logout(db, user, data.baby_profile_ids, data.fcm_token, request)
