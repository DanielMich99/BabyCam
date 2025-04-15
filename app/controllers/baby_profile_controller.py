from fastapi import HTTPException, File, UploadFile, Depends
from sqlalchemy.orm import Session
from app.services.baby_profile_service import save_profile, fetch_profiles, modify_profile, remove_profile, save_profile_picture, update_profile_dangerous_objects, get_profile_dangerous_objects
from database.database import get_db
from fastapi import Body

def create_profile(user_id: int, name: str, age: int, height: int, sensitivity: str,
                   medical_condition: str, profile_picture: str = None, db: Session = Depends(get_db)):
    success = save_profile(db, user_id, name, age, height, sensitivity, medical_condition, profile_picture)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to save profile")
    return {"message": "Profile created successfully"}

def get_profiles(user_id: str, db: Session = Depends(get_db)):
    """מציג את כל הפרופילים של המשתמש"""
    profiles = fetch_profiles(db, user_id)
    return {"profiles": profiles}

def update_profile(user_id: str, profile_id: int, name: str, age: int, height: int, sensitivity: str, medical_condition: str, db: Session = Depends(get_db)):
    """מעדכן פרטי פרופיל"""
    success = modify_profile(db, profile_id, name, age, height, sensitivity, medical_condition)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to update profile")
    return {"message": "Profile updated successfully"}

def delete_profile(user_id: str, profile_id: int, db: Session = Depends(get_db)):
    """מוחק פרופיל"""
    success = remove_profile(db, user_id, profile_id)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to delete profile")
    return {"message": "Profile deleted successfully"}

def upload_profile_picture(user_id: str, profile_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    """שומר תמונה עבור פרופיל של תינוק"""
    image_url = save_profile_picture(db, user_id, profile_id, file)
    if not image_url:
        raise HTTPException(status_code=500, detail="Failed to save profile picture")
    return {"message": "Profile picture uploaded successfully", "image_url": image_url}

def update_dangerous_objects(profile_id: int, dangerous_objects: list = Body(...), db: Session = Depends(get_db)):
    """מעדכן את רשימת החפצים המסוכנים בפרופיל של התינוק"""
    success = update_profile_dangerous_objects(db, profile_id, dangerous_objects)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to update dangerous objects")
    return {"message": "Dangerous objects updated successfully"}

def get_dangerous_objects(profile_id: int, db: Session = Depends(get_db)):
    """מחזיר את רשימת החפצים המסוכנים ששמורים כרגע בפרופיל התינוק"""
    dangerous_objects = get_profile_dangerous_objects(db, profile_id)
    if dangerous_objects is None:
        raise HTTPException(status_code=404, detail="Profile not found or no dangerous objects saved")
    return {"dangerous_objects": dangerous_objects}