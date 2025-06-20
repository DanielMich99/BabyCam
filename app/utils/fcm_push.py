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
            resp_json = response.json()

            # בדיקה אם FCM מחזיר שגיאה בתוך תגובה תקינה
            if 'error' in resp_json:
                error_message = resp_json['error'].get('message', '').lower()
                if 'requested entity was not found' in error_message or 'notregistered' in error_message:
                    print("[FCM REMOVE] Invalid token detected:", token)
                    _delete_token_from_db(token)

                else:
                    print("[FCM ERROR] Other FCM error:", resp_json['error'])
            else:
                print("[FCM SUCCESS] Notification sent to", token)
                
        except requests.exceptions.RequestException as e:
            print("[FCM EXCEPTION] HTTP error for token", token, "->", e)

            try:
                resp_json = response.json()
                error_message = resp_json.get('error', {}).get('message', '').lower()
                if 'requested entity was not found' in error_message or 'notregistered' in error_message:
                    print("[FCM REMOVE] Invalid token detected (from error response):", token)
                    _delete_token_from_db(token)
            except Exception as parse_err:
                print("[FCM ERROR] Failed to parse error response:", parse_err)

def _delete_token_from_db(token: str):
    try:
        db = SessionLocal()
        token_obj = db.query(UserFCMToken).filter_by(token=token).first()
        if token_obj:
            db.delete(token_obj)
            db.commit()
            print("[DB] Token deleted:", token)
        else:
            print("[DB] Token not found in DB:", token)
    except Exception as db_err:
        print("[DB ERROR]", db_err)
    finally:
        db.close()