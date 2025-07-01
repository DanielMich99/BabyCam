import os
import time
import io
import ssl
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload, MediaIoBaseDownload
from googleapiclient.errors import HttpError

# Google Drive API scope
SCOPES = ['https://www.googleapis.com/auth/drive']

# Path to service account credentials JSON file
SERVICE_ACCOUNT_FILE = os.path.join(
    os.path.dirname(os.path.dirname(__file__)),
    'credentials',
    'babycam-colab-deploy-f71bda72f9f3.json'
)

class GoogleDriveService:
    def __init__(self):
        # Authenticate using service account credentials
        credentials = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE, scopes=SCOPES)
        self.service = build('drive', 'v3', credentials=credentials)

    def get_or_create_folder(self, folder_name, parent_id=None, max_retries=5):
        """
        Looks for an existing folder with the given name (and optional parent).
        If not found, creates it. Includes retry mechanism.
        """
        query = f"mimeType='application/vnd.google-apps.folder' and name='{folder_name}' and trashed=false"
        if parent_id:
            query += f" and '{parent_id}' in parents"

        for attempt in range(max_retries):
            try:
                results = self.service.files().list(q=query, fields="files(id)").execute()
                files = results.get('files', [])
                break
            except Exception as e:
                print(f"[GET_OR_CREATE_FOLDER - LIST ERROR] Attempt {attempt+1}: {e}")
                time.sleep(2 ** attempt)
        else:
            raise Exception(f"Failed to list folder after {max_retries} retries")

        if files:
            return files[0]['id']  # Return existing folder ID

        file_metadata = {
            'name': folder_name,
            'mimeType': 'application/vnd.google-apps.folder'
        }
        if parent_id:
            file_metadata['parents'] = [parent_id]

        for attempt in range(max_retries):
            try:
                folder = self.service.files().create(body=file_metadata, fields="id").execute()
                return folder['id']
            except Exception as e:
                print(f"[GET_OR_CREATE_FOLDER - CREATE ERROR] Attempt {attempt+1}: {e}")
                time.sleep(2 ** attempt)

        raise Exception(f"Failed to create folder after {max_retries} retries")

    def upload_file(self, local_file_path: str, parent_folder_id: str, max_retries=5):
        """
        Uploads a file to a specified folder in Drive.
        If a file with the same name exists, it is deleted first.
        """
        file_name = os.path.basename(local_file_path)

        # Step 1: Delete any existing file with the same name
        query = f"'{parent_folder_id}' in parents and name='{file_name}' and trashed=false"
        try:
            results = self.service.files().list(q=query, fields="files(id)").execute()
            existing_files = results.get('files', [])
            for file in existing_files:
                print(f"[UPLOAD] Found existing file '{file_name}' (id: {file['id']}), deleting before upload...")
                self.service.files().delete(fileId=file['id']).execute()
        except Exception as e:
            print(f"[UPLOAD WARNING] Failed to check & delete existing files: {e}")

        # Step 2: Upload file with retry
        file_metadata = {
            'name': file_name,
            'parents': [parent_folder_id]
        }
        media = MediaFileUpload(local_file_path, resumable=True)

        for attempt in range(max_retries):
            try:
                file = self.service.files().create(body=file_metadata, media_body=media, fields='id').execute()
                print(f"[DRIVE] Uploaded {file_name}")
                return file.get('id')
            except (HttpError, ssl.SSLEOFError, Exception) as e:
                print(f"[UPLOAD ERROR] Attempt {attempt+1}: {e}")
                time.sleep(2 ** attempt)

        raise Exception(f"Upload failed after {max_retries} retries")

    def download_file(self, file_id: str, destination_path: str, max_retries=5):
        """
        Downloads a file from Google Drive to a local path using its file ID.
        Includes retry and download progress logging.
        """
        for attempt in range(max_retries):
            try:
                request = self.service.files().get_media(fileId=file_id)
                fh = io.FileIO(destination_path, 'wb')
                downloader = MediaIoBaseDownload(fh, request)

                done = False
                while not done:
                    status, done = downloader.next_chunk()
                    if status:
                        print(f"[DOWNLOAD] Download {int(status.progress() * 100)}%")
                return
            except (HttpError, ssl.SSLEOFError, Exception) as e:
                print(f"[DOWNLOAD ERROR] Attempt {attempt+1}: {e}")
                time.sleep(2 ** attempt)

        raise Exception(f"Download failed after {max_retries} retries")

    def delete_baby_profile_folder(self, baby_profile_id: int, root_folder_name="babycam_data", max_retries=5):
        """
        Deletes the folder for a specific baby_profile_id from the babycam_data root folder in Drive.
        """
        try:
            # Step 1: Locate the root folder ID
            root_folder_id = self.get_or_create_folder(root_folder_name)

            # Step 2: Build the name of the baby profile folder (by ID)
            folder_name = str(baby_profile_id)

            # Step 3: Search for the specific profile folder
            query = f"mimeType='application/vnd.google-apps.folder' and name='{folder_name}' and '{root_folder_id}' in parents and trashed=false"
            results = self.service.files().list(q=query, fields="files(id)").execute()
            folders = results.get('files', [])

            if not folders:
                print(f"[DELETE] No folder found for baby_profile_id {baby_profile_id}")
                return False

            folder_id = folders[0]['id']

            # Step 4: Attempt to delete the folder
            for attempt in range(max_retries):
                try:
                    self.service.files().delete(fileId=folder_id).execute()
                    print(f"[DELETE] Successfully deleted folder for baby_profile_id {baby_profile_id}")
                    return True
                except Exception as e:
                    print(f"[DELETE ERROR] Attempt {attempt+1}: {e}")
                    time.sleep(2 ** attempt)

            raise Exception(f"Failed to delete folder after {max_retries} retries")

        except Exception as e:
            print(f"[DELETE FOLDER FAILED] {e}")
            return False
