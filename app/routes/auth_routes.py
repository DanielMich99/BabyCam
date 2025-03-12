from fastapi import APIRouter
from app.controllers.auth_controller import register_user, login_user, refresh_access_token

router = APIRouter()

router.post("/register")(register_user)
router.post("/login")(login_user)
router.post("/refresh")(refresh_access_token)
