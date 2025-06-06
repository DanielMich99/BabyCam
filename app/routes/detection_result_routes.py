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

# יצירה (לא מאובטח — רק השרת קורא)
@router.post("/", response_model=detection_result_schema.DetectionResultOut)
def create_detection_result(data: detection_result_schema.DetectionResultCreate, db: Session = Depends(get_db)):
    return detection_result_controller.create_detection_result_controller(db, data)

# שליפה של כל ההיסטוריה של המשתמש
@router.get("/my", response_model=list[detection_result_schema.DetectionResultOut])
def get_my_detection_results(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return detection_result_controller.get_all_detection_results_by_user_controller(db, current_user.id)

# שליפה לפי פילטרים: פרופיל תינוק + סוג מצלמה
@router.get("/filter", response_model=list[detection_result_schema.DetectionResultOut])
def get_filtered_detection_results(
    baby_profile_id: int,
    camera_type: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return detection_result_controller.get_detection_results_by_filters_controller(db, current_user.id, baby_profile_id, camera_type)

# שליפה בודדת לפי id
@router.get("/{detection_id}", response_model=detection_result_schema.DetectionResultOut)
def get_detection_result(detection_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return detection_result_controller.get_detection_result_by_user_controller(db, detection_id, current_user.id)

# מחיקה (מאובטח)
@router.delete("/{detection_id}", response_model=detection_result_schema.DetectionResultOut)
def delete_detection_result(detection_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return detection_result_controller.delete_detection_result_by_user_controller(db, detection_id, current_user.id)

@router.get("/{detection_id}/image")
def get_detection_image(
    detection_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # נשלוף את ה-detection
    detection = detection_result_controller.get_detection_result_by_user_controller(db, detection_id, current_user.id)

    if not detection or not detection.image_path:
        raise HTTPException(status_code=404, detail="Image not found")

    file_path = os.path.join("uploads", detection.image_path)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")

    return FileResponse(file_path)