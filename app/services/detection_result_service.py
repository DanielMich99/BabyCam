from sqlalchemy.orm import Session
from app.models.detection_result_model import DetectionResult
from app.models.baby_profile_model import BabyProfile
from app.schemas import detection_result_schema

# יצירה (השרת בלבד)
def create_detection_result(db: Session, data: detection_result_schema.DetectionResultCreate):
    db_result = DetectionResult(**data.dict())
    db.add(db_result)
    db.commit()
    db.refresh(db_result)
    return db_result

# שליפה של כל ההיסטוריה של משתמש
def get_all_detection_results_by_user(db: Session, user_id: int):
    return db.query(DetectionResult).join(BabyProfile).filter(BabyProfile.user_id == user_id).all()

# שליפה לפי משתמש + פרופיל תינוק + סוג מצלמה
def get_detection_results_by_filters(db: Session, user_id: int, baby_profile_id: int, camera_type: str):
    return db.query(DetectionResult).join(BabyProfile).filter(
        BabyProfile.user_id == user_id,
        DetectionResult.baby_profile_id == baby_profile_id,
        DetectionResult.camera_type == camera_type
    ).all()

# שליפה בודדת (מאובטח)
def get_detection_result_by_user(db: Session, detection_id: int, user_id: int):
    return db.query(DetectionResult).join(BabyProfile).filter(
        DetectionResult.id == detection_id,
        BabyProfile.user_id == user_id
    ).first()

# מחיקה (מאובטח)
def delete_detection_result_by_user(db: Session, detection_id: int, user_id: int):
    db_result = get_detection_result_by_user(db, detection_id, user_id)
    if db_result is None:
        return None

    db.delete(db_result)
    db.commit()
    return db_result
