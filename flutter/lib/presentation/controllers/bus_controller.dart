import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rutasfrontend/data/services/punto_transbordo.dart';
import 'package:rutasfrontend/data/services/resultado_ruta.dart';
import 'package:rutasfrontend/data/services/ruta_completa.dart';
import 'package:rutasfrontend/data/services/segmento_ruta.dart';
import '../../data/models/bus.dart';
import '../../data/models/rutas.dart';
import '../../data/models/punto_ruta.dart';
import '../../data/services/bus_service.dart';
import './punto_ruta_controller.dart';
import './ruta_controller.dart';

class BusControllerMejorado {
  final BusService _busService = BusService();
  final RutaController _rutaController = RutaController();
  final PuntoRutaController _puntoRutaController = PuntoRutaController();
  List<PuntoRuta> _puntosRuta = [];

  // 🔥 MÉTODO PRINCIPAL - CALCULAR MEJOR RUTA
  Future<ResultadoRuta> calcularMejorRuta(
    LatLng origen,
    LatLng destino, {
    double radioBusquedaKm = 0.5,
  }) async {
    print('🚀 CALCULANDO MEJOR RUTA: $origen → $destino');

    if (_puntosRuta.isEmpty) {
      await _cargarPuntosRuta();
    }

    final todasLasRutas = await _rutaController.obtenerRutas();
    final rutasRecomendadas = <RutaCompleta>[];

    // 🔥 1. BUSCAR RUTAS DIRECTAS
    final rutasDirectas = await _buscarRutasDirectas(
      origen,
      destino,
      todasLasRutas,
      radioBusquedaKm,
    );

    if (rutasDirectas.isNotEmpty) {
      print('✅ Encontradas ${rutasDirectas.length} rutas directas');
      rutasRecomendadas.addAll(rutasDirectas);
    }

    // 🔥 2. BUSCAR RUTAS CON TRANSBORDO (si no hay directas)
    if (rutasDirectas.isEmpty) {
      print('🔍 Buscando rutas con transbordo...');
      final rutasConTransbordo = await _buscarRutasConTransbordo(
        origen,
        destino,
        todasLasRutas,
        radioBusquedaKm,
      );

      if (rutasConTransbordo.isNotEmpty) {
        print(
          '✅ Encontradas ${rutasConTransbordo.length} rutas con transbordo',
        );
        rutasRecomendadas.addAll(rutasConTransbordo);
      }
    }

    // 🔥 3. ORDENAR POR TIEMPO TOTAL
    rutasRecomendadas.sort((a, b) => a.tiempoTotal.compareTo(b.tiempoTotal));

    return ResultadoRuta(
      rutasRecomendadas: rutasRecomendadas.take(3).toList(), // Top 3
      hayRutasDirectas: rutasDirectas.isNotEmpty,
      mensaje: _generarMensajeResultado(rutasRecomendadas),
      origen: origen,
      destino: destino,
    );
  }

