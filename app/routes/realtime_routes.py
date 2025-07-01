from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Request
from app.services.auth_service import verify_jwt_token
import json
from app.models.user_model import User
from database.database import SessionLocal
from app.utils.connection_manager import ConnectionManager
from datetime import datetime

router = APIRouter()

# Manages active WebSocket connections per user
manager = ConnectionManager()

# WebSocket endpoint for sending real-time detection alerts to the client
@router.websocket("/ws/detections")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    client = websocket.client
    client_info = f"{client.host}:{client.port}" if client else "unknown"
    user_id = None

    try:
        # Expect initial message from client with authentication token
        auth_message = await websocket.receive_text()
        data = json.loads(auth_message)
        token = data.get("token")

        if not token:
            # If token is missing, close connection with custom code
            await websocket.close(code=4001)
            return

        # Verify token and extract user info
        payload = verify_jwt_token(token)
        username = payload.get("sub")

        # Fetch user from DB based on username in token
        db = SessionLocal()
        user = db.query(User).filter(User.username == username).first()
        db.close()

        if not user:
            # Invalid token or user not found
            await websocket.close(code=4002)
            return

        user_id = user.id

        # Register connection
        await manager.connect(user_id, websocket)
        print(
            f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}][WEBSOCKET] Client connected: user_id={user_id}, address={client_info}"
        )

        # Keep the connection alive (even though client won't send anything else)
        while True:
            await websocket.receive_text()

    except WebSocketDisconnect:
        if user_id is not None:
            # On disconnect, unregister the connection
            manager.disconnect(user_id, websocket)
            print(
                f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}][WEBSOCKET] Client disconnected: user_id={user_id}, address={client_info}"
            )
        else:
            print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}][WEBSOCKET] Client disconnected before authentication: address={client_info}")
