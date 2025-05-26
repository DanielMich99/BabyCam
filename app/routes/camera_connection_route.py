from fastapi import APIRouter, HTTPException
from app.controllers.camera_connection_controller import wait_for_camera_connection
from app.services.camera_connection_service import camera_manager
from pydantic import BaseModel
from fastapi import Request

router = APIRouter()

class CameraConnectionRequest(BaseModel):
    baby_profile_id: int
    camera_type: str  # 'head_camera' or 'static_camera'

@router.post("/camera/connect")
async def connect_camera(request: CameraConnectionRequest):
    success = await wait_for_camera_connection(request.baby_profile_id, request.camera_type)
    if success:
        return {"status": "connected"}
    raise HTTPException(status_code=504, detail="No camera connected within timeout.")

@router.post("/camera/report_ip")
async def report_camera_ip(request: Request):
    data = await request.json()
    ip = data.get("ip")

    if not ip:
        return {"status": "error", "message": "Missing IP"}

    key = camera_manager.register_camera_ip(ip)
    if not key:
        return {"status": "error", "message": "No matching profile waiting"}

    return {"status": "ip_received", "profile_key": key}