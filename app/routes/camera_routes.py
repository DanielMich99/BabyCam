from fastapi import APIRouter
from app.controllers.camera_controller import start_camera, stop_camera, get_camera_status, get_camera_frame

router = APIRouter()

router.post("/start/{user_id}")(start_camera)
router.post("/stop/{user_id}")(stop_camera)
router.get("/status/{user_id}")(get_camera_status)
router.get("/frame/{user_id}")(get_camera_frame)
