import json
from app.routes.realtime_routes import manager

# Sends a real-time detection event to the user's connected WebSocket clients.
async def broadcast_detection(user_id: int, event_data: dict):
    """
    Broadcasts a detection event to a specific user via WebSocket.
    
    Args:
        user_id (int): The ID of the user to send the message to.
        event_data (dict): The detection data to send (e.g., detection_id, class, risk_level).
    """
    # Convert the dictionary to a JSON string
    message = json.dumps(event_data)

    # Send the message to all active WebSocket connections of the user
    await manager.send_personal_message(user_id, message)
