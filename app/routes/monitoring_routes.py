# routes/monitoring_routes.py
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from app.controllers.monitoring_controller import start_monitoring_controller, stop_monitoring_controller
from app.schemas.monitoring_schemas import StartMonitoringRequest
from database.database import get_db
from app.services.auth_service import get_current_user

router = APIRouter()

#התחלת תהליך הזיהוי של מודלי פרופילי התינוקות שנבחרו ע"י המשתמש
@router.post("/monitoring/start")
async def start_monitoring(request_data: StartMonitoringRequest, request: Request, current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    return await start_monitoring_controller(request_data, current_user, db, request)

#סיום תהליך הזיהוי - נקרא כאשר המשתמש לוחץ על כפתור הכיבוי
@router.post("/monitoring/stop")
async def stop_monitoring(request: StartMonitoringRequest, current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    return await stop_monitoring_controller(request, db)
