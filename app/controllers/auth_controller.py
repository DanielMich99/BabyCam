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


# Register a new user (delegates to the auth service function)
def register_user(db: Session, register_data: RegisterRequest):
    return auth_register_user(db, register_data)


# Login endpoint: verifies credentials and returns an access token
def login_user(login_data: LoginRequest, db: Session):
    return authenticate_user(db, login_data.username, login_data.password)


# Generates a new JWT access token using a valid refresh token
def refresh_access_token(refresh_token: str):
    return refresh_access_token_service(refresh_token)


# Stores the FCM token for the current user to enable push notifications
def save_fcm_token(token: str, db: Session, current_user: User):
    username = current_user.username
    return add_fcm_token_to_user(db, username, token)


# Removes the given FCM token from the user's record
def delete_fcm_token_controller(token: str, db: Session, current_user: User):
    return delete_fcm_token(token, db, current_user)


# Handles full logout process: - Verifies the request - Removes FCM token - Turns off cameras and stops monitoring if needed
async def logout_user_controller(db: Session, user: User, data: LogoutRequest, request: Request):
    return await process_logout(db, user, data.baby_profile_ids, data.fcm_token, request)