from fastapi import APIRouter, UploadFile, File
from typing import List
import os

router = APIRouter()

@router.post("/upload-to-temp")
async def upload_to_temp(files: List[UploadFile] = File(...)):
    temp_dir = os.path.join("uploads", "temp")
    os.makedirs(temp_dir, exist_ok=True)
    saved_files = []

    for file in files:
        file_path = os.path.join(temp_dir, file.filename)
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)
        saved_files.append(file.filename)

    return {"saved": saved_files}