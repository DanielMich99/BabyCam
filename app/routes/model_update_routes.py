from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.schemas.model_update_schema import ModelUpdateRequest
from app.controllers.model_update_controller import update_model_data
from database.database import get_db
from app.services.auth_service import get_current_user
from app.models.baby_profile_model import BabyProfile

router = APIRouter()

# Endpoint to update the object detection model for a given baby profile
# The request includes additions, deletions, or updates to object classes and training data
@router.post("/model/update")
def update_model(
    request: ModelUpdateRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    print(request)  # Debug print – can be removed in production

    # Ensure the baby profile belongs to the authenticated user
    baby_profile = db.query(BabyProfile).filter_by(id=request.baby_profile_id, user_id=current_user.id).first()
    if not baby_profile:
        raise HTTPException(status_code=403, detail=f"Unauthorized access to baby_profile_id {request.baby_profile_id}")

    # Process the model update using controller logic
    return update_model_data(request, current_user, db)
