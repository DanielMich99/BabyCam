import os
import shutil
from sqlalchemy.orm import Session

from app.models.baby_profile_model import BabyProfile
from app.models.class_model import ClassObject
from app.models.detection_result_model import DetectionResult
from app.schemas import baby_profile_schema
from app.utils.google_drive_service import GoogleDriveService


# Create a new baby profile in the database
def create_baby_profile(db: Session, profile: baby_profile_schema.BabyProfileCreate):
    db_profile = BabyProfile(**profile.dict())
    db.add(db_profile)
    db.commit()
    db.refresh(db_profile)
    return db_profile


# Get all baby profiles (may be used for admin in the future)
def get_all_baby_profiles(db: Session):
    return db.query(BabyProfile).all()


# Get all baby profiles associated with a specific user (secured)
def get_baby_profiles_by_user_id(db: Session, user_id: int):
    return db.query(BabyProfile).filter(BabyProfile.user_id == user_id).all()


# Get a single baby profile by its ID and user ID (secured)
def get_baby_profile_by_user(db: Session, profile_id: int, user_id: int):
    return db.query(BabyProfile).filter(
        BabyProfile.id == profile_id,
        BabyProfile.user_id == user_id
    ).first()


# Update an existing baby profile by ID and user ID (secured)
def update_baby_profile_by_user(db: Session, profile_id: int, user_id: int, profile_update: baby_profile_schema.BabyProfileUpdate):
    db_profile = get_baby_profile_by_user(db, profile_id, user_id)
    if db_profile is None:
        return None

    update_data = profile_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_profile, key, value)

    db.commit()
    db.refresh(db_profile)
    return db_profile


# Delete a baby profile and all its related records and folders (secured)
def delete_baby_profile_by_user(db: Session, profile_id: int, user_id: int):
    db_profile = get_baby_profile_by_user(db, profile_id, user_id)
    if db_profile is None:
        return None

    db.delete(db_profile)

    # Delete all related class definitions
    db_classes = db.query(ClassObject).filter(ClassObject.baby_profile_id == profile_id).all()
    for item in db_classes:
        db.delete(item)

    # Delete all related detection results
    db_detection_results = db.query(DetectionResult).filter(DetectionResult.baby_profile_id == profile_id).all()
    for item in db_detection_results:
        db.delete(item)

    db.commit()

    # Delete local folders for detections and training data
    detections_path = os.path.join("uploads", "detections", str(profile_id))
    if os.path.exists(detections_path):
        shutil.rmtree(detections_path)

    training_data_path = os.path.join("uploads", "training_data", str(profile_id))
    if os.path.exists(training_data_path):
        shutil.rmtree(training_data_path)

    # Delete corresponding Google Drive folder
    drive_service = GoogleDriveService()
    drive_service.delete_baby_profile_folder(profile_id)

    return db_profile
