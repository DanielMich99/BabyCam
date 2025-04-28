import os
import shutil
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.baby_profile_model import BabyProfile
from app.utils.config import config

# ✅ **1. שמירת פרופיל חדש (כולל אופציה לתמונה)**
def save_profile(db: Session, user_id: int, name: str, age: int, height: int, sensitivity: str, medical_condition: str, profile_picture: str = None):
    new_profile = BabyProfile(
        user_id=user_id,
        name=name,
        age=age,
        height=height,
        sensitivity=sensitivity,
        medical_condition=medical_condition,
        profile_picture=profile_picture
    )
    db.add(new_profile)
    db.commit()
    db.refresh(new_profile)
    return new_profile

# ✅ **2. שליפת פרופילים לפי user_id**
def fetch_profiles(db: Session, user_id: int):
    return db.query(BabyProfile).filter(BabyProfile.user_id == user_id).all()

# ✅ **3. עדכון פרופיל קיים**
def modify_profile(db: Session, profile_id: int, name: str, age: int, height: int, sensitivity: str, medical_condition: str):
    profile = db.query(BabyProfile).filter(BabyProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    profile.name = name
    profile.age = age
    profile.height = height
    profile.sensitivity = sensitivity
    profile.medical_condition = medical_condition

    db.commit()
    db.refresh(profile)
    return profile

# ✅ **4. מחיקת פרופיל**
def remove_profile(db: Session, profile_id: int):
    profile = db.query(BabyProfile).filter(BabyProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    db.delete(profile)
    db.commit()
    return {"message": "Profile deleted successfully"}

# ✅ **5. שמירת תמונת פרופיל**
def save_profile_picture(db: Session, user_id: int, profile_id: int, file):
    user_dir = os.path.join(config.UPLOAD_DIR, str(user_id))
    os.makedirs(user_dir, exist_ok=True)

    file_extension = os.path.splitext(file.filename)[1]
    new_filename = f"profile_{profile_id}{file_extension}"
    file_path = os.path.join(user_dir, new_filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    profile = db.query(BabyProfile).filter(BabyProfile.id == profile_id, BabyProfile.user_id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    profile.profile_picture = file_path
    db.commit()
    db.refresh(profile)
    return file_path

# ✅ **6. עדכון רשימת חפצים מסוכנים**
def update_profile_dangerous_objects_ai(db: Session, profile_id: int, dangerous_objects_AI: list):
    profile = db.query(BabyProfile).filter(BabyProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    profile.dangerous_objects_AI = dangerous_objects_AI
    db.commit()
    db.refresh(profile)
    return {"message": "Dangerous objects updated successfully"}

# ✅ **7. שליפת רשימת חפצים מסוכנים**
def get_profile_dangerous_objects_ai(db: Session, profile_id: int):
    profile = db.query(BabyProfile).filter(BabyProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    return profile.dangerous_objects_AI or []

def update_profile_dangerous_objects_static(db: Session, profile_id: int, dangerous_objects_static: list):
    profile = db.query(BabyProfile).filter(BabyProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    profile.dangerous_objects_static = dangerous_objects_static
    db.commit()
    db.refresh(profile)
    return {"message": "Dangerous objects updated successfully"}

def get_profile_dangerous_objects_static(db: Session, profile_id: int):
    profile = db.query(BabyProfile).filter(BabyProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    return profile.dangerous_objects_static or []