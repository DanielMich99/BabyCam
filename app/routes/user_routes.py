from fastapi import APIRouter, Depends
from app.controllers.user_controller import get_user, update_user, delete_user

router = APIRouter()

router.get("/user/{username}")(get_user)
router.put("/user/{username}")(update_user)
router.delete("/user/{username}")(delete_user)