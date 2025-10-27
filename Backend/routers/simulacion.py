from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from sqlmodel import Session
from config.database import get_session, engine
from simulación.bus_simulator import BusSimulator
from simulación.websocket_manager import manager
import asyncio
import threading
import time
from sqlalchemy import text

router = APIRouter()
bus_simulator = None
simulation_task = None

def esperar_conexion_db():
    """Espera hasta que la base de datos esté disponible"""
    max_intentos = 30
    intento = 0
    
    while intento < max_intentos:
        try:
            # Crear una sesión temporal para probar la conexión
            with Session(engine) as session:
                session.exec(text("SELECT 1"))
                print("✅ Base de datos conectada")
                return True
        except Exception as e:
            intento += 1
            print(f"⏳ Esperando base de datos... (intento {intento}/{max_intentos}) - Error: {e}")
            time.sleep(2)
    
    print("❌ No se pudo conectar a la base de datos después de 30 intentos")
    return False

def iniciar_simulacion_en_segundo_plano():
    """Inicia la simulación en un hilo separado"""
    global bus_simulator
    
    try:
        print("🎬 INICIANDO SIMULADOR EN SEGUNDO PLANO...")
        
        # Esperar a que la DB esté lista
        if not esperar_conexion_db():
            print("❌ No se pudo conectar a la DB, cancelando simulación")
            return
        
        # Crear una sesión directamente con el engine
        session = Session(engine)
        bus_simulator = BusSimulator(session)
        
        # Crear event loop para el hilo
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        # Ejecutar simulación
        loop.run_until_complete(bus_simulator.iniciar_simulacion())
        
    except Exception as e:
        print(f"❌ ERROR EN SIMULADOR: {e}")
        import traceback
        traceback.print_exc()

@router.on_event("startup")
async def startup_event():
    """Inicia el simulador cuando arranca la app"""
    global simulation_task
    
    print("🚀 INICIANDO SIMULADOR DE BUSES...")
    
    # Iniciar simulación en un hilo separado
    simulation_thread = threading.Thread(target=iniciar_simulacion_en_segundo_plano)
    simulation_thread.daemon = True
    simulation_thread.start()
    
    # Iniciar broadcasting en el hilo principal después de un delay
    asyncio.create_task(broadcast_continuo())
    
    print("✅ SIMULADOR PROGRAMADO PARA INICIAR")

async def broadcast_continuo():
    """Envía ubicaciones cada 3 segundos a los clientes"""
    # Esperar un poco antes de empezar el broadcast
    await asyncio.sleep(15)
    print("📡 INICIANDO BROADCAST DE UBICACIONES...")
    
    while True:
        if bus_simulator:
            try:
                ubicaciones = bus_simulator.obtener_ubicaciones()
                if ubicaciones:  # Solo enviar si hay datos
                    await manager.broadcast_ubicaciones(ubicaciones)
                    print(f"📤 Broadcast: {len(ubicaciones)} buses")
                else:
                    print("📭 No hay buses activos para broadcast")
            except Exception as e:
                print(f"❌ Error en broadcast: {e}")
        else:
            print("⏳ Simulador no listo aún...")
        
        await asyncio.sleep(5)

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