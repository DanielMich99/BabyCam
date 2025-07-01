from pydantic import BaseModel, EmailStr
from typing import List


class RegisterRequest(BaseModel):
    """Request body schema for user registration."""

    username: str  # Desired username for the new account
    password: str  # Password for the new account
    email: EmailStr  # User's email address (validated for correct format)


class LoginRequest(BaseModel):
    """Request body schema for user login."""

    username: str  # Username used to log in
    password: str  # Password associated with the account


class FCMTokenRequest(BaseModel):
    """Request schema for submitting an FCM device token."""

    token: str  # Firebase Cloud Messaging token used for sending push notifications to this user's device


class LogoutRequest(BaseModel):
    """Request schema for logging out the user."""

    baby_profile_ids: List[int]  # List of baby profile IDs to deactivate monitoring and clear camera IPs
    fcm_token: str  # FCM token to remove from the database
