from sqlalchemy.orm import Session
from app.models.user_model import User
from app.schemas import user_schema
from app.utils.hashing import hash_password
from app.models.baby_profile_model import BabyProfile
from app.services.baby_profile_service import delete_baby_profile_by_user

# Create a new user in the database
def create_user(db: Session, user_data: user_schema.UserCreate):
    hashed_pw = hash_password(user_data.password)
    db_user = User(
        username=user_data.username,
        email=user_data.email,
        hashed_password=hashed_pw,
        already_logged_in=False
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# Get a user by their ID
def get_user_by_id(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

# Update user fields (supports optional password update with hashing)
def update_user(db: Session, user_id: int, update_data: user_schema.UserUpdate):
    db_user = db.query(User).filter(User.id == user_id).first()
    if db_user is None:
        return None

    update_dict = update_data.dict(exclude_unset=True)

    # Handle password hashing if provided
    if "password" in update_dict and update_dict["password"] is not None:
        update_dict["hashed_password"] = hash_password(update_dict.pop("password"))

    for key, value in update_dict.items():
        setattr(db_user, key, value)

    db.commit()
    db.refresh(db_user)
    return db_user

# Delete a user and all of their associated baby profiles
def delete_user(db: Session, user_id: int):
    db_user = db.query(User).filter(User.id == user_id).first()
    if db_user is None:
        return None

    # First delete all associated baby profiles
    db_baby_profiles = db.query(BabyProfile).filter(BabyProfile.user_id == user_id).all()
    for item in db_baby_profiles:
        delete_baby_profile_by_user(db, item.id, user_id)

    # Then delete the user itself
    db.delete(db_user)
    db.commit()
    return db_user
