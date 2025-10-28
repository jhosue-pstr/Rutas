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
            buses = self.session.exec(select(Bus)).all()
            print(f"📊 Total de buses en BD: {len(buses)}")
            
            buses_con_ruta = [b for b in buses if b.RutaId is not None]
            print(f"🎯 Buses con ruta asignada: {len(buses_con_ruta)}")
            
            for bus in buses_con_ruta:
                print(f"🚌 Inicializando bus {bus.IdBus} (Ruta {bus.RutaId})")
                await self._inicializar_bus(bus)
            
            print(f"🚀 Simulación activa con {len(self.buses_activos)} buses")
            
            while self.simulacion_activa:
                await self._actualizar_ubicaciones()
                await asyncio.sleep(3)
                
        except Exception as e:
            print(f"❌ ERROR en simulación: {e}")
            import traceback
            traceback.print_exc()
        finally:
            self.simulacion_activa = False
    
    async def _inicializar_bus(self, bus: Bus):
        """Inicializa un bus en el PRIMER punto de su ruta"""
        try:
            ruta = self.session.get(Ruta, bus.RutaId)
            if not ruta:
                print(f"   ❌ Ruta {bus.RutaId} no encontrada para bus {bus.IdBus}")
                return
                
            puntos = self.session.exec(
                select(PuntoRuta)
                .where(PuntoRuta.RutaId == bus.RutaId)
                .order_by(PuntoRuta.orden) 
            ).all()
            
            print(f"   📍 Puntos de ruta encontrados: {len(puntos)}")
            
            if puntos:
                punto_inicial = puntos[0]
                
                self.buses_activos[bus.IdBus] = {
                    'bus': bus,
                    'latitud': punto_inicial.latitud,
                    'longitud': punto_inicial.longitud,
                    'puntos_ruta': puntos, 
                    'punto_actual_idx': 0, 
                    'proximo_punto_idx': 1,  
                    'velocidad': random.uniform(0.0002, 0.0005),
                                        

                    'sentido': 1, 
                    'ultima_actualizacion': datetime.now(),
                    'en_paradero': False,
                    'tiempo_paradero': 0
                }
                print(f"   ✅ Bus {bus.IdBus} ({bus.placa}) activo en ruta {ruta.nombre}")
                print(f"   📍 Posición inicial (Punto 1): {punto_inicial.latitud:.6f}, {punto_inicial.longitud:.6f}")
                print(f"   🛣️  Ruta con {len(puntos)} puntos ordenados")
            else:
                print(f"   ❌ No hay puntos de ruta para bus {bus.IdBus} en ruta {bus.RutaId}")
                
        except Exception as e:
            print(f"   ❌ Error inicializando bus {bus.IdBus}: {e}")
            import traceback
            traceback.print_exc()
    
    async def _actualizar_ubicaciones(self):
        """Actualiza las ubicaciones de todos los buses"""
        try:
            for bus_id, datos in list(self.buses_activos.items()):
                await self._mover_bus(bus_id, datos)
        except Exception as e:
            print(f"❌ Error actualizando ubicaciones: {e}")
    
    async def _mover_bus(self, bus_id: int, datos: dict):
        """Mueve un bus a lo largo de su ruta en ORDEN"""
        try:
            if datos['en_paradero']:
                datos['tiempo_paradero'] += 3 
                if datos['tiempo_paradero'] >= 10:  
                    datos['en_paradero'] = False
                    datos['tiempo_paradero'] = 0
                    print(f"   🚌 Bus {bus_id} saliendo del paradero")
                return
            
            puntos = datos['puntos_ruta']
            if not puntos or datos['proximo_punto_idx'] >= len(puntos):
                return
            
            punto_actual = puntos[datos['punto_actual_idx']]
            siguiente_punto = puntos[datos['proximo_punto_idx']]
            
            lat_actual, lon_actual = datos['latitud'], datos['longitud']
            lat_destino, lon_destino = siguiente_punto.latitud, siguiente_punto.longitud
            
            distancia = self._calcular_distancia(lat_actual, lon_actual, lat_destino, lon_destino)
            
            if distancia < 0.00005:  
                datos['punto_actual_idx'] = datos['proximo_punto_idx']
                datos['proximo_punto_idx'] += datos['sentido']
                
                print(f"   🚏 Bus {bus_id} llegó al punto {datos['punto_actual_idx'] + 1}")
                
                if datos['proximo_punto_idx'] >= len(puntos) or datos['proximo_punto_idx'] < 0:
                    # Cambiar sentido
                    datos['sentido'] *= -1
                    datos['proximo_punto_idx'] = datos['punto_actual_idx'] + datos['sentido']
                    print(f"   🔄 Bus {bus_id} cambiando sentido")
                
                datos['en_paradero'] = True
                datos['tiempo_paradero'] = 0
                print(f"   ⏸️  Bus {bus_id} detenido en paradero")
                
            else:
                factor = datos['velocidad'] / max(distancia, 0.00001)
                factor = min(factor, 1.0)
                
                nueva_lat = lat_actual + (lat_destino - lat_actual) * factor
                nueva_lon = lon_actual + (lon_destino - lon_actual) * factor
                
                datos['latitud'] = nueva_lat
                datos['longitud'] = nueva_lon
                datos['ultima_actualizacion'] = datetime.now()
                
                # Debug: mostrar movimiento ocasionalmente
                if random.random() < 0.05:  # 5% de probabilidad
                    punto_actual_num = datos['punto_actual_idx'] + 1
                    punto_siguiente_num = datos['proximo_punto_idx'] + 1
                    print(f"   🚌 Bus {bus_id} yendo al punto {punto_siguiente_num} desde {punto_actual_num}")
                
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
                'punto_actual': datos['punto_actual_idx'] + 1,  # Para mostrar número humano
                'ultima_actualizacion': datos['ultima_actualizacion'].isoformat()
            }
        return ubicaciones
    
    def detener_simulacion(self):
        """Detiene la simulación"""
        self.simulacion_activa = False
        print("🛑 Simulación detenida")