from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.controllers.streams_controller import get_streams_controller
from app.schemas.streams_schemas import StreamRequest, StreamResponseItem
from database.database import get_db
from typing import List
from app.services.auth_service import get_current_user  # ייבוא האימות הקיים שלך
from app.models.baby_profile_model import BabyProfile

router = APIRouter()

@router.post("/streams", response_model=List[StreamResponseItem])
async def get_streams(
    request: StreamRequest, 
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):  
    # בדיקה שכל הבייבי-פרופיילים באמת שייכים ליוזר
    for item in request.streams:
        baby_profile = db.query(BabyProfile).filter_by(id=item.baby_profile_id, user_id=current_user.id).first()
        if not baby_profile:
            raise HTTPException(status_code=403, detail=f"Unauthorized access to baby_profile_id {item.baby_profile_id}")
    return await get_streams_controller(request, db, current_user)

# from fastapi import APIRouter, HTTPException
# from fastapi.responses import StreamingResponse
# from app.utils.detection import stream_buffers  # מייבא את ה־ESP32StreamBuffer instances
# import cv2
# import time

# router = APIRouter()

# # Generator שמפיק frames בפורמט MJPEG

# def mjpeg_generator(profile_id: int, camera_type: str):
#     key = f"{profile_id}_{camera_type}"
#     stream_buffer = stream_buffers.get(key)

#     if not stream_buffer:
#         print(f"[STREAM] No active stream buffer found for {key}")
#         yield b"--frame\r\nContent-Type: image/jpeg\r\n\r\n\r\n"
#         return

#     while True:
#         frame = stream_buffer.get_latest_frame()
#         if frame is None:
#             time.sleep(0.2)
#             continue

#         success, jpeg = cv2.imencode(".jpg", frame)
#         if not success:
#             continue

#         yield (b"--frame\r\n"
#                b"Content-Type: image/jpeg\r\n\r\n" + jpeg.tobytes() + b"\r\n")

#         time.sleep(0.05)  # ~20fps

# # Endpoint שמגיש את הזרם ל־Frontend

# @router.get("/stream/{profile_id}/{camera_type}")
# def stream_video(profile_id: int, camera_type: str):
#     key = f"{profile_id}_{camera_type}"
#     if key not in stream_buffers:
#         raise HTTPException(status_code=404, detail="Stream not available for this profile")

#     return StreamingResponse(
#         mjpeg_generator(profile_id, camera_type),
#         media_type="multipart/x-mixed-replace; boundary=frame"
#     )