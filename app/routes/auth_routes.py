from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.controllers.auth_controller import register_user, login_user, refresh_access_token
from database.database import get_db
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter()

@router.post("/register")
def register(username: str, password: str, email: str, db: Session = Depends(get_db)):
    return register_user(db, username, password, email)

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    return login_user(form_data, db)

@router.post("/refresh")
def refresh_token(refresh_token: str):
    return refresh_access_token(refresh_token)
