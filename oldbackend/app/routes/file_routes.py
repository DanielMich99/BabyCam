from fastapi import APIRouter
from app.controllers.file_controller import upload_file, download_file, list_user_files, delete_file

router = APIRouter()

router.post("/upload/{user_id}")(upload_file)
router.get("/download/{user_id}/{filename}")(download_file)
router.get("/files/{user_id}")(list_user_files)
router.delete("/delete/{user_id}/{filename}")(delete_file)