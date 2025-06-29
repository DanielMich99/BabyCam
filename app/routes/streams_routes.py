from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.controllers.streams_controller import get_streams_controller
from app.schemas.streams_schemas import StreamRequest, StreamResponseItem
from database.database import get_db
from typing import List
from app.services.auth_service import get_current_user  # ייבוא האימות הקיים שלך
from app.models.baby_profile_model import BabyProfile

router = APIRouter()

@router.post("/streams", response_model=List[StreamResponseItem])
async def get_streams(
    request: StreamRequest, 
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):  
    # בדיקה שכל הבייבי-פרופיילים באמת שייכים ליוזר
    for item in request.streams:
        baby_profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id, user_id=current_user.id).first()
        if not baby_profile:
            raise HTTPException(status_code=403, detail=f"Unauthorized access to baby_profile_id {item.baby_profile_id}")
    return await get_streams_controller(request, db, current_user)