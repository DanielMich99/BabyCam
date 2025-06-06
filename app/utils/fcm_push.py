import json
import requests
from google.auth.transport.requests import Request
from google.oauth2 import service_account
from database.database import SessionLocal
from app.models.user_model import UserFCMToken

'''def send_push_notification(token: str, title: str, body: str, project_id: str, credentials_path: str):
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
        print("[FCM SUCCESS] Notification sent to", token)'''

def send_push_notifications(tokens: list[str], title: str, body: str, project_id: str, credentials_path: str):
    """
    Sends push notifications to multiple devices using FCM HTTP v1 API.
    Removes invalid tokens automatically if db session provided.
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

    for token in tokens:
        message = {
            "message": {
                "token": token,
                "notification": {
                    "title": title,
                    "body": body
                }
            }
        }
        try:
            response = requests.post(url, headers=headers, data=json.dumps(message))
            response.raise_for_status()
            print("[FCM SUCCESS] Notification sent to", token)
        except requests.exceptions.RequestException as e:
            print("[FCM ERROR]", e)
            if response is not None and response.status_code == 404:
                print("[FCM REMOVE] Token not registered:", token)
                try:
                    db = SessionLocal()
                    token_obj = db.query(UserFCMToken).filter_by(token=token).first()
                    if token_obj:
                        db.delete(token_obj)
                        db.commit()
                except Exception as db_err:
                    print("[DB ERROR]", db_err)
                finally:
                    db.close()