from pydantic import BaseModel
from typing import List, Literal

# Represents a single baby profile and camera type pair to be monitored
class CameraTuple(BaseModel):
    baby_profile_id: int  # ID of the baby profile to monitor
    camera_type: Literal["head_camera", "static_camera"]  # Type of camera to monitor

# Request schema used to start or stop monitoring for one or more camera/profile pairs
class StartMonitoringRequest(BaseModel):
    camera_profiles: List[CameraTuple]  # List of baby profile and camera type pairs to activate
