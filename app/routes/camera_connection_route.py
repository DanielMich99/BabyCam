from fastapi import APIRouter, HTTPException, Depends, Request
from app.controllers.camera_connection_controller import wait_for_camera_connection, disconnect_camera_controller, reset_user_cameras_controller
from app.services.camera_connection_service import camera_manager
from pydantic import BaseModel
from app.services.auth_service import get_current_user

router = APIRouter()

class CameraConnectionRequest(BaseModel):
    baby_profile_id: int
    camera_type: str  # 'head_camera' or 'static_camera'

class ResetUserCamerasRequest(BaseModel):
    user_id: int

#קישור מצלמה למודל של פרופיל תינוק
@router.post("/camera/connect")
async def connect_camera(request: CameraConnectionRequest, current_user=Depends(get_current_user)):
    success = await wait_for_camera_connection(request.baby_profile_id, request.camera_type)
    if success:
        return {"status": "connected"}
    raise HTTPException(status_code=504, detail="No camera connected within timeout.")

#ניתוק מצלמה ממודל של פרופיל תינוק
@router.post("/camera/disconnect")
def disconnect_camera_endpoint(request: CameraConnectionRequest, current_user=Depends(get_current_user)):
    success = disconnect_camera_controller(request.baby_profile_id, request.camera_type)
    if success:
        return {"status": "disconnected"}
    raise HTTPException(status_code=404, detail="Profile not found or invalid camera type")

#ניתוק שיוך כל המודלים של יוזר מסוים ממצלמות
@router.post("/camera/reset_user_cameras")
def reset_user_cameras(request: ResetUserCamerasRequest, current_user=Depends(get_current_user)):
    updated = reset_user_cameras_controller(request.user_id)
    if updated == 0:
        raise HTTPException(status_code=404, detail="No baby profiles found for this user")
    return {"status": "reset", "profiles_updated": updated}

#המצלמה שולחת את הip שלה לשרת
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