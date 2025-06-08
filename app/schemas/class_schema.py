from pydantic import BaseModel
from typing import Optional
from enum import Enum

class RiskLevelEnum(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"

class ClassResponse(BaseModel):
    id: int
    name: str
    risk_level: RiskLevelEnum
    model_index: Optional[int]
    camera_type: str
    baby_profile_id: int

    class Config:
        from_attributes = True