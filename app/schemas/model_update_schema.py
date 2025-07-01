from typing import List
from pydantic import BaseModel, Field

# Represents a list of filenames associated with a class: image files and label files
class FileList(BaseModel):
    images: List[str]  # List of image filenames
    labels: List[str]  # List of label filenames (YOLO format)

# Represents a single object class being added or updated in the model
class ClassItem(BaseModel):
    name: str  # Name of the class (e.g., "knife")
    risk_level: str  # Risk level for the class: "high", "medium", or "low"
    files: FileList  # Associated files for the class (images + labels)

# Schema for a model update request, including class additions, updates, and deletions
class ModelUpdateRequest(BaseModel):
    baby_profile_id: int  # ID of the baby profile whose model is being updated
    model_type: str  # Type of model: "head_camera_model" or "static_camera_model"
    new_classes: List[ClassItem]  # List of classes to be added
    updated_classes: List[ClassItem]  # List of classes to be updated
    deleted_classes: List[str]  # List of class names to be removed
