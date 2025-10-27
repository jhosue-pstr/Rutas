# routers/simulacion.py
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from sqlmodel import Session
from config.database import get_session
from simulación.bus_simulator import BusSimulator
from simulación.websocket_manager import manager
import asyncio

router = APIRouter()
bus_simulator = None

@router.on_event("startup")
async def startup_event():
    """Inicia el simulador cuando arranca la app"""
    global bus_simulator
    session = next(get_session())
    bus_simulator = BusSimulator(session)
    
    # Ejecutar simulación en segundo plano
    asyncio.create_task(bus_simulator.iniciar_simulacion())
    
    # Ejecutar broadcasting de ubicaciones
    asyncio.create_task(broadcast_continuo())

async def broadcast_continuo():
    """Envía ubicaciones cada 3 segundos a los clientes"""
    while True:
        if bus_simulator:
            ubicaciones = bus_simulator.obtener_ubicaciones()
            await manager.broadcast_ubicaciones(ubicaciones)
        await asyncio.sleep(3)

@router.websocket("/ws/ubicaciones-buses")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket para recibir ubicaciones en tiempo real"""
    await manager.connect(websocket)
    try:
        while True:
            # Mantener conexión activa
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)

@router.get("/simulacion/ubicaciones")
def obtener_ubicaciones_actuales():
    """Endpoint HTTP para obtener ubicaciones actuales"""
    if bus_simulator:
        return bus_simulator.obtener_ubicaciones()
    return {}