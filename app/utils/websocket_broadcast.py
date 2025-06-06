import json
from app.routes.realtime_routes import manager

async def broadcast_detection(user_id: int, event_data: dict):
    message = json.dumps(event_data)
    await manager.send_personal_message(user_id, message)