  // 🔥 BUSCAR RUTAS DIRECTAS
  Future<List<RutaCompleta>> _buscarRutasDirectas(
    LatLng origen,
    LatLng destino,
    List<Ruta> todasLasRutas,
    double radioKm,
  ) async {
    final rutasDirectas = <RutaCompleta>[];

    for (final ruta in todasLasRutas) {
      final puntosRuta = _puntosRuta
          .where((p) => p.RutaId == ruta.IdRuta)
          .toList();

      if (puntosRuta.length < 2) continue;

      // Verificar si la ruta pasa cerca del ORIGEN y DESTINO
      final puntoCercanoOrigen = _encontrarPuntoMasCercano(origen, puntosRuta);
      final distanciaOrigen = _calcularDistanciaKm(
        origen.latitude,
        origen.longitude,
        puntoCercanoOrigen.latitud,
        puntoCercanoOrigen.longitud,
      );

      final puntoCercanoDestino = _encontrarPuntoMasCercano(
        destino,
        puntosRuta,
      );
      final distanciaDestino = _calcularDistanciaKm(
        destino.latitude,
        destino.longitude,
        puntoCercanoDestino.latitud,
        puntoCercanoDestino.longitud,
      );

      // Verificar dirección correcta (origen antes que destino en la ruta)
      final ordenCorrecto = _verificarOrdenRuta(
        puntosRuta,
        puntoCercanoOrigen,
        puntoCercanoDestino,
      );

      if (distanciaOrigen <= radioKm &&
          distanciaDestino <= radioKm &&
          ordenCorrecto) {
        // Crear segmento de ruta directa
        final tiempoCaminandoOrigen = _calcularTiempoCaminando(
          distanciaOrigen * 1000,
        );
        final tiempoCaminandoDestino = _calcularTiempoCaminando(
          distanciaDestino * 1000,
        );
        final tiempoBus = _estimarTiempoBus(
          ruta,
          puntoCercanoOrigen,
          puntoCercanoDestino,
        );

        final segmentos = [
          // Caminar hasta la parada
          SegmentoRuta(
            puntoInicio: origen,
            puntoFin: LatLng(
              puntoCercanoOrigen.latitud,
              puntoCercanoOrigen.longitud,
            ),
            tiempoEstimado: tiempoCaminandoOrigen,
            distancia: distanciaOrigen,
            tipo: 'CAMINANDO',
            instruccion:
                'Camina ${distanciaOrigen.toStringAsFixed(1)} km hasta la parada',
          ),
          // Tomar el bus
          SegmentoRuta(
            ruta: ruta,
            puntoInicio: LatLng(
              puntoCercanoOrigen.latitud,
              puntoCercanoOrigen.longitud,
            ),
            puntoFin: LatLng(
              puntoCercanoDestino.latitud,
              puntoCercanoDestino.longitud,
            ),
            tiempoEstimado: tiempoBus,
            distancia: _calcularDistanciaEntrePuntos(
              puntoCercanoOrigen,
              puntoCercanoDestino,
            ),
            tipo: 'BUS',
            instruccion: 'Toma el bus ${ruta.nombre}',
          ),
          // Caminar hasta el destino
          SegmentoRuta(
            puntoInicio: LatLng(
              puntoCercanoDestino.latitud,
              puntoCercanoDestino.longitud,
            ),
            puntoFin: destino,
            tiempoEstimado: tiempoCaminandoDestino,
            distancia: distanciaDestino,
            tipo: 'CAMINANDO',
            instruccion:
                'Camina ${distanciaDestino.toStringAsFixed(1)} km hasta tu destino',
          ),
        ];

        final tiempoTotal =
            tiempoCaminandoOrigen + tiempoBus + tiempoCaminandoDestino;
        final distanciaTotal =
            distanciaOrigen +
            _calcularDistanciaEntrePuntos(
              puntoCercanoOrigen,
              puntoCercanoDestino,
            ) +
            distanciaDestino;

        rutasDirectas.add(
          RutaCompleta(
            segmentos: segmentos,
            tiempoTotal: tiempoTotal,
            distanciaTotal: distanciaTotal,
            tipo: 'DIRECTA',
            instrucciones: 'Toma el bus ${ruta.nombre} directamente',
            prioridad: 1,
          ),
        );
      }
    }

    return rutasDirectas;
  }

  // 🔥 BUSCAR RUTAS CON TRANSBORDO - CORREGIDO
  Future<List<RutaCompleta>> _buscarRutasConTransbordo(
    LatLng origen,
    LatLng destino,
    List<Ruta> todasLasRutas,
    double radioKm,
  ) async {
    final rutasConTransbordo = <RutaCompleta>[];

    final rutasCercaOrigenInfo = await _buscarRutasCercanas(
      origen,
      todasLasRutas,
      radioKm,
    );
    final rutasCercaDestinoInfo = await _buscarRutasCercanas(
      destino,
      todasLasRutas,
      radioKm,
    );

    final rutasCercaOrigen = rutasCercaOrigenInfo
        .map((info) => info.ruta)
        .toList();
    final rutasCercaDestino = rutasCercaDestinoInfo
        .map((info) => info.ruta)
        .toList();

    for (final rutaOrigen in rutasCercaOrigen) {
      for (final rutaDestino in rutasCercaDestino) {
        if (rutaOrigen.IdRuta != rutaDestino.IdRuta) {
          final transbordo = await _encontrarMejorTransbordo(
            rutaOrigen,
            rutaDestino,
          );
          if (transbordo != null) {
            final rutaCompleta = await _crearRutaConTransbordo(
              origen,
              destino,
              rutaOrigen,
              rutaDestino,
              transbordo,
            );
            rutasConTransbordo.add(rutaCompleta);
          }
        }
      }
    }

    return rutasConTransbordo;
  }

