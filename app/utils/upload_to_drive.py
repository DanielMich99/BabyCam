import os
import zipfile
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from app.utils.google_drive_service import GoogleDriveService

drive_service = GoogleDriveService()

def zip_dataset(baby_profile_id: int, camera_type: str) -> str:
    base_dir = f"uploads/training_data/{baby_profile_id}/{camera_type}"
    zip_path = f"{baby_profile_id}_{camera_type}.zip"

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, _, files in os.walk(base_dir):
            for file in files:
                filepath = os.path.join(root, file)

                # תנאים:
                # 1. בתוך images/
                # 2. בתוך labels/
                # 3. בדיוק dataset.yaml בקובץ הראשי
                if (
                    filepath.startswith(os.path.join(base_dir, "images")) or
                    filepath.startswith(os.path.join(base_dir, "labels")) or
                    filepath == os.path.join(base_dir, "dataset.yaml")
                ):
                    arcname = os.path.relpath(filepath, start=base_dir)
                    print(f"[ZIP] Adding {arcname}")
                    zipf.write(filepath, arcname)

    print(f"[ZIP] Created {zip_path}")
    return zip_path

def cleanup_zip(baby_profile_id: int, camera_type: str):
    zip_path = f"{baby_profile_id}_{camera_type}.zip"
    if os.path.exists(zip_path):
        os.remove(zip_path)
        print(f"[CLEANUP] Deleted local zip file: {zip_path}")
    else:
        print(f"[CLEANUP] No zip file found to delete: {zip_path}")

def upload_to_drive(local_zip_path: str, baby_profile_id: int, model_type: str, drive_base_folder: str = "babycam_data"):
    root_folder_id = drive_service.get_or_create_folder(drive_base_folder)
    profile_folder_id = drive_service.get_or_create_folder(str(baby_profile_id), root_folder_id)
    model_folder_id = drive_service.get_or_create_folder(model_type, profile_folder_id)

    drive_service.upload_file(local_zip_path, model_folder_id)