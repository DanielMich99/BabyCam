from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.controllers.auth_controller import (
    register_user,
    login_user,
    refresh_access_token,
    save_fcm_token,
    delete_fcm_token_controller
)
from database.database import get_db
from app.schemas.auth_schemas import RegisterRequest, LoginRequest, FCMTokenRequest
from app.services.auth_service import get_current_user


router = APIRouter()


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(register_data: RegisterRequest, db: Session = Depends(get_db)):
    """
    Register a new user with username, email, and password.
    Returns the created user or authentication token.
    """
    return register_user(db, register_data)


@router.post("/login")
def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """
    Authenticate a user and return a JWT access token if successful.
    """
    return login_user(login_data, db)


@router.post("/refresh")
def refresh_token(refresh_token: str):
    """
    Refresh an expired access token using a valid refresh token.
    """
    return refresh_access_token(refresh_token)


@router.post("/save-fcm-token", status_code=status.HTTP_201_CREATED)
def set_fcm_token(
    token_request: FCMTokenRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Save the user's FCM device token for push notifications.
    """
    return save_fcm_token(token_request.token, db, current_user)


@router.post("/remove-fcm-token", status_code=status.HTTP_204_NO_CONTENT)
def remove_fcm_token(
    token_request: FCMTokenRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Remove the user's FCM device token from the database.
    """
    return delete_fcm_token_controller(token_request.token, db, current_user)
