from fastapi import APIRouter, UploadFile, File, Depends
from typing import List
import os
from app.services.auth_service import get_current_user

router = APIRouter()

# Uploads one or more files to the temporary upload directory.
# Authenticated users only.
@router.post("/upload-to-temp")
async def upload_to_temp(files: List[UploadFile] = File(...), current_user=Depends(get_current_user)):
    # Define path to temporary upload folder
    temp_dir = os.path.join("uploads", "temp")
    os.makedirs(temp_dir, exist_ok=True)

    saved_files = []

    for file in files:
        file_path = os.path.join(temp_dir, file.filename)
        # Read and save each file to the temp directory
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)
        saved_files.append(file.filename)

    return {"saved": saved_files}
