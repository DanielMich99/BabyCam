from datetime import datetime
from pydantic import BaseModel
from typing import Optional


class DetectionResultBase(BaseModel):
    """Base schema for detection result records, used for create and internal processing."""

    baby_profile_id: int  # ID of the baby profile this detection is related to
    class_id: int  # ID of the detected object class
    class_name: str  # Name of the detected object class (e.g., "knife", "scissors")
    confidence: float  # Confidence score from the detection model (0.0 - 1.0)
    camera_type: str  # Either "head_camera" or "static_camera"
    timestamp: Optional[datetime] = None  # When the detection occurred (defaults to now if not provided)


class DetectionResultCreate(DetectionResultBase):
    """Schema for creating a new detection result (inherits all fields from base)."""
    pass


class DetectionResultUpdate(BaseModel):
    """Schema for updating an existing detection result. All fields are optional."""

    class_id: Optional[int] = None  # Updated class ID
    class_name: Optional[str] = None  # Updated class name
    confidence: Optional[float] = None  # Updated confidence score
    camera_type: Optional[str] = None  # Updated camera type
    timestamp: Optional[datetime] = None  # Updated timestamp


class DetectionResultOut(BaseModel):
    """Schema for returning detection result data to the client."""

    id: int  # Unique ID of the detection result
    baby_profile_id: int  # ID of the baby profile associated with this detection
    baby_profile_name: str  # Name of the baby profile (joined from related model)
    class_id: int  # ID of the detected object class
    class_name: str  # Name of the detected object class
    confidence: float  # Detection confidence score
    camera_type: str  # Type of camera that captured the detection
    timestamp: datetime  # Timestamp of the detection
    risk_level: Optional[str]  # Risk level associated with the class (e.g., "high", "medium", "low")
    image_path: Optional[str]  # Path to the image/frame where detection occurred

    class Config:
        from_attributes = True  # Allow loading data from ORM objects (e.g., SQLAlchemy models)
