# routes/monitoring_routes.py
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from app.controllers.monitoring_controller import start_monitoring_controller, stop_monitoring_controller
from app.schemas.monitoring_schemas import StartMonitoringRequest
from database.database import get_db

router = APIRouter()

#התחלת תהליך הזיהוי של מודלי פרופילי התינוקות שנבחרו ע"י המשתמש
@router.post("/monitoring/start")
async def start_monitoring(request_data: StartMonitoringRequest, request: Request, db: Session = Depends(get_db)):
    return await start_monitoring_controller(request_data, db, request)

#סיום תהליך הזיהוי - נקרא כאשר המשתמש לוחץ על כפתור הכיבוי
@router.post("/monitoring/stop")
async def stop_monitoring(request: StartMonitoringRequest, db: Session = Depends(get_db)):
    return await stop_monitoring_controller(request, db)
