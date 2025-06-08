# class_routes.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.controllers.class_controller import fetch_classes_by_profile_and_camera
from app.schemas.class_schema import ClassResponse
from database.database import get_db
from app.services.auth_service import get_current_user

router = APIRouter(
    prefix="/classes",
    tags=["Classes"]
)

@router.get("/", response_model=List[ClassResponse])
def get_classes(
    baby_profile_id: int,
    camera_type: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    return fetch_classes_by_profile_and_camera(
        db, 
        current_user.id, 
        baby_profile_id, 
        camera_type
    )
