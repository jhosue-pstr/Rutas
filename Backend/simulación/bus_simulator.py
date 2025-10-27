import asyncio
import random
import time
from datetime import datetime
from sqlmodel import Session, select
from models.bus import Bus
from models.ruta import Ruta
from models.punto_ruta import PuntoRuta

class BusSimulator:
    def __init__(self, session: Session):
        self.session = session
        self.buses_activos = {}
        print("✅ BusSimulator inicializado")
        
    async def iniciar_simulacion(self):
        """Inicia la simulación de todos los buses"""
        print("🎯 INICIANDO SIMULACIÓN DE BUSES...")
        
        try:
            buses = self.session.exec(select(Bus)).all()
            print(f"📊 Total de buses en BD: {len(buses)}")
            
            buses_con_ruta = [b for b in buses if b.RutaId is not None]
            print(f"🎯 Buses con ruta asignada: {len(buses_con_ruta)}")
            
            for bus in buses_con_ruta:
                print(f"🚌 Inicializando bus {bus.IdBus} (Ruta {bus.RutaId})")
                await self._inicializar_bus(bus)
            
            print(f"🚀 Simulación activa con {len(self.buses_activos)} buses")
            
            # Simulación continua
            while True:
                await self._actualizar_ubicaciones()
                await asyncio.sleep(5)  # Actualizar cada 5 segundos
                
        except Exception as e:
            print(f"❌ ERROR en simulación: {e}")
    
    async def _inicializar_bus(self, bus: Bus):
        """Inicializa un bus en una posición aleatoria de su ruta"""
        try:
            ruta = self.session.get(Ruta, bus.RutaId)
            if not ruta:
                print(f"   ❌ Ruta {bus.RutaId} no encontrada para bus {bus.IdBus}")
                return
                
            puntos = self.session.exec(
                select(PuntoRuta).where(PuntoRuta.RutaId == bus.RutaId)
            ).all()
            
            print(f"   📍 Puntos de ruta encontrados: {len(puntos)}")
            
            if puntos:
                punto_inicial = random.choice(puntos)
                self.buses_activos[bus.IdBus] = {
                    'bus': bus,
                    'latitud': punto_inicial.latitud,
                    'longitud': punto_inicial.longitud,
                    'punto_actual': 0,
                    'puntos_ruta': puntos,
                    'velocidad': random.uniform(0.0001, 0.0003),
                    'direccion': 1
                }
                print(f"   ✅ Bus {bus.IdBus} activo en: {punto_inicial.latitud:.4f}, {punto_inicial.longitud:.4f}")
            else:
                print(f"   ❌ No hay puntos de ruta para bus {bus.IdBus}")
                
        except Exception as e:
            print(f"   ❌ Error inicializando bus {bus.IdBus}: {e}")
    
    async def _actualizar_ubicaciones(self):
        """Actualiza la ubicación de todos los buses activos"""
        for bus_id, datos in self.buses_activos.items():
            try:
                puntos = datos['puntos_ruta']
                punto_actual = datos['punto_actual']
                
                if 0 <= punto_actual < len(puntos) - 1:
                    punto_obj = puntos[punto_actual]
                    next_punto = puntos[punto_actual + datos['direccion']]
                    
                    # Mover el bus
                    datos['latitud'] += (next_punto.latitud - punto_obj.latitud) * datos['velocidad']
                    datos['longitud'] += (next_punto.longitud - punto_obj.longitud) * datos['velocidad']
                    
                    # Verificar si llegó al siguiente punto
                    distancia = self._calcular_distancia(
                        datos['latitud'], datos['longitud'],
                        next_punto.latitud, next_punto.longitud
                    )
                    
                    if distancia < 0.001:
                        datos['punto_actual'] += datos['direccion']
                        
                        # Cambiar dirección en los extremos
                        if datos['punto_actual'] >= len(puntos) - 1:
                            datos['direccion'] = -1
                        elif datos['punto_actual'] <= 0:
                            datos['direccion'] = 1
                            
            except Exception as e:
                print(f"❌ Error actualizando bus {bus_id}: {e}")
    
    def _calcular_distancia(self, lat1, lon1, lat2, lon2):
        return ((lat2 - lat1) ** 2 + (lon2 - lon1) ** 2) ** 0.5
    
    def obtener_ubicaciones(self):
        return {
            bus_id: {
                'bus_id': bus_id,
                'latitud': datos['latitud'],
                'longitud': datos['longitud'],
                'placa': datos['bus'].placa,
                'ruta_id': datos['bus'].RutaId
            }
            for bus_id, datos in self.buses_activos.items()
        }