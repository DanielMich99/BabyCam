from pydantic import BaseModel
from typing import List, Literal

class CameraTuple(BaseModel):
    baby_profile_id: int
    camera_type: Literal["head_camera", "static_camera"]

class StartMonitoringRequest(BaseModel):
    camera_profiles: List[CameraTuple]