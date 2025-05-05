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
                arcname = os.path.relpath(filepath, start=base_dir)  # יחסית לתוך ה-ZIP
                print(f"Zipping {arcname}")
                zipf.write(filepath, arcname)

    print(f"[ZIP] Created {zip_path}")
    return zip_path

def upload_to_drive(local_zip_path: str, drive_folder_name: str = "babycam_data"):
    # Step 1: התחברות עם הרשאות גוגל (יפתח לך חלון דפדפן פעם ראשונה)
    gauth = GoogleAuth()
    gauth.LocalWebserverAuth()
    drive = GoogleDrive(gauth)

    # Step 2: מצא או צור תיקייה בשם babycam_data
    folder_id = None
    file_list = drive.ListFile({'q': "mimeType='application/vnd.google-apps.folder' and trashed=false"}).GetList()
    for folder in file_list:
        if folder['title'] == drive_folder_name:
            folder_id = folder['id']
            break

    if not folder_id:
        folder_metadata = {
            'title': drive_folder_name,
            'mimeType': 'application/vnd.google-apps.folder'
        }
        folder = drive.CreateFile(folder_metadata)
        folder.Upload()
        folder_id = folder['id']
        print(f"[DRIVE] Created folder '{drive_folder_name}'")

    # Step 3: העלאת הקובץ לדרייב
    file_name = os.path.basename(local_zip_path)
    gfile = drive.CreateFile({
        'title': file_name,
        'parents': [{'id': folder_id}]
    })
    gfile.SetContentFile(local_zip_path)
    gfile.Upload()
    print(f"[DRIVE] Uploaded {file_name} to folder '{drive_folder_name}'")

# דוגמה לשימוש
if __name__ == "__main__":
    user_id = 123
    camera_type = "head_camera"

    zip_path = zip_dataset(user_id, camera_type)
    upload_to_drive(zip_path)
