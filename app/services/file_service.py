import os
import shutil
import uuid
from fastapi import HTTPException, UploadFile
from fastapi.responses import FileResponse
from app.utils.config import config

def upload_user_file(user_id: str, file: UploadFile):
    """ מעלה קובץ לתיקייה של המשתמש """
    
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in config.ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Invalid file type. Only images are allowed.")
    
    file_size = file.file.read()
    if not file_size:
        raise HTTPException(status_code=400, detail="Uploaded file is empty")

    file.file.seek(0)

    user_dir = os.path.join(config.UPLOAD_DIR, user_id)
    os.makedirs(user_dir, exist_ok=True)

    new_filename = f"{uuid.uuid4()}{ext}"
    file_location = os.path.join(user_dir, new_filename)

    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return {"filename": new_filename, "message": "File uploaded successfully!"}

def get_user_files(user_id: str):
    """ מחזיר רשימת קבצים של המשתמש """
    
    user_dir = os.path.join(config.UPLOAD_DIR, user_id)
    if not os.path.exists(user_dir):
        raise HTTPException(status_code=404, detail="User directory not found.")

    files = os.listdir(user_dir)
    return {"files": files}

def download_user_file(user_id: str, filename: str):
    """ מחזיר קובץ ספציפי להורדה """
    
    file_path = os.path.join(config.UPLOAD_DIR, user_id, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found.")

    return FileResponse(file_path, media_type="application/octet-stream", filename=filename)

def remove_user_file(user_id: str, filename: str):
    """ מוחק קובץ של המשתמש """
    
    file_path = os.path.join(config.UPLOAD_DIR, user_id, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found.")

    os.remove(file_path)
    return {"message": f"File {filename} deleted successfully!"}
