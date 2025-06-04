from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.schemas import user_schema
from app.controllers import user_controller
from database.database import get_db
from app.services.auth_service import get_current_user
from app.models.user_model import User

router = APIRouter(prefix="/users", tags=["Users"])

# יצירה - פתוח
@router.post("/", response_model=user_schema.UserOut)
def create_user(user_data: user_schema.UserCreate, db: Session = Depends(get_db)):
    return user_controller.create_user_controller(db, user_data)

# שליפה - מאובטח
@router.get("/me", response_model=user_schema.UserOut)
def get_my_user(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return user_controller.get_user_controller(db, current_user.id)

# עדכון - מאובטח
@router.put("/me", response_model=user_schema.UserOut)
def update_my_user(update_data: user_schema.UserUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return user_controller.update_user_controller(db, current_user.id, update_data)

# מחיקה - מאובטח
@router.delete("/me", response_model=user_schema.UserOut)
def delete_my_user(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return user_controller.delete_user_controller(db, current_user.id)
