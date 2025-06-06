from pydantic import BaseModel
from typing import Optional, List, Dict

class BabyProfileBase(BaseModel):
    user_id: Optional[int] = None
    name: str
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

class BabyProfileCreate(BabyProfileBase):
    pass

class BabyProfileUpdate(BaseModel):
    name: str
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

class BabyProfileOut(BabyProfileBase):
    id: int

    class Config:
        from_attrributes = True
