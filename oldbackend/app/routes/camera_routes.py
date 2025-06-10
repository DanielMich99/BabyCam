from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.controllers.camera_controller import start_camera, stop_camera, get_camera_status, get_camera_frame
from database.database import get_db

router = APIRouter()

router.post("/start/{profile_id}")(lambda profile_id, db: start_camera(db, profile_id))
router.post("/stop/{profile_id}")(lambda profile_id, db: stop_camera(db, profile_id))
router.get("/status/{profile_id}")(lambda profile_id, db: get_camera_status(db, profile_id))
router.get("/frame/{profile_id}")(lambda profile_id, db: get_camera_frame(db, profile_id))

