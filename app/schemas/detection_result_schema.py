from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class DetectionResultBase(BaseModel):
    baby_profile_id: int
    class_id: int
    class_name: str
    confidence: float
    camera_type: str
    timestamp: Optional[datetime] = None

class DetectionResultCreate(DetectionResultBase):
    pass

class DetectionResultUpdate(BaseModel):
    class_id: Optional[int] = None
    class_name: Optional[str] = None
    confidence: Optional[float] = None
    camera_type: Optional[str] = None
    timestamp: Optional[datetime] = None

class DetectionResultOut(BaseModel):
    id: int
    baby_profile_id: int
    baby_profile_name: str
    class_id: int
    class_name: str
    confidence: float
    camera_type: str
    timestamp: datetime
    risk_level: Optional[str]

    class Config:
        from_attrributes = True
