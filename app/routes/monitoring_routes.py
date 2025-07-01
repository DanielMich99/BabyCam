# routes/monitoring_routes.py

from fastapi import APIRouter, Depends, Request, HTTPException
from sqlalchemy.orm import Session
from app.controllers.monitoring_controller import start_monitoring_controller, stop_monitoring_controller
from app.schemas.monitoring_schemas import StartMonitoringRequest
from database.database import get_db
from app.services.auth_service import get_current_user
from app.models.baby_profile_model import BabyProfile

router = APIRouter()

# Start the detection process for selected baby profiles.
# Validates that each selected baby profile belongs to the authenticated user.
@router.post("/monitoring/start")
async def start_monitoring(
    request_data: StartMonitoringRequest,
    request: Request,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Ensure all baby profiles belong to the authenticated user
    for item in request_data.camera_profiles:
        baby_profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id, user_id=current_user.id).first()
        if not baby_profile:
            raise HTTPException(status_code=403, detail=f"Unauthorized access to baby_profile_id {item.baby_profile_id}")

    return await start_monitoring_controller(request_data, current_user, db, request)


# Stop the detection process for selected baby profiles.
# Validates ownership like in the start route.
@router.post("/monitoring/stop")
async def stop_monitoring(
    request: StartMonitoringRequest,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Ensure all baby profiles belong to the authenticated user
    for item in request.camera_profiles:
        baby_profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id, user_id=current_user.id).first()
        if not baby_profile:
            raise HTTPException(status_code=403, detail=f"Unauthorized access to baby_profile_id {item.baby_profile_id}")

    return await stop_monitoring_controller(request, db)
