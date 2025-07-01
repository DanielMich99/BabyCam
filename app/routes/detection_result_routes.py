from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.schemas import detection_result_schema
from app.controllers import detection_result_controller
from database.database import get_db
from app.services.auth_service import get_current_user
from app.models.user_model import User
from fastapi.responses import FileResponse
import os

router = APIRouter(prefix="/detection_results", tags=["Detection Results"])


# Create a detection result (used internally by the server – not secured for frontend clients)
@router.post("/", response_model=detection_result_schema.DetectionResultOut)
def create_detection_result(data: detection_result_schema.DetectionResultCreate, db: Session = Depends(get_db)):
    return detection_result_controller.create_detection_result_controller(db, data)


# Retrieve all detection results for the authenticated user
@router.get("/my", response_model=list[detection_result_schema.DetectionResultOut])
def get_my_detection_results(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return detection_result_controller.get_all_detection_results_by_user_controller(db, current_user.id)


# Retrieve detection results filtered by baby profile and camera type
@router.get("/filter", response_model=list[detection_result_schema.DetectionResultOut])
def get_filtered_detection_results(
    baby_profile_id: int,
    camera_type: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return detection_result_controller.get_detection_results_by_filters_controller(
        db, current_user.id, baby_profile_id, camera_type
    )


# Delete multiple detection results grouped by baby profile
@router.delete("/batch_delete")
def batch_delete_detection_results(
    payload: detection_result_schema.BatchDeleteRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return detection_result_controller.batch_delete_detection_results_by_user_controller(
        db, current_user.id, payload.alerts_by_baby
    )


# Retrieve a specific detection result by ID (must belong to user)
@router.get("/{detection_id}", response_model=detection_result_schema.DetectionResultOut)
def get_detection_result(detection_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return detection_result_controller.get_detection_result_by_user_controller(db, detection_id, current_user.id)


# Delete a specific detection result by ID (must belong to user)
@router.delete("/{detection_id}", response_model=detection_result_schema.DetectionResultOut)
def delete_detection_result(detection_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return detection_result_controller.delete_detection_result_by_user_controller(db, detection_id, current_user.id)


# Get the image associated with a detection result
@router.get("/{detection_id}/image")
def get_detection_image(
    detection_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Retrieve detection from DB
    detection = detection_result_controller.get_detection_result_by_user_controller(db, detection_id, current_user.id)

    if not detection or not detection.image_path:
        raise HTTPException(status_code=404, detail="Image not found")

    # Build full path to image
    file_path = os.path.join("uploads", detection.image_path)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")

    return FileResponse(file_path)
