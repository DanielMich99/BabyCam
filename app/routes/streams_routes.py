from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.controllers.streams_controller import get_streams_controller
from app.schemas.streams_schemas import StreamRequest, StreamResponseItem
from database.database import get_db
from typing import List
from app.services.auth_service import get_current_user  # ייבוא האימות הקיים שלך

router = APIRouter()

@router.post("/streams", response_model=List[StreamResponseItem])
async def get_streams(
    request: StreamRequest, 
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    return await get_streams_controller(request, db, current_user)