  // Buscar rutas cerca del ORIGEN

  // 🔥 CREAR RUTA COMPLETA CON TRANSBORDO
  Future<RutaCompleta> _crearRutaConTransbordo(
    LatLng origen,
    LatLng destino,
    Ruta rutaOrigen,
    Ruta rutaDestino,
    PuntoTransbordo transbordo,
  ) async {
    final puntosRutaOrigen = _puntosRuta
        .where((p) => p.RutaId == rutaOrigen.IdRuta)
        .toList();
    final puntosRutaDestino = _puntosRuta
        .where((p) => p.RutaId == rutaDestino.IdRuta)
        .toList();

    // Encontrar puntos más cercanos
    final puntoOrigenCercano = _encontrarPuntoMasCercano(
      origen,
      puntosRutaOrigen,
    );
    final puntoTransbordoOrigen = _encontrarPuntoMasCercano(
      transbordo.ubicacion,
      puntosRutaOrigen,
    );
    final puntoTransbordoDestino = _encontrarPuntoMasCercano(
      transbordo.ubicacion,
      puntosRutaDestino,
    );
    final puntoDestinoCercano = _encontrarPuntoMasCercano(
      destino,
      puntosRutaDestino,
    );

    // Calcular distancias
    final distanciaOrigen = _calcularDistanciaKm(
      origen.latitude,
      origen.longitude,
      puntoOrigenCercano.latitud,
      puntoOrigenCercano.longitud,
    );

    final distanciaTransbordo = _calcularDistanciaKm(
      puntoTransbordoOrigen.latitud,
      puntoTransbordoOrigen.longitud,
      puntoTransbordoDestino.latitud,
      puntoTransbordoDestino.longitud,
    );

    final distanciaDestino = _calcularDistanciaKm(
      puntoDestinoCercano.latitud,
      puntoDestinoCercano.longitud,
      destino.latitude,
      destino.longitude,
    );

    // Calcular tiempos
    final tiempoCaminandoOrigen = _calcularTiempoCaminando(
      distanciaOrigen * 1000,
    );
    final tiempoBus1 = _estimarTiempoBus(
      rutaOrigen,
      puntoOrigenCercano,
      puntoTransbordoOrigen,
    );
    final tiempoCaminandoTransbordo = _calcularTiempoCaminando(
      distanciaTransbordo * 1000,
    );
    final tiempoBus2 = _estimarTiempoBus(
      rutaDestino,
      puntoTransbordoDestino,
      puntoDestinoCercano,
    );
    final tiempoCaminandoDestino = _calcularTiempoCaminando(
      distanciaDestino * 1000,
    );

    final segmentos = [
      // Caminar hasta primera parada
      SegmentoRuta(
        puntoInicio: origen,
        puntoFin: LatLng(
          puntoOrigenCercano.latitud,
          puntoOrigenCercano.longitud,
        ),
        tiempoEstimado: tiempoCaminandoOrigen,
        distancia: distanciaOrigen,
        tipo: 'CAMINANDO',
        instruccion:
            'Camina ${distanciaOrigen.toStringAsFixed(1)} km hasta la parada',
      ),
      // Tomar primer bus
      SegmentoRuta(
        ruta: rutaOrigen,
        puntoInicio: LatLng(
          puntoOrigenCercano.latitud,
          puntoOrigenCercano.longitud,
        ),
        puntoFin: LatLng(
          puntoTransbordoOrigen.latitud,
          puntoTransbordoOrigen.longitud,
        ),
        tiempoEstimado: tiempoBus1,
        distancia: _calcularDistanciaEntrePuntos(
          puntoOrigenCercano,
          puntoTransbordoOrigen,
        ),
        tipo: 'BUS',
        instruccion: 'Toma el bus ${rutaOrigen.nombre}',
      ),
      // Caminar entre paradas (transbordo)
      SegmentoRuta(
        puntoInicio: LatLng(
          puntoTransbordoOrigen.latitud,
          puntoTransbordoOrigen.longitud,
        ),
        puntoFin: LatLng(
          puntoTransbordoDestino.latitud,
          puntoTransbordoDestino.longitud,
        ),
        tiempoEstimado: tiempoCaminandoTransbordo,
        distancia: distanciaTransbordo,
        tipo: 'CAMINANDO',
        instruccion:
            'Baja y camina ${distanciaTransbordo.toStringAsFixed(1)} km hasta la siguiente parada',
      ),
      // Tomar segundo bus
      SegmentoRuta(
        ruta: rutaDestino,
        puntoInicio: LatLng(
          puntoTransbordoDestino.latitud,
          puntoTransbordoDestino.longitud,
        ),
        puntoFin: LatLng(
          puntoDestinoCercano.latitud,
          puntoDestinoCercano.longitud,
        ),
        tiempoEstimado: tiempoBus2,
        distancia: _calcularDistanciaEntrePuntos(
          puntoTransbordoDestino,
          puntoDestinoCercano,
        ),
        tipo: 'BUS',
        instruccion: 'Toma el bus ${rutaDestino.nombre}',
      ),
      // Caminar hasta destino final
      SegmentoRuta(
        puntoInicio: LatLng(
          puntoDestinoCercano.latitud,
          puntoDestinoCercano.longitud,
        ),
        puntoFin: destino,
        tiempoEstimado: tiempoCaminandoDestino,
        distancia: distanciaDestino,
        tipo: 'CAMINANDO',
        instruccion:
            'Camina ${distanciaDestino.toStringAsFixed(1)} km hasta tu destino',
      ),
    ];

    final tiempoTotal =
        tiempoCaminandoOrigen +
        tiempoBus1 +
        tiempoCaminandoTransbordo +
        tiempoBus2 +
        tiempoCaminandoDestino;
    final distanciaTotal =
        distanciaOrigen +
        _calcularDistanciaEntrePuntos(
          puntoOrigenCercano,
          puntoTransbordoOrigen,
        ) +
        distanciaTransbordo +
        _calcularDistanciaEntrePuntos(
          puntoTransbordoDestino,
          puntoDestinoCercano,
        ) +
        distanciaDestino;

    return RutaCompleta(
      segmentos: segmentos,
      tiempoTotal: tiempoTotal,
      distanciaTotal: distanciaTotal,
      tipo: 'CON_TRANSBORDO',
      instrucciones:
          'Toma bus ${rutaOrigen.nombre}, transborda en ${transbordo.nombreParada} y toma bus ${rutaDestino.nombre}',
      prioridad: 2,
    );
  }

