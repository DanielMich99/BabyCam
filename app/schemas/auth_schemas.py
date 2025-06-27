from pydantic import BaseModel, EmailStr
from typing import List


class RegisterRequest(BaseModel):
    """Request body schema for user registration."""

    username: str  # Desired username for the new account
    password: str  # Password for the new account
    email: EmailStr  # User's email address (validated format)


class LoginRequest(BaseModel):
    """Request body schema for user login."""

    username: str  # Username used to log in
    password: str  # User's password


class FCMTokenRequest(BaseModel):
    """Request schema for submitting an FCM device token."""

    token: str  # Firebase Cloud Messaging token for push notifications

class LogoutRequest(BaseModel):
    baby_profile_ids: List[int]
    fcm_token: str
