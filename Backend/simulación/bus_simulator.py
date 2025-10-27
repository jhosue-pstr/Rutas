# simulación/bus_simulator.py
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
        self.simulacion_activa = False
        print("✅ BusSimulator inicializado")
        
    async def iniciar_simulacion(self):
        """Inicia la simulación de todos los buses"""
        print("🎯 INICIANDO SIMULACIÓN DE BUSES...")
        self.simulacion_activa = True
        
        try:
            # Usar la sesión que ya tenemos
            buses = self.session.exec(select(Bus)).all()
            print(f"📊 Total de buses en BD: {len(buses)}")
            
            buses_con_ruta = [b for b in buses if b.RutaId is not None]
            print(f"🎯 Buses con ruta asignada: {len(buses_con_ruta)}")
            
            for bus in buses_con_ruta:
                print(f"🚌 Inicializando bus {bus.IdBus} (Ruta {bus.RutaId})")
                await self._inicializar_bus(bus)
            
            print(f"🚀 Simulación activa con {len(self.buses_activos)} buses")
            
            # Simulación continua
            while self.simulacion_activa:
                await self._actualizar_ubicaciones()
                await asyncio.sleep(3)  # Reducido a 3 segundos
                
        except Exception as e:
            print(f"❌ ERROR en simulación: {e}")
            import traceback
            traceback.print_exc()
        finally:
            self.simulacion_activa = False
    
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
                    'latitud': punto_inicial.Latitud,
                    'longitud': punto_inicial.Longitud,
                    'punto_actual': 0,
                    'puntos_ruta': puntos,
                    'velocidad': random.uniform(0.0001, 0.0003),
                    'direccion': 1,
                    'proximo_punto': 0,
                    'ultima_actualizacion': datetime.now()
                }
                print(f"   ✅ Bus {bus.IdBus} activo en: {punto_inicial.Latitud:.4f}, {punto_inicial.Longitud:.4f}")
            else:
                print(f"   ❌ No hay puntos de ruta para bus {bus.IdBus}")
                
        except Exception as e:
            print(f"   ❌ Error inicializando bus {bus.IdBus}: {e}")
    
    async def _actualizar_ubicaciones(self):
        """Actualiza las ubicaciones de todos los buses"""
        try:
            for bus_id, datos in list(self.buses_activos.items()):
                await self._mover_bus(bus_id, datos)
        except Exception as e:
            print(f"❌ Error actualizando ubicaciones: {e}")
    
    async def _mover_bus(self, bus_id: int, datos: dict):
        """Mueve un bus a lo largo de su ruta"""
        try:
            puntos = datos['puntos_ruta']
            if not puntos:
                return
            
            # Obtener punto actual y siguiente
            punto_actual_idx = datos['proximo_punto']
            siguiente_idx = (punto_actual_idx + 1) % len(puntos)
            
            punto_actual = puntos[punto_actual_idx]
            siguiente_punto = puntos[siguiente_idx]
            
            # Calcular dirección
            lat_actual, lon_actual = datos['latitud'], datos['longitud']
            lat_destino, lon_destino = siguiente_punto.Latitud, siguiente_punto.Longitud
            
            # Calcular distancia
            distancia = self._calcular_distancia(lat_actual, lon_actual, lat_destino, lon_destino)
            
            # Si está muy cerca, pasar al siguiente punto
            if distancia < 0.0001:  # Aproximadamente 11 metros
                datos['proximo_punto'] = siguiente_idx
                # Pequeña pausa en el paradero
                await asyncio.sleep(0.5)
            else:
                # Mover hacia el siguiente punto
                factor = datos['velocidad'] / max(distancia, 0.0001)
                factor = min(factor, 1.0)  # No pasar del punto destino
                
                nueva_lat = lat_actual + (lat_destino - lat_actual) * factor
                nueva_lon = lon_actual + (lon_destino - lon_actual) * factor
                
                datos['latitud'] = nueva_lat
                datos['longitud'] = nueva_lon
                datos['ultima_actualizacion'] = datetime.now()
                
        except Exception as e:
            print(f"❌ Error moviendo bus {bus_id}: {e}")
    
    def _calcular_distancia(self, lat1, lon1, lat2, lon2):
        """Calcula distancia euclidiana simplificada"""
        return ((lat2 - lat1) ** 2 + (lon2 - lon1) ** 2) ** 0.5
    
    def obtener_ubicaciones(self):
        """Obtiene las ubicaciones actuales de todos los buses"""
        ubicaciones = {}
        for bus_id, datos in self.buses_activos.items():
            ubicaciones[bus_id] = {
                'bus_id': bus_id,
                'latitud': datos['latitud'],
                'longitud': datos['longitud'],
                'placa': datos['bus'].placa,
                'ruta_id': datos['bus'].RutaId,
                'ultima_actualizacion': datos['ultima_actualizacion'].isoformat()
            }
        return ubicaciones
    
    def detener_simulacion(self):
        """Detiene la simulación"""
        self.simulacion_activa = False
        print("🛑 Simulación detenida")