  // 🔥 ENCONTRAR MEJOR PUNTO DE TRANSBORDO
  Future<PuntoTransbordo?> _encontrarMejorTransbordo(
    Ruta rutaOrigen,
    Ruta rutaDestino,
  ) async {
    final puntosOrigen = _puntosRuta
        .where((p) => p.RutaId == rutaOrigen.IdRuta)
        .toList();
    final puntosDestino = _puntosRuta
        .where((p) => p.RutaId == rutaDestino.IdRuta)
        .toList();

    PuntoTransbordo? mejorTransbordo;
    double mejorDistancia = double.maxFinite;

    for (final puntoOrigen in puntosOrigen) {
      for (final puntoDestino in puntosDestino) {
        final distancia = _calcularDistanciaKm(
          puntoOrigen.latitud,
          puntoOrigen.longitud,
          puntoDestino.latitud,
          puntoDestino.longitud,
        );

        // Buscar puntos cercanos entre rutas (máximo 500m caminando)
        if (distancia <= 0.5 && distancia < mejorDistancia) {
          mejorDistancia = distancia;
          final tiempoCaminando = _calcularTiempoCaminando(distancia * 1000);

          mejorTransbordo = PuntoTransbordo(
            ubicacion: LatLng(puntoOrigen.latitud, puntoOrigen.longitud),
            distanciaCaminando: distancia,
            tiempoCaminando: tiempoCaminando,
            rutaOrigen: rutaOrigen,
            rutaDestino: rutaDestino,
            nombreParada: 'Parada de transbordo',
          );
        }
      }
    }

    return mejorTransbordo;
  }

