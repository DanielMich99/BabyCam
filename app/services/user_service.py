from fastapi import HTTPException
from app.utils.config import config
from app.services.auth_service import users_db



def find_user(username: str):
    """ מחפש משתמש לפי שם משתמש """
    
    if username not in users_db:
        raise HTTPException(status_code=404, detail="User not found")

    return users_db[username]

def modify_user_data(username: str, new_email: str, new_password: str):
    """ מעדכן אימייל וסיסמה של המשתמש """
    
    if username not in users_db:
        raise HTTPException(status_code=404, detail="User not found")

    users_db[username]["email"] = new_email
    users_db[username]["hashed_password"] = new_password  # יש להצפין סיסמאות בעתיד
    
    return {"message": "User updated successfully"}

def remove_user_data(username: str):
    """ מוחק את המשתמש מהמערכת """
    
    if username not in users_db:
        raise HTTPException(status_code=404, detail="User not found")

    del users_db[username]
    
    return {"message": "User deleted successfully"}
