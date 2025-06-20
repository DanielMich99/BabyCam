from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.schemas import baby_profile_schema
from app.services import baby_profile_service


# Create a new baby profile
def create_baby_profile_controller(db: Session, profile: baby_profile_schema.BabyProfileCreate):
    return baby_profile_service.create_baby_profile(db, profile)


# Get all baby profiles for a given user
def get_baby_profiles_by_user_controller(db: Session, user_id: int):
    return baby_profile_service.get_baby_profiles_by_user_id(db, user_id)


# Get a specific baby profile by ID and user ID (secured)
def get_baby_profile_by_user_controller(db: Session, profile_id: int, user_id: int):
    profile = baby_profile_service.get_baby_profile_by_user(db, profile_id, user_id)
    if profile is None:
        raise HTTPException(status_code=404, detail="Baby profile not found or unauthorized")
    return profile


# Update a specific baby profile by ID and user ID (secured)
def update_baby_profile_by_user_controller(db: Session, profile_id: int, user_id: int, profile_update: baby_profile_schema.BabyProfileUpdate):
    profile = baby_profile_service.update_baby_profile_by_user(db, profile_id, user_id, profile_update)
    if profile is None:
        raise HTTPException(status_code=404, detail="Baby profile not found or unauthorized")
    return profile


# Delete a specific baby profile by ID and user ID (secured)
def delete_baby_profile_by_user_controller(db: Session, profile_id: int, user_id: int):
    profile = baby_profile_service.delete_baby_profile_by_user(db, profile_id, user_id)
    if profile is None:
        raise HTTPException(status_code=404, detail="Baby profile not found or unauthorized")
    return profile
