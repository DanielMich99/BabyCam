import json
import requests
from google.auth.transport.requests import Request
from google.oauth2 import service_account

def send_push_notification(token: str, title: str, body: str, project_id: str, credentials_path: str):
    """
    Sends a push notification using FCM HTTP v1 API.
    """
    credentials = service_account.Credentials.from_service_account_file(
        credentials_path,
        scopes=["https://www.googleapis.com/auth/firebase.messaging"]
    )

    credentials.refresh(Request())
    access_token = credentials.token

    url = f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    message = {
        "message": {
            "token": token,
            "notification": {
                "title": title,
                "body": body
            }
        }
    }

    response = requests.post(url, headers=headers, data=json.dumps(message))

    if response.status_code != 200:
        print("[FCM ERROR]", response.status_code, response.text)
    else:
        print("[FCM SUCCESS] Notification sent to", token)