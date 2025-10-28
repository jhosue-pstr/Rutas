import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/bus.dart';
import '../../data/models/rutas.dart';
import '../../data/models/punto_ruta.dart';
import '../../data/models/ubicacion_bus.dart';
import '../../data/services/bus_service.dart';
import './punto_ruta_controller.dart';
import './ruta_controller.dart';

class BusController {
  final BusService _busService = BusService();
  final RutaController _rutaController = RutaController();
  final PuntoRutaController _puntoRutaController = PuntoRutaController();
  List<PuntoRuta> _puntosRuta = [];

  Future<ResultadoBusqueda> buscarRutasYBuses(
    LatLng origen,
    LatLng destino, {
    double radioMaximoKm = 2.0,
  }) async {
    print('📍 Buscando RUTAS Y BUSES desde: $origen hasta: $destino');

    if (_puntosRuta.isEmpty) {
      await _cargarPuntosRuta();
    }

    final resultado = ResultadoBusqueda();

    final todasLasRutas = await _rutaController.obtenerRutas();

    final rutasCercanas = await _encontrarTodasRutasCercanas(
      origen,
      todasLasRutas,
      radioMaximoKm,
    );

    if (rutasCercanas.isEmpty) {
      print('❌ No se encontraron rutas cercanas al origen');
      return resultado;
    }

    print('🛣️ Rutas cercanas encontradas: ${rutasCercanas.length}');

    for (final rutaInfo in rutasCercanas) {
      final llegaAlDestino = await _verificarLlegaAlDestino(
        rutaInfo.ruta,
        rutaInfo.puntoCercano,
        destino,
      );

      if (llegaAlDestino) {
        final busesEnRuta = await _obtenerBusesEnRuta(rutaInfo.ruta.IdRuta);

        final rutaValida = RutaValida(
          ruta: rutaInfo.ruta,
          distanciaAlOrigen: rutaInfo.distancia,
          puntoEmbarque: rutaInfo.puntoCercano,
          busesDisponibles: busesEnRuta,
          tiempoCaminando: _calcularTiempoCaminando(rutaInfo.distancia * 1000),
          tiempoEstimadoBus: _estimarTiempoHastaDestino(
            rutaInfo.ruta,
            rutaInfo.puntoCercano,
            destino,
          ),
        );

        resultado.rutasValidas.add(rutaValida);

        print(
          '✅ Ruta ${rutaInfo.ruta.nombre} - '
          '${rutaInfo.distancia.toStringAsFixed(2)} km - '
          '${busesEnRuta.length} buses - '
          '${rutaValida.tiempoTotal} min total',
        );
      } else {
        print('🔴 Ruta ${rutaInfo.ruta.nombre} - NO llega al destino');
      }
    }

    resultado.rutasValidas.sort(
      (a, b) => a.distanciaAlOrigen.compareTo(b.distanciaAlOrigen),
    );

    resultado.recomendaciones = _calcularMejoresOpciones(
      resultado.rutasValidas,
    );

    print(
      '📊 Resultado: ${resultado.rutasValidas.length} rutas válidas, '
      '${resultado.recomendaciones.length} recomendaciones',
    );

    return resultado;
  }

  Future<List<RutaCercanaInfo>> _encontrarTodasRutasCercanas(
    LatLng origen,
    List<Ruta> todasLasRutas, // ✅ RECIBIR RUTAS COMO PARÁMETRO
    double radioMaximoKm,
  ) async {
    final rutasCercanas = <RutaCercanaInfo>[];

    for (final ruta in todasLasRutas) {
      final puntosRuta = _puntosRuta
          .where((p) => p.RutaId == ruta.IdRuta)
          .toList();

      if (puntosRuta.isEmpty) continue;

      final puntoCercano = _encontrarPuntoMasCercano(origen, puntosRuta);
      final distancia = _calcularDistanciaKm(
        origen.latitude,
        origen.longitude,
        puntoCercano.latitud,
        puntoCercano.longitud,
      );

      if (distancia <= radioMaximoKm) {
        rutasCercanas.add(
          RutaCercanaInfo(
            ruta: ruta,
            puntoCercano: LatLng(puntoCercano.latitud, puntoCercano.longitud),
            distancia: distancia,
          ),
        );
      }
    }

    return rutasCercanas;
  }

  Future<bool> _verificarLlegaAlDestino(
    Ruta ruta,
    LatLng puntoEmbarque,
    LatLng destino,
  ) async {
    final puntosRuta = _puntosRuta
        .where((p) => p.RutaId == ruta.IdRuta)
        .toList();

    if (puntosRuta.length < 2) return false;

    puntosRuta.sort((a, b) => a.orden.compareTo(b.orden));

    final puntoEmbarqueObj = _encontrarPuntoMasCercano(
      puntoEmbarque,
      puntosRuta,
    );
    final indiceEmbarque = puntosRuta.indexOf(puntoEmbarqueObj);

    for (int i = indiceEmbarque; i < puntosRuta.length; i++) {
      final punto = puntosRuta[i];
      final distanciaAlDestino = _calcularDistanciaKm(
        destino.latitude,
        destino.longitude,
        punto.latitud,
        punto.longitud,
      );

      if (distanciaAlDestino <= 1.5) {
        return true;
      }
    }

    return false;
  }

