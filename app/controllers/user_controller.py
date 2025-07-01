from fastapi import HTTPException
from sqlalchemy.orm import Session
from app.schemas import user_schema
from app.services import user_service

# Creates a new user in the system using the provided user creation schema
def create_user_controller(db: Session, user_data: user_schema.UserCreate):
    return user_service.create_user(db, user_data)

# Retrieves a user by their ID
def get_user_controller(db: Session, user_id: int):
    user = user_service.get_user_by_id(db, user_id)
    if user is None:
        # If the user does not exist, return 404
        raise HTTPException(status_code=404, detail="User not found")
    return user

# Updates an existing user with the given update data
def update_user_controller(db: Session, user_id: int, update_data: user_schema.UserUpdate):
    user = user_service.update_user(db, user_id, update_data)
    if user is None:
        # If the user does not exist, return 404
        raise HTTPException(status_code=404, detail="User not found")
    return user

# Deletes a user by their ID
def delete_user_controller(db: Session, user_id: int):
    user = user_service.delete_user(db, user_id)
    if user is None:
        # If the user does not exist, return 404
        raise HTTPException(status_code=404, detail="User not found")
    return user
