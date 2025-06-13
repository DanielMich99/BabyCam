from sqlalchemy.orm import Session
from typing import List
from app.models.baby_profile_model import BabyProfile
from app.schemas.streams_schemas import StreamRequestItem, StreamResponseItem

def get_streams(db: Session, stream_requests: List[StreamRequestItem]) -> List[StreamResponseItem]:
    response = []

    for item in stream_requests:
        baby_profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id).first()

        if not baby_profile:
            continue

        ip = None
        if item.model_type == "head_camera":
            ip = baby_profile.head_camera_ip
        elif item.model_type == "static_camera":
            ip = baby_profile.static_camera_ip

        if ip:
            stream_url = f"http://{ip}/stream"
            response.append(StreamResponseItem(
                baby_profile_id=item.baby_profile_id,
                model_type=item.model_type,
                stream_url=stream_url
            ))

    return response
