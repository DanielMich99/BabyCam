# Authentication and user session management logic

from datetime import datetime, timedelta, timezone
import jwt
from typing import List
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from database.database import get_db
from app.models.user_model import User, UserFCMToken
from app.models.baby_profile_model import BabyProfile
from app.schemas import user_schema
from app.schemas.auth_schemas import RegisterRequest
from app.services.user_service import create_user
from app.utils.config import config
from app.utils.hashing import verify_password
from app.schemas.monitoring_schemas import CameraTuple

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

# In-memory storage of refresh tokens
refresh_tokens = {}


# Register a new user if username is available
def register_user(db: Session, register_data: RegisterRequest):
    existing_user = db.query(User).filter(User.username == register_data.username).first()
    if existing_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already exists")

    new_user = user_schema.UserCreate(
        username=register_data.username,
        email=register_data.email,
        password=register_data.password
    )
    return create_user(db, new_user)


# Verify credentials and return JWT access + refresh tokens
def authenticate_user(db: Session, username: str, password: str):
    user = db.query(User).filter(User.username == username).first()
    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    
    first_login = not user.already_logged_in
    if first_login:
        user.already_logged_in = True
        db.commit()

    access_token = create_access_token(username)
    refresh_token = create_refresh_token(username)
    refresh_tokens[username] = refresh_token

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "first_login": first_login
    }


# Create access token with expiration
def create_access_token(username: str):
    return jwt.encode(
        {
            "sub": username,
            "exp": datetime.now(timezone.utc) + timedelta(minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES)
        },
        config.SECRET_KEY,
        algorithm=config.ALGORITHM
    )


# Create refresh token with longer expiration
def create_refresh_token(username: str):
    return jwt.encode(
        {
            "sub": username,
            "exp": datetime.now(timezone.utc) + timedelta(days=config.REFRESH_TOKEN_EXPIRE_DAYS)
        },
        config.SECRET_KEY,
        algorithm=config.ALGORITHM
    )


# Validate refresh token and issue new access token
def refresh_access_token(refresh_token: str):
    try:
        payload = jwt.decode(refresh_token, config.SECRET_KEY, algorithms=[config.ALGORITHM])
        username = payload.get("sub")
        if refresh_tokens.get(username) != refresh_token:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token mismatch")

        return {
            "access_token": create_access_token(username),
            "token_type": "bearer"
        }
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")


# Save FCM token to user
def add_fcm_token_to_user(db: Session, username: str, token: str):
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    existing_token = db.query(UserFCMToken).filter(UserFCMToken.token == token).first()
    if existing_token:
        return existing_token

    new_token = UserFCMToken(user_id=user.id, token=token)
    db.add(new_token)
    db.commit()
    db.refresh(new_token)
    return new_token


# Remove an FCM token from user
def delete_fcm_token(token: str, db: Session, current_user: User):
    username = current_user.username
    user = db.query(User).filter(User.username == username).first()

    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    token_obj = db.query(UserFCMToken).filter_by(user_id=user.id, token=token).first()
    if token_obj:
        db.delete(token_obj)
        db.commit()
    else:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Token not found")


# Handle full logout logic
async def process_logout(db: Session, user: User, baby_profile_ids: List[int], fcm_token: str, request: Request):
    # Step 1: Validate ownership of baby profiles
    owned_ids = db.query(BabyProfile.id).filter(BabyProfile.user_id == user.id).all()
    owned_ids_set = {r.id for r in owned_ids}
    if not set(baby_profile_ids).issubset(owned_ids_set):
        raise HTTPException(status_code=403, detail="Unauthorized access to baby profile(s)")

    # Step 2: Remove FCM token
    token_entry = db.query(UserFCMToken).filter_by(user_id=user.id, token=fcm_token).first()
    if token_entry:
        db.delete(token_entry)
        db.commit()
    if not token_entry:
        # Don't block logout if token isn't found — just log
        print("FCM token not found")

    # Step 3: If user still has other FCM tokens, don't fully log out
    if db.query(UserFCMToken).filter_by(user_id=user.id).count() > 0:
        return {"status": "partial_logout"}

    # Step 4: Disconnect all cameras and stop monitoring
    profiles = db.query(BabyProfile).filter(BabyProfile.user_id == user.id).all()
    monitoring_to_stop = []

    for profile in profiles:
        for cam_type in ["head_camera", "static_camera"]:
            if getattr(profile, f"{cam_type}_on"):
                setattr(profile, f"{cam_type}_on", False)
            if getattr(profile, f"{cam_type}_ip"):
                setattr(profile, f"{cam_type}_ip", None)
            if getattr(profile, f"{cam_type}_in_detection_system_on"):
                setattr(profile, f"{cam_type}_in_detection_system_on", False)
                monitoring_to_stop.append(CameraTuple(
                    baby_profile_id=profile.id,
                    camera_type=cam_type
                ))

    db.commit()

    # Step 5: Stop active monitoring services
    if monitoring_to_stop:
        from app.services.monitoring_service import stop_monitoring_service
        await stop_monitoring_service(monitoring_to_stop, db)

    return {"status": "logout_successful"}


# Get current user based on access token
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


# Verify JWT token manually and return decoded payload (used in WebSocket or internal tools)
def verify_jwt_token(token: str):
    try:
        payload = jwt.decode(token, config.SECRET_KEY, algorithms=[config.ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
