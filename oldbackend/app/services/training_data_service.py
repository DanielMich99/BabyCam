import os
import shutil
from app.utils.config import config
from datetime import datetime

BASE_UPLOAD_DIR = os.path.join(config.UPLOAD_DIR, "training_data")

def ensure_dir(path: str):
    os.makedirs(path, exist_ok=True)

def save_image(user_id: int, object_name: str, image_file):
    save_dir = os.path.join(BASE_UPLOAD_DIR, str(user_id), "head_camera", "objects", object_name)
    ensure_dir(save_dir)
    filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{image_file.filename}"
    save_path = os.path.join(save_dir, filename)

    with open(save_path, "wb") as buffer:
        shutil.copyfileobj(image_file.file, buffer)

    return save_path

def save_video(user_id: int, scene_name: str, video_file):
    save_dir = os.path.join(BASE_UPLOAD_DIR, str(user_id), "static_camera", "scenes", scene_name)
    ensure_dir(save_dir)
    filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{video_file.filename}"
    save_path = os.path.join(save_dir, filename)

    with open(save_path, "wb") as buffer:
        shutil.copyfileobj(video_file.file, buffer)

    return save_path
