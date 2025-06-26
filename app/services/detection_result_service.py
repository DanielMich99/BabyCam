from sqlalchemy.orm import Session, joinedload
from app.models.detection_result_model import DetectionResult
from app.models.baby_profile_model import BabyProfile
from app.models.class_model import ClassObject
from app.schemas import detection_result_schema
import os
from fastapi import HTTPException

# יצירה (השרת בלבד)
def create_detection_result(db: Session, data: detection_result_schema.DetectionResultCreate):
    db_result = DetectionResult(**data.dict())
    db.add(db_result)
    db.commit()
    db.refresh(db_result)
    return db_result

# שליפה של כל ההיסטוריה של משתמש
def get_all_detection_results_by_user(db: Session, user_id: int):
    results = db.query(DetectionResult).join(BabyProfile).join(ClassObject).filter(
        BabyProfile.user_id == user_id
    ).options(
        joinedload(DetectionResult.baby_profile),
        joinedload(DetectionResult.class_)
    ).all()

    return [
        detection_result_schema.DetectionResultOut(
            id=result.id,
            baby_profile_id=result.baby_profile_id,
            baby_profile_name=result.baby_profile.name,
            class_id=result.class_id,
            class_name=result.class_name,
            confidence=result.confidence,
            camera_type=result.camera_type,
            timestamp=result.timestamp,
            risk_level=result.class_.risk_level,
            image_path=result.image_path
        )
        for result in results
    ]

# שליפה לפי משתמש + פרופיל תינוק + סוג מצלמה
def get_detection_results_by_filters(db: Session, user_id: int, baby_profile_id: int, camera_type: str):
    results = db.query(DetectionResult).join(BabyProfile).join(ClassObject).filter(
        BabyProfile.user_id == user_id,
        DetectionResult.baby_profile_id == baby_profile_id,
        DetectionResult.camera_type == camera_type
    ).options(
        joinedload(DetectionResult.baby_profile),
        joinedload(DetectionResult.class_)
    ).all()

    return [
        detection_result_schema.DetectionResultOut(
            id=result.id,
            baby_profile_id=result.baby_profile_id,
            baby_profile_name=result.baby_profile.name,
            class_id=result.class_id,
            class_name=result.class_name,
            confidence=result.confidence,
            camera_type=result.camera_type,
            timestamp=result.timestamp,
            risk_level=result.class_.risk_level,
            image_path=result.image_path
        )
        for result in results
    ]

# שליפה בודדת (מאובטח)
def get_detection_result_by_user(db: Session, detection_id: int, user_id: int):
    result = db.query(DetectionResult).join(BabyProfile).join(ClassObject).filter(
        DetectionResult.id == detection_id,
        BabyProfile.user_id == user_id
    ).options(
        joinedload(DetectionResult.baby_profile),
        joinedload(DetectionResult.class_)
    ).first()

    if not result:
        return None

    return detection_result_schema.DetectionResultOut(
        id=result.id,
        baby_profile_id=result.baby_profile_id,
        baby_profile_name=result.baby_profile.name,
        class_id=result.class_id,
        class_name=result.class_name,
        confidence=result.confidence,
        camera_type=result.camera_type,
        timestamp=result.timestamp,
        risk_level=result.class_.risk_level,
        image_path=result.image_path
    )

# מחיקה (מאובטח)
def delete_detection_result_by_user(db: Session, detection_id: int, user_id: int):
    db_result = db.query(DetectionResult).join(BabyProfile).filter(
        DetectionResult.id == detection_id,
        BabyProfile.user_id == user_id
    ).options(
        joinedload(DetectionResult.baby_profile),
        joinedload(DetectionResult.class_)
    ).first()

    if db_result is None:
        return None

    # מחיקת קובץ התמונה אם קיים
    if db_result.image_path:
        file_path = os.path.join("uploads", db_result.image_path)
        if os.path.exists(file_path):
            try:
                os.remove(file_path)
            except Exception as e:
                print(f"Failed to delete image file: {e}")

    db.delete(db_result)
    db.commit()

    return detection_result_schema.DetectionResultOut(
        id=db_result.id,
        baby_profile_id=db_result.baby_profile_id,
        baby_profile_name=db_result.baby_profile.name,
        class_id=db_result.class_id,
        class_name=db_result.class_name,
        confidence=db_result.confidence,
        camera_type=db_result.camera_type,
        timestamp=db_result.timestamp,
        risk_level=db_result.class_.risk_level,
        image_path=db_result.image_path
    )

def batch_delete_detection_results_by_user(db: Session, user_id: int, alerts_by_baby: dict):
    # Convert string keys to int (from JSON)
    try:
        baby_ids = [int(bid) for bid in alerts_by_baby.keys()]
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid baby profile ID in request (must be integers)")

    # Check if user owns all the baby profiles
    owned_profiles = db.query(BabyProfile.id).filter(
        BabyProfile.user_id == user_id,
        BabyProfile.id.in_(baby_ids)
    ).all()
    owned_ids = {row.id for row in owned_profiles}

    unauthorized = set(baby_ids) - owned_ids
    if unauthorized:
        raise HTTPException(status_code=403, detail=f"Unauthorized access to baby profile(s): {list(unauthorized)}")

    # Delete detections
    deleted_results = []

    for baby_id_str, alert_ids in alerts_by_baby.items():
        baby_id = int(baby_id_str)
        for alert_id in alert_ids:
            detection = db.query(DetectionResult).join(BabyProfile).filter(
                DetectionResult.id == alert_id,
                DetectionResult.baby_profile_id == baby_id,
                BabyProfile.user_id == user_id
            ).first()

            if detection:
                if detection.image_path:
                    file_path = os.path.join("uploads", detection.image_path)
                    if os.path.exists(file_path):
                        try:
                            os.remove(file_path)
                        except Exception as e:
                            print(f"Failed to delete image file: {e}")
                deleted_results.append(detection)
                db.delete(detection)

    db.commit()
    return {"deleted_count": len(deleted_results)}


