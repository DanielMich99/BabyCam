from fastapi import APIRouter, HTTPException, Depends, Request
from app.controllers.camera_connection_controller import wait_for_camera_connection, disconnect_camera_controller, reset_user_cameras_controller
from app.services.camera_connection_service import camera_manager
from pydantic import BaseModel
from app.services.auth_service import get_current_user
from sqlalchemy.orm import Session
from database.database import get_db
from app.models.baby_profile_model import BabyProfile
from app.models.user_model import User

router = APIRouter()

# Request body schema for camera connect/disconnect
class CameraConnectionRequest(BaseModel):
    baby_profile_id: int
    camera_type: str  # 'head_camera' or 'static_camera'

# Request body schema for resetting all user cameras
class ResetUserCamerasRequest(BaseModel):
    user_id: int

# Link a camera to a baby profile model (starts waiting for a camera to report its IP)
@router.post("/camera/connect")
async def connect_camera(request: CameraConnectionRequest, current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    baby_profile = db.query(BabyProfile).filter_by(id=request.baby_profile_id, user_id=current_user.id).first()
    if not baby_profile:
        raise HTTPException(status_code=403, detail=f"Unauthorized access to baby_profile_id {request.baby_profile_id}")
    
    success = await wait_for_camera_connection(request.baby_profile_id, request.camera_type)
    if success:
        return {"status": "connected", "url": success}
    
    raise HTTPException(status_code=504, detail="No camera connected within timeout.")

# Disconnect a camera from a baby profile (clears stored IP)
@router.post("/camera/disconnect")
def disconnect_camera_endpoint(request: CameraConnectionRequest, current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    baby_profile = db.query(BabyProfile).filter_by(id=request.baby_profile_id, user_id=current_user.id).first()
    if not baby_profile:
        raise HTTPException(status_code=403, detail=f"Unauthorized access to baby_profile_id {request.baby_profile_id}")
    
    success = disconnect_camera_controller(request.baby_profile_id, request.camera_type)
    if success:
        return {"status": "disconnected"}
    
    raise HTTPException(status_code=404, detail="Profile not found or invalid camera type")

# Disconnect all cameras from all baby profiles owned by a specific user
@router.post("/camera/reset_user_cameras")
def reset_user_cameras(request: ResetUserCamerasRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if request.user_id != current_user.id:
        raise HTTPException(status_code=403, detail=f"Unauthorized access to user_id {request.user_id}")
    
    updated = reset_user_cameras_controller(request.user_id)
    if updated == 0:
        raise HTTPException(status_code=404, detail="No baby profiles found for this user")
    
    return {"status": "reset", "profiles_updated": updated}

# Endpoint for a camera to report its IP to the server (called by ESP32-CAM)
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
