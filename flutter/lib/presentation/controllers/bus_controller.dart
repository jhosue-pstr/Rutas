import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/bus.dart';
import '../../data/models/rutas.dart';
import '../../data/models/punto_ruta.dart';
import '../../data/services/bus_service.dart';
import './punto_ruta_controller.dart';

class BusController {
  final BusService _busService = BusService();
  final PuntoRutaController _puntoRutaController = PuntoRutaController();
  List<PuntoRuta> _puntosRuta = [];

  // ========== MÉTODOS CRUD BÁSICOS ==========

  Future<List<Bus>> obtenerBuses() async {
    try {
      return await _busService.obtenerBuses();
    } catch (e) {
      throw Exception('Error al obtener los buses: $e');
    }
  }

  Future<Bus> obtenerBusPorId(int id) async {
    try {
      return await _busService.obtenerBusPorId(id);
    } catch (e) {
      throw Exception('Error al obtener el bus: $e');
    }
  }

  Future<Bus> crearBus(Bus bus) async {
    try {
      return await _busService.crearBus(bus);
    } catch (e) {
      throw Exception('Error al crear el bus: $e');
    }
  }

  Future<Bus> actualizarBus(int id, Bus bus) async {
    try {
      return await _busService.actualizarBus(id, bus);
    } catch (e) {
      throw Exception('Error al actualizar el bus: $e');
    }
  }

  Future<void> eliminarBus(int id) async {
    try {
      await _busService.eliminarBus(id);
    } catch (e) {
      throw Exception('Error al eliminar el bus: $e');
    }
  }

  // ========== MÉTODOS DE CÁLCULO DE RUTAS ==========

  // 🔹 OBTENER BUSES CERCA DE UNA UBICACIÓN
  Future<List<Bus>> obtenerBusesCercaDe(
    LatLng ubicacion,
    List<Bus> todosLosBuses,
    List<Ruta> todasLasRutas,
  ) async {
    // Cargar puntos de ruta si no están cargados
    if (_puntosRuta.isEmpty) {
      await _cargarPuntosRuta();
    }

    final busesCerca = <Bus>[];

    for (final bus in todosLosBuses) {
      if (bus.RutaId != null) {
        final ruta = todasLasRutas.firstWhere(
          (r) => r.IdRuta == bus.RutaId,
          orElse: () => Ruta(
            IdRuta: 0,
            nombre: '',
            FechaRegistro: DateTime.now(),
            puntos: [],
            buses: null,
          ),
        );

        final puntosRuta = _puntosRuta
            .where((p) => p.RutaId == ruta.IdRuta)
            .toList();

        // Verificar si algún punto de la ruta está cerca
        for (final punto in puntosRuta) {
          final distancia = _calcularDistancia(
            ubicacion.latitude,
            ubicacion.longitude,
            punto.latitud,
            punto.longitud,
          );

          if (distancia <= 500) {
            // 500 metros de radio
            busesCerca.add(bus);
            break;
          }
        }
      }
    }

    return busesCerca;
  }

