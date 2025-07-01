from fastapi import APIRouter
from app.controllers.dangerous_objects_controller import get_recommended_dangers

router = APIRouter()

router.get("/recommend/{user_id}/{profile_id}")(get_recommended_dangers)
