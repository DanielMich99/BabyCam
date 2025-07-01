from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.schemas import baby_profile_schema
from app.services import baby_profile_service


# Creates a new baby profile in the database
def create_baby_profile_controller(db: Session, profile: baby_profile_schema.BabyProfileCreate):
    return baby_profile_service.create_baby_profile(db, profile)


# Retrieves all baby profiles that belong to the specified user
def get_baby_profiles_by_user_controller(db: Session, user_id: int):
    return baby_profile_service.get_baby_profiles_by_user_id(db, user_id)


# Retrieves a single baby profile by profile ID and user ID (authorization enforced)
def get_baby_profile_by_user_controller(db: Session, profile_id: int, user_id: int):
    profile = baby_profile_service.get_baby_profile_by_user(db, profile_id, user_id)
    if profile is None:
        # If the profile does not exist or does not belong to the user, return 404
        raise HTTPException(status_code=404, detail="Baby profile not found or unauthorized")
    return profile


# Updates a baby profile by its ID and user ID (authorization enforced)
def update_baby_profile_by_user_controller(db: Session, profile_id: int, user_id: int, profile_update: baby_profile_schema.BabyProfileUpdate):
    profile = baby_profile_service.update_baby_profile_by_user(db, profile_id, user_id, profile_update)
    if profile is None:
        # If the profile does not exist or does not belong to the user, return 404
        raise HTTPException(status_code=404, detail="Baby profile not found or unauthorized")
    return profile


# Deletes a baby profile by its ID and user ID (authorization enforced)
def delete_baby_profile_by_user_controller(db: Session, profile_id: int, user_id: int):
    profile = baby_profile_service.delete_baby_profile_by_user(db, profile_id, user_id)
    if profile is None:
        # If the profile does not exist or does not belong to the user, return 404
        raise HTTPException(status_code=404, detail="Baby profile not found or unauthorized")
    return profile