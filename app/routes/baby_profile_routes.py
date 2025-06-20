from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database.database import get_db
from app.controllers import baby_profile_controller
from app.models.user_model import User
from app.schemas import baby_profile_schema
from app.services.auth_service import get_current_user


router = APIRouter(prefix="/baby_profiles", tags=["Baby Profiles"])


# Create a new baby profile (user_id is taken from the authenticated token)
@router.post("/", response_model=baby_profile_schema.BabyProfileOut)
def create_baby_profile(
    profile: baby_profile_schema.BabyProfileCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile.user_id = current_user.id
    return baby_profile_controller.create_baby_profile_controller(db, profile)


# Get all baby profiles belonging to the authenticated user
@router.get("/my_profiles", response_model=list[baby_profile_schema.BabyProfileOut])
def get_my_baby_profiles(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return baby_profile_controller.get_baby_profiles_by_user_controller(db, current_user.id)


# Get a specific baby profile by ID (must belong to the authenticated user)
@router.get("/{profile_id}", response_model=baby_profile_schema.BabyProfileOut)
def get_baby_profile(
    profile_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return baby_profile_controller.get_baby_profile_by_user_controller(db, profile_id, current_user.id)


# Update an existing baby profile (must belong to the authenticated user)
@router.put("/{profile_id}", response_model=baby_profile_schema.BabyProfileOut)
def update_baby_profile(
    profile_id: int,
    profile_update: baby_profile_schema.BabyProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return baby_profile_controller.update_baby_profile_by_user_controller(db, profile_id, current_user.id, profile_update)


# Delete a baby profile (must belong to the authenticated user)
@router.delete("/{profile_id}", response_model=baby_profile_schema.BabyProfileOut)
def delete_baby_profile(
    profile_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return baby_profile_controller.delete_baby_profile_by_user_controller(db, profile_id, current_user.id)
