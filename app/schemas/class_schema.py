from pydantic import BaseModel
from typing import Optional
from enum import Enum

# Enum to define possible risk levels for a class
class RiskLevelEnum(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"

# Response schema used to return class details to the client
class ClassResponse(BaseModel):
    id: int  # Unique ID of the class
    name: str  # Name of the object class (e.g., "knife", "bottle")
    risk_level: RiskLevelEnum  # Risk level assigned to this class
    model_index: Optional[int]  # Index in the model's output layer (used internally)
    camera_type: str  # Type of camera: 'head_camera' or 'static_camera'
    baby_profile_id: int  # ID of the baby profile this class belongs to

    class Config:
        from_attributes = True  # Allows reading from ORM objects like SQLAlchemy models
