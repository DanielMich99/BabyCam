from fastapi import HTTPException, Depends
from app.services.user_service import find_user, modify_user_data, remove_user_data
from app.services.auth_service import get_current_user

def get_user(username: str, current_user: dict = Depends(get_current_user)):
    if current_user["username"] != username:
        raise HTTPException(status_code=403, detail="You can only view your own profile")

    return find_user(username)

def update_user(username: str, new_email: str, new_password: str, current_user: dict = Depends(get_current_user)):
    if current_user["username"] != username:
        raise HTTPException(status_code=403, detail="You can only modify your own account")

    return modify_user_data(username, new_email, new_password)

def delete_user(username: str, current_user: dict = Depends(get_current_user)):
    if current_user["username"] != username:
        raise HTTPException(status_code=403, detail="You can only delete your own account")

    return remove_user_data(username)

