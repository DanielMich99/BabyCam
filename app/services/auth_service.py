from datetime import datetime, timedelta, timezone
import jwt
from passlib.context import CryptContext
from fastapi import HTTPException, status, Depends
from sqlalchemy.orm import Session
from app.models.user_model import User, UserFCMToken
from app.utils.config import config
from app.services.user_service import create_user
from database.database import get_db
from fastapi.security import OAuth2PasswordBearer
from app.schemas.auth_schemas import RegisterRequest
from app.schemas import user_schema

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")
refresh_tokens = {}

def register_user(db: Session, register_data: RegisterRequest):
    existing_user = db.query(User).filter(User.username == register_data.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")
    new_user = user_schema.UserCreate(username=register_data.username,
        email=register_data.email,
        password=register_data.password
    )
    return create_user(db, new_user)

def authenticate_user(db: Session, username: str, password: str):
    user = db.query(User).filter(User.username == username).first()
    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    access_token = create_access_token(username)
    refresh_token = create_refresh_token(username)
    refresh_tokens[username] = refresh_token

    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(username: str):
    return jwt.encode(
        {"sub": username, "exp": datetime.now(timezone.utc) + timedelta(minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES)},
        config.SECRET_KEY,
        algorithm=config.ALGORITHM
    )

def create_refresh_token(username: str):
    return jwt.encode(
        {"sub": username, "exp": datetime.now(timezone.utc) + timedelta(days=config.REFRESH_TOKEN_EXPIRE_DAYS)},
        config.SECRET_KEY,
        algorithm=config.ALGORITHM
    )

def refresh_access_token(refresh_token: str):
    try:
        payload = jwt.decode(refresh_token, config.SECRET_KEY, algorithms=[config.ALGORITHM])
        username = payload.get("sub")
        if refresh_tokens.get(username) != refresh_token:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token mismatch")
        return {"access_token": create_access_token(username), "token_type": "bearer"}
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing token")

    try:
        payload = jwt.decode(token, config.SECRET_KEY, algorithms=[config.ALGORITHM])
        username: str = payload.get("sub")

        if not username:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

        user = db.query(User).filter(User.username == username).first()
        if not user:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

        return user

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    
def verify_jwt_token(token: str):
    try:
        payload = jwt.decode(token, config.SECRET_KEY, algorithms=[config.ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    
'''def update_fcm_token_by_username(db: Session, username: str, token: str):
    user = db.query(User).filter(User.username == username).first()
    if user:
        user.fcm_token = token
        db.commit()
    else:
        raise HTTPException(status_code=404, detail="User not found")'''
    
def add_fcm_token_to_user(db: Session, username: str, token: str):
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    # בדיקה אם הטוקן כבר קיים
    existing_token = db.query(UserFCMToken).filter(UserFCMToken.token == token).first()
    if existing_token:
        return  # לא נכניס טוקן כפול

    new_token = UserFCMToken(user_id=user.id, token=token)
    db.add(new_token)
    db.commit()

def delete_fcm_token(token: str, db: Session, current_user: User):
    username = current_user.username
    user = db.query(User).filter(User.username == username).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    token_obj = db.query(UserFCMToken).filter_by(user_id=user.id, token=token).first()
    if token_obj:
        db.delete(token_obj)
        db.commit()
        return {"message": "FCM token removed successfully"}
    else:
        raise HTTPException(status_code=404, detail="Token not found")
    
