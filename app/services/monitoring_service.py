import os
from fastapi import HTTPException, Request
from sqlalchemy.orm import Session
from app.models.baby_profile_model import BabyProfile
from app.utils.detection import start_detection_loop, stop_detection_loop
from app.schemas.monitoring_schemas import CameraTuple
from app.models.user_model import User
from typing import List

async def start_monitoring_service(camera_profiles: List[CameraTuple], current_user: User, db: Session, request: Request):
    active_sessions = []

    # Extract user ID before the object becomes detached
    user_id = current_user.id if current_user else None

    for item in camera_profiles:
        profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id).first()
        if not profile:
            raise HTTPException(status_code=404, detail=f"Profile {item.baby_profile_id} not found")

        ip_field = f"{item.camera_type}_ip"
        ip = getattr(profile, ip_field)
        if not ip:
            raise HTTPException(status_code=400, detail=f"No IP found for {item.camera_type} on profile {item.baby_profile_id}")

        model_path = f"uploads/training_data/{item.baby_profile_id}/{item.camera_type}/{item.baby_profile_id}_{item.camera_type}_model.pt"
        if not os.path.exists(model_path):
            raise HTTPException(status_code=404, detail=f"Model file not found for {item.camera_type} on profile {item.baby_profile_id}")

        session = await start_detection_loop(profile.id, item.camera_type, ip, user_id, model_path, db, camera_profiles)
        active_sessions.append(session)
        if profile:
            setattr(profile, f"{item.camera_type}_in_detection_system_on", True)
            db.commit()    

    return {"status": "monitoring_started", "sessions": len(active_sessions)}

async def stop_monitoring_service(camera_profiles: List[CameraTuple], db: Session):
    for item in camera_profiles:
        await stop_detection_loop(item.baby_profile_id, item.camera_type)
        profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id).first()
        if profile:
            #setattr(profile, f"{item.camera_type}_ip", None)
            setattr(profile, f"{item.camera_type}_in_detection_system_on", False)
            db.commit()    

    return {"status": "monitoring_stopped"}