# simulación/bus_simulator.py
import asyncio
import random
from datetime import datetime
from sqlmodel import Session, select
from models.bus import Bus
from models.ruta import Ruta
from models.punto_ruta import PuntoRuta

class BusSimulator:
    def __init__(self, session: Session):
        self.session = session
        self.buses_activos = {}
        
    async def iniciar_simulacion(self):
        """Inicia la simulación de todos los buses"""
        print("🔍 BUSCANDO BUSES EN LA BASE DE DATOS...")
    
        buses = self.session.exec(select(Bus)).all()
        print(f"📊 Total de buses encontrados: {len(buses)}")
    
        for bus in buses:
            print(f"🚌 Bus {bus.IdBus}: Placa {bus.placa}, RutaId {bus.RutaId}")
        
        buses_con_ruta = [b for b in buses if b.RutaId is not None]
        print(f"🎯 Buses con ruta asignada: {len(buses_con_ruta)}")
    
        for bus in buses_con_ruta:
            await self._inicializar_bus(bus)
    
        print(f"🚀 Simulación iniciada con {len(self.buses_activos)} buses activos")
    
    # Ejecutar simulación continua
        while True:
            await self._actualizar_ubicaciones()
            await asyncio.sleep(10)



    async def _inicializar_bus(self, bus: Bus):
        """Inicializa un bus en una posición aleatoria de su ruta"""
        ruta = self.session.get(Ruta, bus.RutaId)
        puntos = self.session.exec(
            select(PuntoRuta).where(PuntoRuta.RutaId == bus.RutaId)
        ).all()
        
        if puntos:
            punto_inicial = random.choice(puntos)
            self.buses_activos[bus.IdBus] = {
                'bus': bus,
                'latitud': punto_inicial.latitud,
                'longitud': punto_inicial.longitud,
                'punto_actual': 0,
                'puntos_ruta': puntos,
                'velocidad': random.uniform(0.0001, 0.0003),  # Velocidad realista
                'direccion': 1  # 1 para adelante, -1 para atrás
            }
    
    async def _actualizar_ubicaciones(self):
        """Actualiza la ubicación de todos los buses activos"""
        for bus_id, datos in self.buses_activos.items():
            puntos = datos['puntos_ruta']
            punto_actual = datos['punto_actual']
            
            # Mover hacia el siguiente punto
            if 0 <= punto_actual < len(puntos) - 1:
                punto_obj = puntos[punto_actual]
                next_punto = puntos[punto_actual + datos['direccion']]
                
                # Calcular nueva posición (movimiento lineal simple)
                datos['latitud'] += (next_punto.latitud - punto_obj.latitud) * datos['velocidad']
                datos['longitud'] += (next_punto.longitud - punto_obj.longitud) * datos['velocidad']
                
                # Si está suficientemente cerca del siguiente punto, avanzar
                distancia = self._calcular_distancia(
                    datos['latitud'], datos['longitud'],
                    next_punto.latitud, next_punto.longitud
                )
                
                if distancia < 0.001:  # ~100 metros
                    datos['punto_actual'] += datos['direccion']
                    
                    # Cambiar dirección si llega al final
                    if datos['punto_actual'] >= len(puntos) - 1:
                        datos['direccion'] = -1
                    elif datos['punto_actual'] <= 0:
                        datos['direccion'] = 1
    
    def _calcular_distancia(self, lat1, lon1, lat2, lon2):
        """Calcula distancia entre dos puntos (simplificado)"""
        return ((lat2 - lat1) ** 2 + (lon2 - lon1) ** 2) ** 0.5
    
    def obtener_ubicaciones(self):
        """Retorna las ubicaciones actuales de todos los buses"""
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