from pydantic import BaseModel
from typing import List


class SuggestedClassesResponse(BaseModel):
    camera_type: str
    classes: List[str]