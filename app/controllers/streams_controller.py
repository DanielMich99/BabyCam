from sqlalchemy.orm import Session
from app.schemas.streams_schemas import StreamRequest, StreamResponseItem
from app.services.streams_service import get_streams
from app.models.baby_profile_model import BabyProfile
from fastapi import HTTPException

async def get_streams_controller(request: StreamRequest, db: Session, current_user):
    # בדיקה שכל הבייבי-פרופיילים באמת שייכים ליוזר
    for item in request.streams:
        baby_profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id, user_id=current_user.id).first()
        if not baby_profile:
            raise HTTPException(status_code=403, detail=f"Unauthorized access to baby_profile_id {item.baby_profile_id}")

    return get_streams(db, request.streams)
