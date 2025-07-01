from app.services.camera_connection_service import camera_manager

# Waits asynchronously for a camera to connect (within a timeout) for the given baby profile and camera type
async def wait_for_camera_connection(baby_profile_id: int, camera_type: str) -> bool:
    return await camera_manager.wait_for_camera(baby_profile_id, camera_type)

# Disconnects the camera (removes stored IP) for a given baby profile and camera type
def disconnect_camera_controller(baby_profile_id: int, camera_type: str):
    return camera_manager.disconnect_camera(baby_profile_id, camera_type)

# Resets (clears) all camera IP addresses for a specific user (typically called on logout)
def reset_user_cameras_controller(user_id: int):
    return camera_manager.reset_all_camera_ips_for_user(user_id)
