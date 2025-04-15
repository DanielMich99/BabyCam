from sqlalchemy.orm import Session
from app.models.user_model import User
from app.utils.hashing import hash_password
from fastapi import HTTPException

# ✅ **1. שליפת משתמש לפי שם משתמש**
def find_user(db: Session, username: str):
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# ✅ **2. עדכון פרטי משתמש**
def modify_user_data(db: Session, username: str, new_email: str, new_password: str):
    user = find_user(db, username)
    
    # עדכון הנתונים
    user.email = new_email
    user.hashed_password = hash_password(new_password)

    db.commit()
    db.refresh(user)
    return {"message": "User updated successfully"}

# ✅ **3. מחיקת משתמש מהמערכת**
def remove_user_data(db: Session, username: str):
    user = find_user(db, username)
    
    db.delete(user)
    db.commit()
    
    return {"message": "User deleted successfully"}

# ✅ **4. יצירת משתמש חדש**
def create_user(db: Session, username: str, email: str, password: str):
    hashed_password = hash_password(password)
    new_user = User(username=username, email=email, hashed_password=hashed_password)
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {"message": "User created successfully", "username": new_user.username}
