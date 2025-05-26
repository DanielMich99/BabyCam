import os
import zipfile
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive

def zip_dataset(user_id: int, camera_type: str) -> str:
    base_dir = f"uploads/training_data/{user_id}/{camera_type}"
    zip_path = f"{user_id}_{camera_type}.zip"

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

def upload_to_drive(local_zip_path: str, baby_profile_id: int, model_type: str, drive_base_folder: str = "babycam_data"):
    gauth = GoogleAuth()
    gauth.LocalWebserverAuth()
    drive = GoogleDrive(gauth)

    def get_or_create_folder(parent_id, name):
        query = f"'{parent_id}' in parents and title = '{name}' and mimeType = 'application/vnd.google-apps.folder' and trashed=false"
        folders = drive.ListFile({'q': query}).GetList()
        if folders:
            return folders[0]['id']
        folder_metadata = {
            'title': name,
            'mimeType': 'application/vnd.google-apps.folder',
            'parents': [{'id': parent_id}]
        }
        folder = drive.CreateFile(folder_metadata)
        folder.Upload()
        return folder['id']

    # Step 1: Get or create base folder
    root_folders = drive.ListFile({'q': "mimeType='application/vnd.google-apps.folder' and trashed=false"}).GetList()
    root_folder = next((f for f in root_folders if f['title'] == drive_base_folder), None)
    if not root_folder:
        root = drive.CreateFile({'title': drive_base_folder, 'mimeType': 'application/vnd.google-apps.folder'})
        root.Upload()
        root_folder_id = root['id']
    else:
        root_folder_id = root_folder['id']

    # Step 2: Get or create nested structure: /baby_profile_id/model_type
    profile_folder_id = get_or_create_folder(root_folder_id, str(baby_profile_id))
    model_folder_id = get_or_create_folder(profile_folder_id, model_type)

    # Step 3: Upload file to nested folder
    file_name = os.path.basename(local_zip_path)
    gfile = drive.CreateFile({
        'title': file_name,
        'parents': [{'id': model_folder_id}]
    })
    gfile.SetContentFile(local_zip_path)
    gfile.Upload()
    print(f"[DRIVE] Uploaded {file_name} to Drive path: {drive_base_folder}/{baby_profile_id}/{model_type}")
    
# דוגמה לשימוש
if __name__ == "__main__":
    user_id = 123
    camera_type = "head_camera"

    zip_path = zip_dataset(user_id, camera_type)
    upload_to_drive(zip_path)
