from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Request
from app.services.auth_service import verify_jwt_token
import json
from app.models.user_model import User
from database.database import SessionLocal
from app.utils.connection_manager import ConnectionManager

router = APIRouter()

manager = ConnectionManager()

@router.websocket("/ws/detections")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    client = websocket.client
    client_info = f"{client.host}:{client.port}" if client else "unknown"
    user_id = None

    try:
        auth_message = await websocket.receive_text()
        data = json.loads(auth_message)
        token = data.get("token")

        if not token:
            await websocket.close(code=4001)
            return

        payload = verify_jwt_token(token)
        username = payload.get("sub")

        db = SessionLocal()
        user = db.query(User).filter(User.username == username).first()
        db.close()

        if not user:
            await websocket.close(code=4002)
            return

        user_id = user.id

        await manager.connect(user_id, websocket)
        print(
            f"[WEBSOCKET] Client connected: user_id={user_id}, address={client_info}"
        )

        while True:
            await websocket.receive_text()

    except WebSocketDisconnect:
        if user_id is not None:
            print(
                f"[WEBSOCKET] Client disconnected: user_id={user_id}, address={client_info}"
            )
            manager.disconnect(user_id, websocket)
        else:
            print(f"[WEBSOCKET] Client disconnected before authentication: address={client_info}")