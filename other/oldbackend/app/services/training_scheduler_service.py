import os
import json
import time
from datetime import datetime
from app.services.dataset_service import create_dataset_yaml
from upload_to_drive import zip_dataset, upload_to_drive
import requests

# תנאים לאימון מחדש
MIN_NEW_IMAGES = 10               # כמה תמונות חדשות לפחות
MIN_HOURS_BETWEEN_TRAINING = 12   # שעות מינימום בין אימונים

def count_new_images_since(path: str, last_trained_ts: float) -> int:
    return len([
        f for root, _, files in os.walk(path)
        for f in files
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
        and os.path.getmtime(os.path.join(root, f)) > last_trained_ts
    ])

def should_train(last_trained_ts: float, new_images: int) -> bool:
    now = time.time()

    # תנאי 1: זמן
    time_ok = False
    if last_trained_ts is None:
        time_ok = True
    else:
        hours_passed = (now - last_trained_ts) / 3600
        time_ok = hours_passed >= MIN_HOURS_BETWEEN_TRAINING

    # תנאי 2: נוספו מספיק תמונות חדשות
    count_ok = new_images >= MIN_NEW_IMAGES

    return time_ok or count_ok

def update_meta(meta_path: str):
    with open(meta_path, "w") as f:
        json.dump({
            "last_trained": time.time()
        }, f)

def call_cloud_training_function(user_id: int, camera_type: str):
    url = "https://us-central1-babycam-colab-deploy.cloudfunctions.net/trigger_colab_training"
    payload = {
        "user_id": user_id,
        "camera_type": camera_type
    }
    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        print(f"[CLOUD TRAIN] Triggered cloud training for {user_id} / {camera_type}")
    except Exception as e:
        print(f"[CLOUD TRAIN ERROR] {e}")

def process_user_camera(user_id: int, camera_type: str):
    """
    בדוק האם צריך לאמן מחדש עבור מצלמה מסוג מסוים של משתמש.
    """
    base_path = f"uploads/training_data/{user_id}/{camera_type}"
    images_path = os.path.join(base_path, "objects" if camera_type == "head_camera" else "scenes")
    meta_path = os.path.join(base_path, "meta.json")

    # זמן אימון קודם (אם יש)
    if os.path.exists(meta_path):
        with open(meta_path, "r") as f:
            meta = json.load(f)
            last_trained_ts = meta.get("last_trained", None)
    else:
        last_trained_ts = None

    # חשב כמה תמונות חדשות נוספו מאז
    new_images = count_new_images_since(images_path, last_trained_ts or 0)

    if should_train(last_trained_ts, new_images):
        print(f"[TRAINING] user {user_id} / {camera_type} | {new_images} new images")
        # שלב 1: צור את dataset.yaml
        create_dataset_yaml(user_id, camera_type)

        # שלב 2: צור ZIP
        zip_path = zip_dataset(user_id, camera_type)

        # שלב 3: העלה ל־Google Drive
        upload_to_drive(zip_path)

        call_cloud_training_function(user_id, camera_type)

        # שלב 4: עדכן את זמן האימון האחרון
        update_meta(meta_path)
    else:
        print(f"[SKIP] user {user_id} / {camera_type} | {new_images} new images")

def process_all_users(base_upload_dir="uploads/training_data"):
    """
    עבור על כל המשתמשים וכל סוגי המצלמות ובדוק אם צריך לאמן.
    """
    for user_id in os.listdir(base_upload_dir):
        user_path = os.path.join(base_upload_dir, user_id)
        if not os.path.isdir(user_path):
            continue

        for camera_type in ["head_camera", "static_camera"]:
            camera_path = os.path.join(user_path, camera_type)
            if os.path.exists(camera_path):
                process_user_camera(int(user_id), camera_type)
