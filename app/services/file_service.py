import os
import shutil
import uuid
from fastapi import HTTPException, UploadFile
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from app.models.file_model import File
from app.utils.config import config

# ✅ **1. העלאת קובץ ושמירת המידע ב-DB**
def upload_user_file(db: Session, user_id: int, file: UploadFile):
    """ מעלה קובץ לתיקייה של המשתמש ושומר את פרטי הקובץ ב-DB """
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in config.ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Invalid file type. Only images are allowed.")

    file_size = file.file.read()
    if not file_size:
        raise HTTPException(status_code=400, detail="Uploaded file is empty")

    file.file.seek(0)

    user_dir = os.path.join(config.UPLOAD_DIR, str(user_id))
    os.makedirs(user_dir, exist_ok=True)

    new_filename = f"{uuid.uuid4()}{ext}"
    file_location = os.path.join(user_dir, new_filename)

    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # ✅ שמירת פרטי הקובץ ב-DB
    new_file = File(
        user_id=user_id,
        filename=new_filename,
        path=file_location
    )
    db.add(new_file)
    db.commit()
    db.refresh(new_file)

    return {"filename": new_filename, "message": "File uploaded successfully!"}

# ✅ **2. שליפת רשימת קבצים מה-DB**
def get_user_files(db: Session, user_id: int):
    """מחזיר רשימת קבצים של המשתמש מה-DB"""
    files = db.query(File).filter(File.user_id == user_id).all()
    if not files:
        raise HTTPException(status_code=404, detail="No files found for this user")
    
    return {"files": [file.filename for file in files]}

# ✅ **3. הורדת קובץ לפי שם**
def download_user_file(db: Session, user_id: int, filename: str):
    """מחזיר קובץ ספציפי להורדה מה-DB"""
    file = db.query(File).filter(File.user_id == user_id, File.filename == filename).first()
    if not file:
        raise HTTPException(status_code=404, detail="File not found")
    
    if not os.path.exists(file.path):
        raise HTTPException(status_code=404, detail="File path not found on disk")
    
    return FileResponse(file.path, media_type="application/octet-stream", filename=filename)

# ✅ **4. מחיקת קובץ מה-DB ומהדיסק**
def remove_user_file(db: Session, user_id: int, filename: str):
    """מוחק קובץ של המשתמש מה-DB ומהמערכת"""
    file = db.query(File).filter(File.user_id == user_id, File.filename == filename).first()
    if not file:
        raise HTTPException(status_code=404, detail="File not found")
    
    # ✅ מחיקת הקובץ מהדיסק
    if os.path.exists(file.path):
        os.remove(file.path)

    # ✅ מחיקת הפרטים מה-DB
    db.delete(file)
    db.commit()
    
    return {"message": f"File {filename} deleted successfully!"}
