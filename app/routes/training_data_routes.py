from fastapi import APIRouter, UploadFile, File, Form
from app.controllers import training_data_controller

router = APIRouter(
    prefix="/training_data",
    tags=["Training Data"]
)

@router.post("/upload_image")
async def upload_training_image(
    user_id: int = Form(...),
    object_name: str = Form(...),
    image: UploadFile = File(...)
):
    return await training_data_controller.upload_training_image(user_id, object_name, image)

@router.post("/upload_video")
async def upload_training_video(
    user_id: int = Form(...),
    scene_name: str = Form(...),
    video: UploadFile = File(...)
):
    return await training_data_controller.upload_training_video(user_id, scene_name, video)
