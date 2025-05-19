from typing import List
from pydantic import BaseModel, Field

class FileList(BaseModel):
    images: List[str]
    labels: List[str]

class ClassItem(BaseModel):
    name: str
    risk_level: str  # "high", "medium", or "low"
    files: FileList

class ModelUpdateRequest(BaseModel):
    baby_profile_id: int
    model_type: str  # "head_camera_model" or "static_camera_model"
    new_classes: List[ClassItem]
    updated_classes: List[ClassItem]
    deleted_classes: List[str]
