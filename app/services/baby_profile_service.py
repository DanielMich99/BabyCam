from sqlalchemy.orm import Session
from app.models.baby_profile_model import BabyProfile
from app.schemas import baby_profile_schema

# יצירה
def create_baby_profile(db: Session, profile: baby_profile_schema.BabyProfileCreate):
    db_profile = BabyProfile(**profile.dict())
    db.add(db_profile)
    db.commit()
    db.refresh(db_profile)
    return db_profile

# שליפה של כל הפרופילים (למנהל אולי בעתיד)
def get_all_baby_profiles(db: Session):
    return db.query(BabyProfile).all()

# שליפה לפי user_id - מאובטח
def get_baby_profiles_by_user_id(db: Session, user_id: int):
    return db.query(BabyProfile).filter(BabyProfile.user_id == user_id).all()

# שליפה של פרופיל יחיד לפי id ו-user_id - מאובטח
def get_baby_profile_by_user(db: Session, profile_id: int, user_id: int):
    return db.query(BabyProfile).filter(BabyProfile.id == profile_id, BabyProfile.user_id == user_id).first()

# עדכון - מאובטח
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

# מחיקה - מאובטח
def delete_baby_profile_by_user(db: Session, profile_id: int, user_id: int):
    db_profile = get_baby_profile_by_user(db, profile_id, user_id)
    if db_profile is None:
        return None

    db.delete(db_profile)
    db.commit()
    return db_profile