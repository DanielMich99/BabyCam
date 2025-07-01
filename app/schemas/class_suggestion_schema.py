from pydantic import BaseModel
from typing import List

# Response schema for suggested object classes based on a camera type.
# Used to suggest classes for a specific baby profile and camera type.
class SuggestedClassesResponse(BaseModel):
    camera_type: str  # 'head_camera' or 'static_camera'
    classes: List[str]  # List of suggested class names (strings)
