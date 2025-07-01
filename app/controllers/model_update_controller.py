from app.schemas.model_update_schema import ModelUpdateRequest
from sqlalchemy.orm import Session
from app.services.model_update_service import process_model_update
from app.models.user_model import User

# Handles the update request for a model:
# - May add, delete, or update object classes
# - Prepares training data
# - Optionally triggers training or fine-tuning
def update_model_data(request: ModelUpdateRequest, current_user: User, db: Session):
    return process_model_update(request, current_user, db)