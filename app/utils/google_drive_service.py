import os
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

SCOPES = ['https://www.googleapis.com/auth/drive']
SERVICE_ACCOUNT_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'credentials', 'babycam-colab-deploy-f71bda72f9f3.json')  # כאן לשים את הנתיב האמיתי

class GoogleDriveService:
    def __init__(self):
        credentials = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE, scopes=SCOPES)
        self.service = build('drive', 'v3', credentials=credentials)

    def get_or_create_folder(self, folder_name, parent_id=None):
        query = f"mimeType='application/vnd.google-apps.folder' and name='{folder_name}' and trashed=false"
        if parent_id:
            query += f" and '{parent_id}' in parents"

        results = self.service.files().list(q=query, fields="files(id)").execute()
        files = results.get('files', [])

        if files:
            return files[0]['id']
        
        file_metadata = {
            'name': folder_name,
            'mimeType': 'application/vnd.google-apps.folder'
        }
        if parent_id:
            file_metadata['parents'] = [parent_id]

        folder = self.service.files().create(body=file_metadata, fields="id").execute()
        return folder['id']

    def upload_file(self, local_file_path: str, parent_folder_id: str):
        file_name = os.path.basename(local_file_path)
        file_metadata = {
            'name': file_name,
            'parents': [parent_folder_id]
        }
        media = MediaFileUpload(local_file_path, resumable=True)
        file = self.service.files().create(body=file_metadata, media_body=media, fields='id').execute()

        print(f"[DRIVE] Uploaded {file_name}")
        return file.get('id')