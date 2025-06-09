import os
import time
import io
import ssl
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload, MediaIoBaseDownload
from googleapiclient.errors import HttpError

SCOPES = ['https://www.googleapis.com/auth/drive']
SERVICE_ACCOUNT_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'credentials', 'babycam-colab-deploy-f71bda72f9f3.json')  # כאן לשים את הנתיב האמיתי

class GoogleDriveService:
    def __init__(self):
        credentials = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE, scopes=SCOPES)
        self.service = build('drive', 'v3', credentials=credentials)

    def get_or_create_folder(self, folder_name, parent_id=None, max_retries=5):
        query = f"mimeType='application/vnd.google-apps.folder' and name='{folder_name}' and trashed=false"
        if parent_id:
            query += f" and '{parent_id}' in parents"

        # --- שלב החיפוש עם retry ---
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
            return files[0]['id']
        
        file_metadata = {
            'name': folder_name,
            'mimeType': 'application/vnd.google-apps.folder'
        }
        if parent_id:
            file_metadata['parents'] = [parent_id]

        # --- שלב היצירה עם retry ---
        for attempt in range(max_retries):
            try:
                folder = self.service.files().create(body=file_metadata, fields="id").execute()
                return folder['id']
            except Exception as e:
                print(f"[GET_OR_CREATE_FOLDER - CREATE ERROR] Attempt {attempt+1}: {e}")
                time.sleep(2 ** attempt)

        raise Exception(f"Failed to create folder after {max_retries} retries")


    def upload_file(self, local_file_path: str, parent_folder_id: str, max_retries=5):
        file_name = os.path.basename(local_file_path)

        # שלב 1 - לבדוק אם קובץ כזה כבר קיים ולמחוק אותו לפני ההעלאה
        query = f"'{parent_folder_id}' in parents and name='{file_name}' and trashed=false"
        try:
            results = self.service.files().list(q=query, fields="files(id)").execute()
            existing_files = results.get('files', [])
            for file in existing_files:
                print(f"[UPLOAD] Found existing file '{file_name}' (id: {file['id']}), deleting before upload...")
                self.service.files().delete(fileId=file['id']).execute()
        except Exception as e:
            print(f"[UPLOAD WARNING] Failed to check & delete existing files: {e}")

        # שלב 2 - לבצע את ההעלאה עם retries
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
                time.sleep(2 ** attempt)  # Exponential backoff

        raise Exception(f"Download failed after {max_retries} retries")
