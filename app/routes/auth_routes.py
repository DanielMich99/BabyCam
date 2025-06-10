from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.controllers.auth_controller import register_user, login_user, refresh_access_token, save_fcm_token, delete_fcm_token_controller
from database.database import get_db
from fastapi.security import OAuth2PasswordRequestForm
from app.schemas.auth_schemas import RegisterRequest, LoginRequest, FCMTokenRequest
from app.services.auth_service import get_current_user

router = APIRouter()

@router.post("/register", status_code=201)
def register(register_data: RegisterRequest, db: Session = Depends(get_db)):
    return register_user(db, register_data.username, register_data.password, register_data.email)

@router.post("/login")
def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    return login_user(login_data, db)

@router.post("/refresh")
def refresh_token(refresh_token: str):
    return refresh_access_token(refresh_token)

#שליחת fcm token מהמכשיר של המשתמש לשרת
@router.post("/save-fcm-token")
def set_fcm_token(token_request: FCMTokenRequest, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return save_fcm_token(token_request.token, db, current_user)

@router.post("/remove-fcm-token")
def remove_fcm_token(token_request: FCMTokenRequest, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return delete_fcm_token_controller(token_request.token, db, current_user)