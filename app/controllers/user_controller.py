from fastapi import HTTPException
from sqlalchemy.orm import Session
from app.schemas import user_schema
from app.services import user_service

def create_user_controller(db: Session, user_data: user_schema.UserCreate):
    return user_service.create_user(db, user_data)

def get_user_controller(db: Session, user_id: int):
    user = user_service.get_user_by_id(db, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

def update_user_controller(db: Session, user_id: int, update_data: user_schema.UserUpdate):
    user = user_service.update_user(db, user_id, update_data)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

def delete_user_controller(db: Session, user_id: int):
    user = user_service.delete_user(db, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user


