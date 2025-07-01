import os
from fastapi import HTTPException, Request
from sqlalchemy.orm import Session
from app.models.baby_profile_model import BabyProfile
from app.utils.detection import start_detection_loop, stop_detection_loop
from app.schemas.monitoring_schemas import CameraTuple
from app.models.user_model import User
from typing import List

# Starts monitoring (object detection) for the provided list of baby profiles and camera types
async def start_monitoring_service(camera_profiles: List[CameraTuple], current_user: User, db: Session, request: Request):
    active_sessions = []
    user_id = current_user.id if current_user else None  # Extract before session closes

    for item in camera_profiles:
        # Fetch baby profile
        profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id).first()
        if not profile:
            raise HTTPException(status_code=404, detail=f"Profile {item.baby_profile_id} not found")

        # Retrieve camera IP
        ip_field = f"{item.camera_type}_ip"
        ip = getattr(profile, ip_field)
        if not ip:
            raise HTTPException(status_code=400, detail=f"No IP found for {item.camera_type} on profile {item.baby_profile_id}")

        # Verify model file exists
        model_path = f"uploads/training_data/{item.baby_profile_id}/{item.camera_type}/{item.baby_profile_id}_{item.camera_type}_model.pt"
        if not os.path.exists(model_path):
            raise HTTPException(status_code=404, detail=f"Model file not found for {item.camera_type} on profile {item.baby_profile_id}")

        # Start detection loop
        session = await start_detection_loop(profile.id, item.camera_type, ip, user_id, model_path, db, camera_profiles)
        active_sessions.append(session)

        # Update monitoring flag in DB
        if profile:
            setattr(profile, f"{item.camera_type}_in_detection_system_on", True)
            db.commit()

    return {"status": "monitoring_started", "sessions": len(active_sessions)}


# Stops monitoring (object detection) for the provided baby profiles and camera types
async def stop_monitoring_service(camera_profiles: List[CameraTuple], db: Session):
    for item in camera_profiles:
        # Stop detection process
        await stop_detection_loop(item.baby_profile_id, item.camera_type)

        # Reset flag in DB
        profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id).first()
        if profile:
            # Optional: Clear camera IP here if desired
            setattr(profile, f"{item.camera_type}_in_detection_system_on", False)
            db.commit()

    return {"status": "monitoring_stopped"}
