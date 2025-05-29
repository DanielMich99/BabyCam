from app.services.camera_connection_service import camera_manager

async def wait_for_camera_connection(baby_profile_id: int, camera_type: str) -> bool:
    return await camera_manager.wait_for_camera(baby_profile_id, camera_type)

def disconnect_camera_controller(baby_profile_id: int, camera_type: str):
    return camera_manager.disconnect_camera(baby_profile_id, camera_type)

def reset_user_cameras_controller(user_id: int):
    return camera_manager.reset_all_camera_ips_for_user(user_id)