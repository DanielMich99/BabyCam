import json
import requests
from google.auth.transport.requests import Request
from google.oauth2 import service_account
from database.database import SessionLocal
from app.models.user_model import UserFCMToken

def send_push_notifications(
    tokens: list[str],
    base_message_json: dict,
    project_id: str,
    credentials_path: str
):
    """
    Sends push notifications to multiple devices using Firebase Cloud Messaging (HTTP v1 API).
    Expects a base_message_json (without the 'token') which is added per device before sending.
    """
    # Load service account credentials and generate access token
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

    # Iterate through all device tokens and send the message individually
    for token in tokens:
        message = {
            "message": {
                "token": token,  # Attach the current token
                **base_message_json["message"]  # Merge base message content
            }
        }

        try:
            print(f"[FCM DEBUG] Sending message to token: {token[:20]}...")
            print(f"[FCM DEBUG] Message payload: {json.dumps(message, indent=2)}")

            response = requests.post(url, headers=headers, data=json.dumps(message))

            print(f"[FCM DEBUG] Response status: {response.status_code}")
            print(f"[FCM DEBUG] Response headers: {dict(response.headers)}")

            # Handle errors or success
            if response.status_code != 200:
                print(f"[FCM ERROR] HTTP {response.status_code}: {response.text}")
                try:
                    error_json = response.json()
                    print(f"[FCM ERROR] Error details: {json.dumps(error_json, indent=2)}")

                    if 'error' in error_json:
                        error_message = error_json['error'].get('message', '').lower()

                        # Remove invalid or unregistered tokens from DB
                        if 'requested entity was not found' in error_message or 'notregistered' in error_message:
                            print("[FCM REMOVE] Invalid token detected:", token)
                            _delete_token_from_db(token)

                        elif 'invalid argument' in error_message:
                            print("[FCM ERROR] Invalid message format - check payload structure")

                        else:
                            print(f"[FCM ERROR] Other FCM error: {error_json['error']}")

                except Exception as parse_err:
                    print(f"[FCM ERROR] Failed to parse error response: {parse_err}")
                    print(f"[FCM ERROR] Raw response: {response.text}")
            else:
                print("[FCM SUCCESS] Notification sent to", token)

        except requests.exceptions.RequestException as e:
            print(f"[FCM EXCEPTION] HTTP error for token {token[:20]}... -> {e}")
            if hasattr(e, 'response') and e.response is not None:
                try:
                    error_json = e.response.json()
                    error_message = error_json.get('error', {}).get('message', '').lower()
                    if 'requested entity was not found' in error_message or 'notregistered' in error_message:
                        print("[FCM REMOVE] Invalid token detected (from exception):", token)
                        _delete_token_from_db(token)
                except Exception as parse_err:
                    print(f"[FCM ERROR] Failed to parse exception response: {parse_err}")


def _delete_token_from_db(token: str):
    """
    Removes an invalid or expired FCM token from the database.
    """
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
