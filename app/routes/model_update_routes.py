from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.schemas.model_update_schema import ModelUpdateRequest
from app.controllers.model_update_controller import update_model_data
from database.database import get_db

router = APIRouter()

@router.post("/model/update")
def update_model(request: ModelUpdateRequest, db: Session = Depends(get_db)):
    return update_model_data(request, db)