  List<Recomendacion> _calcularMejoresOpciones(List<RutaValida> rutasValidas) {
    final recomendaciones = <Recomendacion>[];

    for (final ruta in rutasValidas) {
      if (ruta.busesDisponibles.isNotEmpty) {
        recomendaciones.add(
          Recomendacion(
            ruta: ruta.ruta,
            puntoEmbarque: ruta.puntoEmbarque,
            distanciaCaminando: ruta.distanciaAlOrigen,
            tiempoCaminando: ruta.tiempoCaminando,
            tiempoTotal: ruta.tiempoTotal,
            busesDisponibles: ruta.busesDisponibles,
            tipo: 'Con bus disponible',
            prioridad: 1, // Máxima prioridad
          ),
        );
      } else {
        recomendaciones.add(
          Recomendacion(
            ruta: ruta.ruta,
            puntoEmbarque: ruta.puntoEmbarque,
            distanciaCaminando: ruta.distanciaAlOrigen,
            tiempoCaminando: ruta.tiempoCaminando,
            tiempoTotal: ruta.tiempoTotal + 10,
            busesDisponibles: [],
            tipo: 'Ruta válida (esperar bus)',
            prioridad: 2,
          ),
        );
      }
    }

    recomendaciones.sort((a, b) {
      if (a.prioridad != b.prioridad) {
        return a.prioridad.compareTo(b.prioridad);
      }
      if (a.distanciaCaminando != b.distanciaCaminando) {
        return a.distanciaCaminando.compareTo(b.distanciaCaminando);
      }
      return a.tiempoTotal.compareTo(b.tiempoTotal);
    });
  }

  Future<List<Bus>> _obtenerBusesEnRuta(int rutaId) async {
    try {
      final todosLosBuses = await _busService.obtenerBuses();
      return todosLosBuses.where((bus) => bus.RutaId == rutaId).toList();
    } catch (e) {
      print('⚠️ Error obteniendo buses: $e');
      return [];
    }
  }

  PuntoRuta _encontrarPuntoMasCercano(
    LatLng ubicacion,
    List<PuntoRuta> puntosRuta,
  ) {
    PuntoRuta puntoMasCercano = puntosRuta.first;
    double distanciaMinima = double.maxFinite;

    for (final punto in puntosRuta) {
      final distancia = _calcularDistanciaKm(
        ubicacion.latitude,
        ubicacion.longitude,
        punto.latitud,
        punto.longitud,
      );

      if (distancia < distanciaMinima) {
        distanciaMinima = distancia;
        puntoMasCercano = punto;
      }
    }
    return puntoMasCercano;
  }

  double _calcularDistanciaKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radioTierra = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radioTierra * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  int _calcularTiempoCaminando(double distanciaMetros) {
    return (distanciaMetros / 80).round();
  }

  int _estimarTiempoHastaDestino(Ruta ruta, LatLng inicio, LatLng fin) {
    final distancia = _calcularDistanciaKm(
      inicio.latitude,
      inicio.longitude,
      fin.latitude,
      fin.longitude,
    );
    return (distancia / 20 * 60 + distancia * 0.5).round();
  }

  Future<void> _cargarPuntosRuta() async {
    try {
      _puntosRuta = await _puntoRutaController.obtenerPuntosRuta();
      print('📍 Puntos de ruta cargados: ${_puntosRuta.length}');
    } catch (e) {
      print('❌ Error cargando puntos de ruta: $e');
      _puntosRuta = [];
    }
  }
}

class ResultadoBusqueda {
  List<RutaValida> rutasValidas = [];
  List<Recomendacion> recomendaciones = [];

  bool get hayRutas => rutasValidas.isNotEmpty;
  bool get hayBusesDisponibles =>
      rutasValidas.any((ruta) => ruta.busesDisponibles.isNotEmpty);
}

class RutaCercanaInfo {
  final Ruta ruta;
  final LatLng puntoCercano;
  final double distancia;

  RutaCercanaInfo({
    required this.ruta,
    required this.puntoCercano,
    required this.distancia,
  });
}

class RutaValida {
  final Ruta ruta;
  final double distanciaAlOrigen;
  final LatLng puntoEmbarque;
  final List<Bus> busesDisponibles;
  final int tiempoCaminando;
  final int tiempoEstimadoBus;

  RutaValida({
    required this.ruta,
    required this.distanciaAlOrigen,
    required this.puntoEmbarque,
    required this.busesDisponibles,
    required this.tiempoCaminando,
    required this.tiempoEstimadoBus,
  });

  int get tiempoTotal => tiempoCaminando + tiempoEstimadoBus;
  bool get tieneBuses => busesDisponibles.isNotEmpty;
}

class Recomendacion {
  final Ruta ruta;
  final LatLng puntoEmbarque;
  final double distanciaCaminando;
  final int tiempoCaminando;
  final int tiempoTotal;
  final List<Bus> busesDisponibles;
  final String tipo;
  final int prioridad;

  Recomendacion({
    required this.ruta,
    required this.puntoEmbarque,
    required this.distanciaCaminando,
    required this.tiempoCaminando,
    required this.tiempoTotal,
    required this.busesDisponibles,
    required this.tipo,
    required this.prioridad,
  });
}
