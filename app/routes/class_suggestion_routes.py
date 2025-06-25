from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.controllers.class_suggestion_controller import get_suggested_classes_controller
from app.schemas.class_suggestion_schema import SuggestedClassesResponse
from database.database import get_db
from app.services.auth_service import get_current_user

router = APIRouter(prefix="/class_suggestions", tags=["Class Suggestions"])


@router.get("/", response_model=SuggestedClassesResponse)
def suggest_classes(
    baby_profile_id: int,
    camera_type: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    classes = get_suggested_classes_controller(
        db,
        current_user.id,
        baby_profile_id,
        camera_type,
    )
    return {
        "camera_type": camera_type,
        "classes": classes,
    }