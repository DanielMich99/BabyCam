from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.controllers.auth_controller import register_user, login_user, refresh_access_token
from database.database import get_db
from fastapi.security import OAuth2PasswordRequestForm
from app.schemas.auth_schemas import RegisterRequest


router = APIRouter()

@router.post("/register", status_code=201)
def register(register_data: RegisterRequest, db: Session = Depends(get_db)):
    return register_user(db, register_data.username, register_data.password, register_data.email)

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    return login_user(form_data, db)

@router.post("/refresh")
def refresh_token(refresh_token: str):
    return refresh_access_token(refresh_token)
