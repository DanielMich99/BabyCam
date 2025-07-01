from typing import Dict, List
from fastapi import WebSocket

# Manages WebSocket connections per user (supports multiple clients per user)
class ConnectionManager:
    def __init__(self):
        # Dictionary: user_id → list of active WebSocket connections
        self.active_connections: Dict[int, List[WebSocket]] = {}

    # Add a new WebSocket connection for a given user
    async def connect(self, user_id: int, websocket: WebSocket):
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)

    # Remove a WebSocket connection for a given user
    def disconnect(self, user_id: int, websocket: WebSocket):
        if user_id in self.active_connections:
            self.active_connections[user_id].remove(websocket)
            # Clean up if no connections remain for the user
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

    # Send a message only to all WebSocket clients connected for a specific user
    async def send_personal_message(self, user_id: int, message: str):
        clients = self.active_connections.get(user_id, [])
        for connection in clients:
            await connection.send_text(message)

    # Broadcast a message to all connected clients across all users
    async def broadcast(self, message: str):
        for clients in self.active_connections.values():
            for connection in clients:
                await connection.send_text(message)
