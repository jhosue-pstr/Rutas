from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from sqlmodel import Session
from config.database import get_session
from simulación.bus_simulator import BusSimulator
from simulación.websocket_manager import manager
import asyncio
import threading

router = APIRouter()
bus_simulator = None
simulation_task = None

def iniciar_simulacion_en_segundo_plano():
    """Inicia la simulación en un hilo separado"""
    global bus_simulator
    
    try:
        print("🎬 INICIANDO SIMULADOR EN SEGUNDO PLANO...")
        session = next(get_session())
        bus_simulator = BusSimulator(session)
        
        # Crear event loop para el hilo
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        # Ejecutar simulación
        loop.run_until_complete(bus_simulator.iniciar_simulacion())
    except Exception as e:
        print(f"❌ ERROR EN SIMULADOR: {e}")

@router.on_event("startup")
async def startup_event():
    """Inicia el simulador cuando arranca la app"""
    global simulation_task
    
    print("🚀 INICIANDO SIMULADOR DE BUSES...")
    
    # Iniciar simulación en un hilo separado
    simulation_thread = threading.Thread(target=iniciar_simulacion_en_segundo_plano)
    simulation_thread.daemon = True  # Para que se cierre cuando la app se cierre
    simulation_thread.start()
    
    # Iniciar broadcasting en el hilo principal
    asyncio.create_task(broadcast_continuo())
    
    print("✅ SIMULADOR INICIADO EN SEGUNDO PLANO")

async def broadcast_continuo():
    """Envía ubicaciones cada 3 segundos a los clientes"""
    while True:
        if bus_simulator:
            try:
                ubicaciones = bus_simulator.obtener_ubicaciones()
                if ubicaciones:  # Solo enviar si hay datos
                    await manager.broadcast_ubicaciones(ubicaciones)
                    print(f"📤 Broadcast: {len(ubicaciones)} buses")
            except Exception as e:
                print(f"❌ Error en broadcast: {e}")
        await asyncio.sleep(3)

@router.websocket("/ws/ubicaciones-buses")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket para recibir ubicaciones en tiempo real"""
    await manager.connect(websocket)
    print("🔌 Nuevo cliente conectado via WebSocket")
    try:
        while True:
            # Mantener conexión activa
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        print("🔌 Cliente desconectado")

@router.get("/simulacion/ubicaciones")
def obtener_ubicaciones_actuales():
    """Endpoint HTTP para obtener ubicaciones actuales"""
    if bus_simulator:
        ubicaciones = bus_simulator.obtener_ubicaciones()
        print(f"📍 Endpoint HTTP: {len(ubicaciones)} buses")
        return ubicaciones
    return {"error": "Simulador no inicializado"}

@router.get("/simulacion/estado")
def estado_simulacion():
    """Endpoint para ver el estado del simulador"""
    if bus_simulator:
        return {
            "estado": "activo",
            "buses_activos": len(bus_simulator.buses_activos),
            "buses": bus_simulator.obtener_ubicaciones()
        }
    return {"estado": "inactivo"}