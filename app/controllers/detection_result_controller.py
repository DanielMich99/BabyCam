from fastapi import HTTPException
from sqlalchemy.orm import Session
from app.schemas import detection_result_schema
from app.services import detection_result_service

def create_detection_result_controller(db: Session, data: detection_result_schema.DetectionResultCreate):
    return detection_result_service.create_detection_result(db, data)

def get_all_detection_results_by_user_controller(db: Session, user_id: int):
    return detection_result_service.get_all_detection_results_by_user(db, user_id)

def get_detection_results_by_filters_controller(db: Session, user_id: int, baby_profile_id: int, camera_type: str):
    return detection_result_service.get_detection_results_by_filters(db, user_id, baby_profile_id, camera_type)

def get_detection_result_by_user_controller(db: Session, detection_id: int, user_id: int):
    result = detection_result_service.get_detection_result_by_user(db, detection_id, user_id)
    if result is None:
        raise HTTPException(status_code=404, detail="Detection result not found or unauthorized")
    return result

def delete_detection_result_by_user_controller(db: Session, detection_id: int, user_id: int):
    result = detection_result_service.delete_detection_result_by_user(db, detection_id, user_id)
    if result is None:
        raise HTTPException(status_code=404, detail="Detection result not found or unauthorized")
    return result
