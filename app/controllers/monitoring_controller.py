from sqlalchemy.orm import Session
from fastapi import Request, Depends
from app.services.monitoring_service import start_monitoring_service, stop_monitoring_service
from app.schemas.monitoring_schemas import StartMonitoringRequest
from app.services.auth_service import get_current_user
from app.models.user_model import User

# Starts the monitoring service for one or more cameras in the provided list.
# Uses current user info, DB session, and HTTP request context (e.g., for IP handling).
async def start_monitoring_controller(request: StartMonitoringRequest, current_user: User, db: Session, http_request: Request):
    return await start_monitoring_service(request.camera_profiles, current_user, db, http_request)

# Stops the monitoring service for the specified list of camera profiles.
async def stop_monitoring_controller(request: StartMonitoringRequest, db: Session):
    return await stop_monitoring_service(request.camera_profiles, db)