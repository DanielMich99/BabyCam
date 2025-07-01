from pydantic import BaseModel, EmailStr
from typing import Optional

# Base schema shared between user-related schemas
class UserBase(BaseModel):
    username: str  # Username of the user
    email: EmailStr  # Validated email address


# Schema for creating a new user
class UserCreate(UserBase):
    username: str
    email: EmailStr
    password: str  # Plain-text password to be hashed and stored


# Schema for updating an existing user
class UserUpdate(BaseModel):
    username: Optional[str] = None  # Optional new username
    email: Optional[EmailStr] = None  # Optional new email
    password: Optional[str] = None  # Optional new password
    fcm_token: Optional[str] = None  # Optional new FCM token


# Schema for returning user data to the client
class UserOut(UserBase):
    id: int  # Unique ID of the user
    fcm_token: Optional[str] = None  # Most recent registered FCM token
    already_logged_in: Optional[bool] = None  # Indicates session state or onboarding status

    class Config:
        from_attributes = True  # Enables compatibility with ORM models like SQLAlchemy
