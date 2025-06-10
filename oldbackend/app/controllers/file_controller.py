from fastapi import HTTPException, UploadFile, File, Depends
from app.services.file_service import upload_user_file, get_user_files, download_user_file, remove_user_file
from app.services.auth_service import get_current_user

def upload_file(user_id: str, file: UploadFile = File(...), current_user: dict = Depends(get_current_user)):
    if current_user["username"] != user_id:
        raise HTTPException(status_code=403, detail="You can only upload files to your own account")

    return upload_user_file(user_id, file)

def list_user_files(user_id: str, current_user: dict = Depends(get_current_user)):
    if current_user["username"] != user_id:
        raise HTTPException(status_code=403, detail="You can only view your own files")

    return get_user_files(user_id)

def download_file(user_id: str, filename: str, current_user: dict = Depends(get_current_user)):
    if current_user["username"] != user_id:
        raise HTTPException(status_code=403, detail="You can only download your own files")

    return download_user_file(user_id, filename)

def delete_file(user_id: str, filename: str, current_user: dict = Depends(get_current_user)):
    if current_user["username"] != user_id:
        raise HTTPException(status_code=403, detail="You can only delete your own files")

    return remove_user_file(user_id, filename)
