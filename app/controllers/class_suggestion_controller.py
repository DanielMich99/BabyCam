from sqlalchemy.orm import Session
from typing import List

from app.services.class_suggestion_service import suggest_classes_for_baby_profile


def get_suggested_classes_controller(
    db: Session, user_id: int, baby_profile_id: int, camera_type: str
) -> List[str]:
    return suggest_classes_for_baby_profile(db, user_id, baby_profile_id, camera_type)