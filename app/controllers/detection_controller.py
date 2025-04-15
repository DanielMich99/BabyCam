from fastapi import HTTPException
from app.services.detection_service import detect_objects, get_last_detection_results
from app.services.baby_profile_service import fetch_profiles
from app.services.dangerous_objects_service import get_dangerous_objects_from_ai
from app.services.alert_service import save_alert

def process_detection(user_id: str):
    """מריץ זיהוי על התמונה האחרונה שנשמרה למשתמש"""
    detected_objects = detect_objects(user_id)
    
    if not detected_objects:
        raise HTTPException(status_code=404, detail="No objects detected")

    # הבאת פרופיל התינוק של המשתמש
    profiles = fetch_profiles(user_id)
    if not profiles:
        raise HTTPException(status_code=404, detail="No baby profile found")

    profile = profiles[0]  # כרגע מניחים שהמשתמש עובד עם פרופיל אחד

    # קבלת חפצים מסוכנים מומלצים מה-AI על פי מאפייני התינוק
    dangerous_objects = get_dangerous_objects_from_ai(profile)

    # בדיקת התאמה בין מה שזוהה לבין החפצים המסוכנים
    detected_dangerous = [obj for obj in detected_objects if obj in dangerous_objects]

    if detected_dangerous:
        save_alert(user_id, "Danger", f"Detected dangerous objects: {', '.join(detected_dangerous)}")

    return {"detected_objects": detected_objects, "dangerous_objects": detected_dangerous}

def get_last_detection(user_id: str):
    """מחזיר את תוצאות הזיהוי האחרונות של המשתמש"""
    return get_last_detection_results(user_id)