  // 🔥 MÉTODOS AUXILIARES (del controlador anterior)
  Future<List<RutaCercanaInfo>> _buscarRutasCercanas(
    LatLng punto,
    List<Ruta> todasLasRutas,
    double radioKm,
  ) async {
    final rutasCercanas = <RutaCercanaInfo>[];

    for (final ruta in todasLasRutas) {
      final puntosRuta = _puntosRuta
          .where((p) => p.RutaId == ruta.IdRuta)
          .toList();
      if (puntosRuta.isEmpty) continue;

      final puntoCercano = _encontrarPuntoMasCercano(punto, puntosRuta);
      final distancia = _calcularDistanciaKm(
        punto.latitude,
        punto.longitude,
        puntoCercano.latitud,
        puntoCercano.longitud,
      );

      if (distancia <= radioKm) {
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

  bool _verificarOrdenRuta(
    List<PuntoRuta> puntosRuta,
    PuntoRuta puntoOrigen,
    PuntoRuta puntoDestino,
  ) {
    puntosRuta.sort((a, b) => a.orden.compareTo(b.orden));

    int indiceOrigen = -1;
    int indiceDestino = -1;

    for (int i = 0; i < puntosRuta.length; i++) {
      if (puntosRuta[i].IdPunto == puntoOrigen.IdPunto) {
        indiceOrigen = i;
      }
      if (puntosRuta[i].IdPunto == puntoDestino.IdPunto) {
        indiceDestino = i;
      }
    }

    print('DEBUG: Origen=$indiceOrigen, Destino=$indiceDestino');
    return indiceOrigen != -1 &&
        indiceDestino != -1 &&
        indiceOrigen < indiceDestino;
  }

  double _calcularDistanciaEntrePuntos(PuntoRuta p1, PuntoRuta p2) {
    return _calcularDistanciaKm(
      p1.latitud,
      p1.longitud,
      p2.latitud,
      p2.longitud,
    );
  }

  PuntoRuta _encontrarPuntoMasCercano(
    LatLng ubicacion,
    List<PuntoRuta> puntosRuta,
  ) {
    // PRIMERO ordenar por orden de ruta
    puntosRuta.sort((a, b) => a.orden.compareTo(b.orden));

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

    print(
      '📍 Punto cercano: ID=${puntoMasCercano.IdPunto}, Orden=${puntoMasCercano.orden}',
    );
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
    return (distanciaMetros / 80).round(); // 80m/min ≈ 4.8km/h
  }

  int _estimarTiempoBus(Ruta ruta, PuntoRuta inicio, PuntoRuta fin) {
    final distancia = _calcularDistanciaEntrePuntos(inicio, fin);
    return (distancia / 20 * 60 + distancia * 0.5).round(); // 20km/h + paradas
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

  String _generarMensajeResultado(List<RutaCompleta> rutas) {
    if (rutas.isEmpty) return 'No se encontraron rutas disponibles';
    if (rutas.first.esDirecta) return '¡Ruta directa encontrada!';
    return 'Ruta con transbordo disponible';
  }
}

// 🔥 MODELOS TEMPORALES (para compatibilidad)
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

// 🔥 MÉTODO PARA CREAR RUTA CON TRANSBORDO (completar)
Future<RutaCompleta> _crearRutaConTransbordo(
  LatLng origen,
  LatLng destino,
  Ruta rutaOrigen,
  Ruta rutaDestino,
  PuntoTransbordo transbordo,
) async {
  // Implementar lógica para crear ruta con transbordo
  // Similar a _buscarRutasDirectas pero con dos buses
  return RutaCompleta(
    segmentos: [],
    tiempoTotal: 0,
    distanciaTotal: 0,
    tipo: 'CON_TRANSBORDO',
    instrucciones: 'Transbordo en ${transbordo.nombreParada}',
    prioridad: 2,
  );
}
