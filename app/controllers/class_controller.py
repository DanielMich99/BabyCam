from sqlalchemy.orm import Session
from typing import List
from app.services.class_service import get_classes_by_profile_and_camera
from app.schemas.class_schema import ClassResponse

# Retrieves all class objects associated with a specific baby profile and camera type,
# then converts them to response schema format.
def fetch_classes_by_profile_and_camera(
    db: Session, user_id: int, baby_profile_id: int, camera_type: str
) -> List[ClassResponse]:
    classes = get_classes_by_profile_and_camera(db, user_id, baby_profile_id, camera_type)
    return [ClassResponse.from_orm(cls) for cls in classes]
