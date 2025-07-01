from datetime import datetime
from pydantic import BaseModel
from typing import Optional, Dict, List


class DetectionResultBase(BaseModel):
    """Base schema for detection result records, used for creation and internal processing."""

    baby_profile_id: int  # ID of the baby profile this detection is related to
    class_id: int  # ID of the detected object class
    class_name: str  # Name of the detected object class (e.g., "knife", "scissors")
    confidence: float  # Confidence score from the detection model (range: 0.0 to 1.0)
    camera_type: str  # Camera source: "head_camera" or "static_camera"
    timestamp: Optional[datetime] = None  # When the detection occurred (optional)


class DetectionResultCreate(DetectionResultBase):
    """Schema for creating a new detection result entry (inherits all fields from base)."""
    pass


class DetectionResultUpdate(BaseModel):
    """Schema for updating an existing detection result. All fields are optional."""

    class_id: Optional[int] = None  # New class ID, if updating
    class_name: Optional[str] = None  # New class name, if updating
    confidence: Optional[float] = None  # New confidence score
    camera_type: Optional[str] = None  # New camera type
    timestamp: Optional[datetime] = None  # New timestamp


class BatchDeleteRequest(BaseModel):
    """Schema for deleting multiple detection results grouped by baby profile."""
    alerts_by_baby: Dict[str, List[int]]  # e.g., {"Tom": [12, 13], "Luna": [5, 6]}


class DetectionResultOut(BaseModel):
    """Schema for returning detection result data to the client."""

    id: int  # Unique ID of the detection result
    baby_profile_id: int  # ID of the baby profile linked to the detection
    baby_profile_name: str  # Name of the baby (joined from DB)
    class_id: int  # ID of the detected class
    class_name: str  # Name of the detected object
    confidence: float  # Confidence score from the model
    camera_type: str  # Camera type: "head_camera" or "static_camera"
    timestamp: datetime  # When the detection occurred
    risk_level: Optional[str]  # Risk level of the class (e.g., "high")
    image_path: Optional[str]  # Path to image saved for this detection

    class Config:
        from_attributes = True  # Enable loading data from ORM objects (e.g., SQLAlchemy)
