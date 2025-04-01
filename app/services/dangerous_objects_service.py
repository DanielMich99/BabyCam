from sqlalchemy.orm import Session
from app.utils.ai_helper import get_ai_response
from app.models.baby_profile_model import BabyProfile
from fastapi import HTTPException

# ✅ **1. קבלת חפצים מסוכנים מ-AI ושמירתם ב-DB**
def get_dangerous_objects_from_ai(db: Session, profile_id: int):
    """יוצר פרומפט ל-AI ומקבל חפצים מסוכנים מותאמים אישית"""
    profile = db.query(BabyProfile).filter(BabyProfile.id == profile_id).first()
    
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    prompt = f"""
    תינוק בשם {profile.name} עם המאפיינים הבאים:
    - גיל: {profile.age} חודשים
    - גובה: {profile.height} ס"מ
    - רגישות מיוחדת: {profile.sensitivity}
    - מצב רפואי: {profile.medical_condition}

    מהם החפצים המסוכנים ביותר עבורו? החזר רשימה בלבד, ללא הסברים.
    """
    
    dangerous_objects = get_ai_response(prompt)
    
    # ✅ שמירת חפצים מסוכנים בפרופיל
    profile.dangerous_objects = dangerous_objects
    db.commit()
    db.refresh(profile)
    
    return dangerous_objects

# ✅ **2. שליפת חפצים מסוכנים מה-DB**
def get_profile_dangerous_objects(db: Session, profile_id: int):
    """מחזיר את רשימת החפצים המסוכנים של התינוק מה-DB"""
    profile = db.query(BabyProfile).filter(BabyProfile.id == profile_id).first()
    
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    return profile.dangerous_objects or []
