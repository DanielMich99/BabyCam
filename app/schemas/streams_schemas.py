from pydantic import BaseModel
from typing import List

class StreamRequestItem(BaseModel):
    baby_profile_id: int
    model_type: str

class StreamRequest(BaseModel):
    streams: List[StreamRequestItem]

class StreamResponseItem(BaseModel):
    baby_profile_id: int
    model_type: str
    stream_url: str
