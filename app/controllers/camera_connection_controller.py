from app.services.camera_connection_service import camera_manager

async def wait_for_camera_connection(baby_profile_id: int, camera_type: str) -> bool:
    return await camera_manager.wait_for_camera(baby_profile_id, camera_type)
