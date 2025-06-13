from sqlalchemy.orm import Session
from app.schemas.streams_schemas import StreamRequest, StreamResponseItem
from app.services.streams_service import get_streams
from app.models.baby_profile_model import BabyProfile
from fastapi import HTTPException

async def get_streams_controller(request: StreamRequest, db: Session, current_user):
    return get_streams(db, request.streams)
