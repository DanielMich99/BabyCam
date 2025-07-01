from sqlalchemy.orm import Session
from typing import List
from fastapi import HTTPException
from app.models.class_model import ClassObject
from app.models.baby_profile_model import BabyProfile
from app.schemas.class_schema import ClassResponse

# Retrieve all object classes associated with a given baby profile and camera type.
# First verifies that the baby profile belongs to the authenticated user.
def get_classes_by_profile_and_camera(
    db: Session, user_id: int, baby_profile_id: int, camera_type: str
) -> List[ClassObject]:
    
    # Ensure the baby profile belongs to the user making the request
    profile = db.query(BabyProfile).filter_by(id=baby_profile_id, user_id=user_id).first()
    if not profile:
        raise HTTPException(status_code=403, detail="Access denied to baby profile")

    # Return all class entries for the specified baby profile and camera type
    return db.query(ClassObject).filter_by(
        baby_profile_id=baby_profile_id,
        camera_type=camera_type
    ).all()
