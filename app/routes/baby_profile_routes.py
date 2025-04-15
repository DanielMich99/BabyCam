from fastapi import APIRouter
from app.controllers.baby_profile_controller import create_profile, get_profiles, update_profile, delete_profile, upload_profile_picture, update_dangerous_objects, get_dangerous_objects

router = APIRouter()

router.post("/create/{user_id}")(create_profile)
router.get("/list/{user_id}")(get_profiles)
router.put("/update/{user_id}/{profile_id}")(update_profile)
router.delete("/delete/{user_id}/{profile_id}")(delete_profile)
router.post("/upload_picture/{user_id}/{profile_id}")(upload_profile_picture)
router.put("/update_dangerous_objects/{profile_id}")(update_dangerous_objects)
router.get("/get_dangerous_objects/{profile_id}")(get_dangerous_objects)