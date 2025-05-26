from sqlalchemy.orm import Session
from fastapi import Request
from app.services.monitoring_service import start_monitoring_service, stop_monitoring_service
from app.schemas.monitoring_schemas import StartMonitoringRequest

async def start_monitoring_controller(request: StartMonitoringRequest, db: Session, http_request: Request):
    return await start_monitoring_service(request.camera_profiles, db, http_request)

async def stop_monitoring_controller(request: StartMonitoringRequest, db: Session):
    return await stop_monitoring_service(request.camera_profiles, db)