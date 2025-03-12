from datetime import datetime, timedelta, timezone
import jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from app.utils.config import config

# 🔹 הגדרת הצפנת סיסמאות
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# 🔹 ניהול טוקנים דרך OAuth2
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

# 🔹 מסד נתונים זמני (במקום חיבור ל-DB)
users_db = {}
refresh_tokens = {}

### ✅ **1. רישום משתמש חדש**
def register_user(username: str, password: str, email: str):
    """רושם משתמש חדש במערכת"""
    if username in users_db:
        raise HTTPException(status_code=400, detail="Username already exists")

    hashed_password = hash_password(password)
    users_db[username] = {"username": username, "email": email, "hashed_password": hashed_password}
    
    return {"message": "User registered successfully"}

### ✅ **2. אימות משתמש ויצירת טוקנים**
def authenticate_user(username: str, password: str):
    """בודק את פרטי ההתחברות של המשתמש"""
    user = users_db.get(username)
    if not user or not verify_password(password, user["hashed_password"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    # 🔹 יצירת טוקנים
    access_token = create_access_token(username)
    refresh_token = create_refresh_token(username)

    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

### ✅ **3. הצפנה ובדיקה של סיסמאות**
def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

### ✅ **4. יצירת Access Token**
def create_access_token(username: str):
    access_token = jwt.encode(
        {"sub": username, "exp": datetime.now(timezone.utc) + timedelta(minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES)},  # שינוי כאן
        config.SECRET_KEY,
        algorithm=config.ALGORITHM
    )
    return access_token

### ✅ **5. יצירת Refresh Token**
def create_refresh_token(username: str):
    refresh_token = jwt.encode(
        {"sub": username, "exp": datetime.now(timezone.utc) + timedelta(days=config.REFRESH_TOKEN_EXPIRE_DAYS)},  # שינוי כאן
        config.SECRET_KEY,
        algorithm=config.ALGORITHM
    )
    return refresh_token

### ✅ **6. חידוש Access Token מתוך Refresh Token**
def refresh_access_token(refresh_token: str):
    """מחדש את ה-Access Token אם ה-Refresh Token עדיין תקף"""
    try:
        payload = jwt.decode(refresh_token, config.SECRET_KEY, algorithms=[config.ALGORITHM])
        username = payload.get("sub")

        # 🔹 בדיקה שה-Refresh Token תואם למה ששמור
        if refresh_tokens.get(username) != refresh_token:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token mismatch")

        # 🔹 יצירת Access Token חדש
        return {"access_token": create_access_token(username), "token_type": "bearer"}

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

### ✅ **7. שליפת משתמש נוכחי מתוך Token**
def get_current_user(token: str = Depends(oauth2_scheme)):
    """בודק ומחזיר את המשתמש הנוכחי לפי ה-Token"""
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing token")

    try:
        # 🔹 פענוח ה-JWT Token
        payload = jwt.decode(token, config.SECRET_KEY, algorithms=[config.ALGORITHM])
        username: str = payload.get("sub")

        if username is None or username not in users_db:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

        user = users_db[username]  # 🔹 החזרת כל פרטי המשתמש (לא רק שם)

        return user  # 🔹 מחזיר את כל הנתונים על המשתמש

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has expired")

    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
