from sqlalchemy.orm import Session
from typing import List

from app.services.class_suggestion_service import suggest_classes_for_baby_profile

# Returns a list of suggested class names (strings) for a given baby profile and camera type.
# Suggestions are generated based on AI.
def get_suggested_classes_controller(
    db: Session, user_id: int, baby_profile_id: int, camera_type: str
) -> List[str]:
    return suggest_classes_for_baby_profile(db, user_id, baby_profile_id, camera_type)