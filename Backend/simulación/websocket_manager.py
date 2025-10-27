# simulación/websocket_manager.py
from fastapi import WebSocket
import json

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []
    
    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
    
    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
    
    async def broadcast_ubicaciones(self, ubicaciones: dict):
        """Envía las ubicaciones a todos los clientes conectados"""
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_json({
                    "type": "ubicaciones_buses",
                    "data": ubicaciones
                })
            except Exception as e:
                print(f"❌ Error enviando a cliente: {e}")
                disconnected.append(connection)
        
        # Remover conexiones desconectadas
        for connection in disconnected:
            self.disconnect(connection)

manager = ConnectionManager()