import os
from fastapi import HTTPException, Request
from sqlalchemy.orm import Session
from app.models.baby_profile_model import BabyProfile
from app.utils.detection import start_detection_loop, stop_detection_loop

async def start_monitoring_service(camera_profiles, db: Session, request: Request):
    active_sessions = []
    origin = request.headers.get("origin") or "http://localhost:3000"

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

        session = await start_detection_loop(profile.id, item.camera_type, ip, model_path, db, camera_profiles, origin)
        active_sessions.append(session)

    return {"status": "monitoring_started", "sessions": len(active_sessions)}

async def stop_monitoring_service(camera_profiles, db: Session):
    for item in camera_profiles:
        await stop_detection_loop(item.baby_profile_id, item.camera_type)
        profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id).first()
        if profile:
            setattr(profile, f"{item.camera_type}_ip", None)
            db.commit()

    return {"status": "monitoring_stopped"}