  // 🔹 CALCULAR RUTAS RECOMENDADAS
  List<RutaRecomendacion> calcularRutasRecomendadas(
    List<Bus> busesOrigen,
    List<Bus> busesDestino,
    LatLng origen,
    LatLng destino,
    List<Ruta> todasLasRutas,
  ) {
    final recomendaciones = <RutaRecomendacion>[];

    // Rutas directas (mismo bus)
    for (final busOrigen in busesOrigen) {
      for (final busDestino in busesDestino) {
        if (busOrigen.IdBus == busDestino.IdBus) {
          // Mismo bus - ruta directa
          final ruta = todasLasRutas.firstWhere(
            (r) => r.IdRuta == busOrigen.RutaId,
          );
          final tiempo = _estimarTiempoRuta(origen, destino, ruta);

          recomendaciones.add(
            RutaRecomendacion(
              buses: [
                BusInfo(bus: busOrigen, ruta: ruta, tiempoEstimado: tiempo),
              ],
              tiempoTotal: tiempo,
              distanciaCaminando: _calcularDistancia(
                origen.latitude,
                origen.longitude,
                destino.latitude,
                destino.longitude,
              ),
              distanciaDestino: 0.0,
            ),
          );
        }
      }
    }

    // Rutas con combinación (2 buses)
    for (final busOrigen in busesOrigen) {
      for (final busDestino in busesDestino) {
        if (busOrigen.IdBus != busDestino.IdBus) {
          final ruta1 = todasLasRutas.firstWhere(
            (r) => r.IdRuta == busOrigen.RutaId,
          );
          final ruta2 = todasLasRutas.firstWhere(
            (r) => r.IdRuta == busDestino.RutaId,
          );

          // Punto de combinación estimado (en la práctica sería más complejo)
          final tiempo1 = _estimarTiempoRuta(origen, destino, ruta1) ~/ 2;
          final tiempo2 = _estimarTiempoRuta(origen, destino, ruta2) ~/ 2;
          final tiempoTotal = tiempo1 + tiempo2 + 10; // +10 min por transbordo

          recomendaciones.add(
            RutaRecomendacion(
              buses: [
                BusInfo(bus: busOrigen, ruta: ruta1, tiempoEstimado: tiempo1),
                BusInfo(bus: busDestino, ruta: ruta2, tiempoEstimado: tiempo2),
              ],
              tiempoTotal: tiempoTotal,
              distanciaCaminando: _calcularDistancia(
                origen.latitude,
                origen.longitude,
                destino.latitude,
                destino.longitude,
              ),
              distanciaDestino: 0.0,
            ),
          );
        }
      }
    }

    // Ordenar por tiempo total
    recomendaciones.sort((a, b) => a.tiempoTotal.compareTo(b.tiempoTotal));

    return recomendaciones;
  }

  // 🔹 OBTENER BUSES POR RUTA
  List<Bus> obtenerBusesPorRuta(int rutaId, List<Bus> todosLosBuses) {
    return todosLosBuses.where((bus) => bus.RutaId == rutaId).toList();
  }

  // 🔹 OBTENER BUSES SIN RUTA ASIGNADA
  List<Bus> obtenerBusesSinRuta(List<Bus> todosLosBuses) {
    return todosLosBuses.where((bus) => bus.RutaId == null).toList();
  }

  // ========== MÉTODOS PRIVADOS ==========

  Future<void> _cargarPuntosRuta() async {
    try {
      _puntosRuta = await _puntoRutaController.obtenerPuntosRuta();
    } catch (e) {
      print('Error cargando puntos de ruta: $e');
      _puntosRuta = [];
    }
  }

  // 🔹 CALCULAR DISTANCIA ENTRE DOS PUNTOS (Haversine)
  double _calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radioTierra = 6371e3; // metros
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a =
        sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radioTierra * c;
  }

  // 🔹 ESTIMAR TIEMPO DE RUTA (simplificado)
  int _estimarTiempoRuta(LatLng origen, LatLng destino, Ruta ruta) {
    final distancia = _calcularDistancia(
      origen.latitude,
      origen.longitude,
      destino.latitude,
      destino.longitude,
    );
    // Estimación: 5 min/km + 5 min fijos por paradas
    return (distancia / 1000 * 5 + 5).round();
  }
}

// ========== MODELOS PARA RECOMENDACIONES ==========

class RutaRecomendacion {
  final List<BusInfo> buses;
  final int tiempoTotal;
  final double distanciaCaminando;
  final double distanciaDestino;

  RutaRecomendacion({
    required this.buses,
    required this.tiempoTotal,
    required this.distanciaCaminando,
    required this.distanciaDestino,
  });
}

class BusInfo {
  final Bus bus;
  final Ruta ruta;
  final int tiempoEstimado;

  BusInfo({
    required this.bus,
    required this.ruta,
    required this.tiempoEstimado,
  });
}
