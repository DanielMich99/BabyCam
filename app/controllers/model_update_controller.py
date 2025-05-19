from app.schemas.model_update_schema import ModelUpdateRequest
from sqlalchemy.orm import Session
from app.services.model_update_service import process_model_update

def update_model_data(request: ModelUpdateRequest, db: Session):
    return process_model_update(request, db)
