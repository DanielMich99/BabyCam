from fastapi import HTTPException
from sqlalchemy.orm import Session
from app.schemas import detection_result_schema
from app.services import detection_result_service

# Creates a new detection result entry in the database
def create_detection_result_controller(db: Session, data: detection_result_schema.DetectionResultCreate):
    return detection_result_service.create_detection_result(db, data)

# Retrieves all detection results associated with a specific user
def get_all_detection_results_by_user_controller(db: Session, user_id: int):
    return detection_result_service.get_all_detection_results_by_user(db, user_id)

# Retrieves detection results for a given baby profile and camera type
def get_detection_results_by_filters_controller(db: Session, user_id: int, baby_profile_id: int, camera_type: str):
    return detection_result_service.get_detection_results_by_filters(db, user_id, baby_profile_id, camera_type)

# Retrieves a specific detection result for a user by its ID (secured)
def get_detection_result_by_user_controller(db: Session, detection_id: int, user_id: int):
    result = detection_result_service.get_detection_result_by_user(db, detection_id, user_id)
    if result is None:
        # Return 404 if result is not found or does not belong to the user
        raise HTTPException(status_code=404, detail="Detection result not found or unauthorized")
    return result

# Deletes a specific detection result if it belongs to the user
def delete_detection_result_by_user_controller(db: Session, detection_id: int, user_id: int):
    result = detection_result_service.delete_detection_result_by_user(db, detection_id, user_id)
    if result is None:
        # Return 404 if not found or not authorized
        raise HTTPException(status_code=404, detail="Detection result not found or unauthorized")
    return result

# Deletes multiple detection results for a user in batch (grouped by baby profile)
def batch_delete_detection_results_by_user_controller(db: Session, user_id: int, alerts_by_baby: dict):
    return detection_result_service.batch_delete_detection_results_by_user(db, user_id, alerts_by_baby)
