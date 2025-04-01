from fastapi import HTTPException
from app.services.baby_profile_service import fetch_profiles
from app.services.dangerous_objects_service import get_dangerous_objects_from_ai

def get_recommended_dangers(user_id: str, profile_id: int):
    """שולח תכונות של תינוק למנוע AI ומקבל חפצים מסוכנים מותאמים אישית"""
    profiles = fetch_profiles(user_id)
    profile = next((p for p in profiles if p["profile_id"] == profile_id), None)
    
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    # שליחת פרטי התינוק כפרומפט ל-AI
    dangerous_objects = get_dangerous_objects_from_ai(profile)

    return {"recommended_dangerous_objects": dangerous_objects}
