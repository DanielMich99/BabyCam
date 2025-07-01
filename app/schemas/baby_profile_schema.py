from pydantic import BaseModel
from typing import Optional, Dict
from datetime import datetime


class BabyProfileBase(BaseModel):
    """Base schema shared by create, update and output schemas for baby profiles."""

    user_id: Optional[int] = None  # ID of the user who owns the profile
    name: str  # Baby's name (required)
    age: Optional[int] = None  # Baby's age in months
    gender: Optional[str] = None  # 'male', 'female', or 'other'
    weight: Optional[int] = None  # Baby's weight in kilograms
    height: Optional[int] = None  # Baby's height in centimeters
    medical_condition: Optional[str] = None  # Any known medical condition
    profile_picture: Optional[str] = None  # URL or path to profile picture

    # Class name → risk level mappings for each camera type
    head_camera_model_classes: Optional[Dict] = None
    static_camera_model_classes: Optional[Dict] = None

    # Camera IPs
    head_camera_ip: Optional[str] = None
    static_camera_ip: Optional[str] = None

    # Whether each camera is currently connected
    head_camera_on: Optional[bool] = False
    static_camera_on: Optional[bool] = False

    # When the model for each camera type was last updated
    head_camera_model_last_updated_time: Optional[datetime] = None
    static_camera_model_last_updated_time: Optional[datetime] = None

    # Whether detection is currently active for each camera
    head_camera_in_detection_system_on: Optional[bool] = False
    static_camera_in_detection_system_on: Optional[bool] = False


class BabyProfileCreate(BabyProfileBase):
    """Schema for creating a new baby profile (inherits all fields from base)."""
    pass


class BabyProfileUpdate(BaseModel):
    """Schema for updating an existing baby profile. All fields are optional except name."""

    name: str  # Baby's name is required when updating
    age: Optional[int] = None
    gender: Optional[str] = None
    weight: Optional[int] = None
    height: Optional[int] = None
    medical_condition: Optional[str] = None
    profile_picture: Optional[str] = None
    head_camera_model_classes: Optional[Dict] = None
    static_camera_model_classes: Optional[Dict] = None
    head_camera_ip: Optional[str] = None
    static_camera_ip: Optional[str] = None
    head_camera_on: Optional[bool] = None
    static_camera_on: Optional[bool] = None
    head_camera_model_last_updated_time: Optional[datetime] = None
    static_camera_model_last_updated_time: Optional[datetime] = None
    head_camera_in_detection_system_on: Optional[bool] = None
    static_camera_in_detection_system_on: Optional[bool] = None


class BabyProfileOut(BabyProfileBase):
    """Schema for returning baby profile data to the client (includes ID)."""

    id: int  # Unique ID of the baby profile

    class Config:
        from_attributes = True  # Enables loading from ORM objects (e.g., SQLAlchemy)
