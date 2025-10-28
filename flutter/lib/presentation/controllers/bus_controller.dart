// import 'dart:math';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:rutasfrontend/data/services/punto_transbordo.dart';
// import 'package:rutasfrontend/data/services/resultado_ruta.dart';
// import 'package:rutasfrontend/data/services/ruta_completa.dart';
// import 'package:rutasfrontend/data/services/segmento_ruta.dart';
// import '../../data/models/bus.dart';
// import '../../data/models/rutas.dart';
// import '../../data/models/punto_ruta.dart';
// import '../../data/services/bus_service.dart';
// import './punto_ruta_controller.dart';
// import './ruta_controller.dart';

// class BusControllerMejorado {
//   final BusService _busService = BusService();
//   final RutaController _rutaController = RutaController();
//   final PuntoRutaController _puntoRutaController = PuntoRutaController();
//   List<PuntoRuta> _puntosRuta = [];

//   Future<ResultadoRuta> calcularMejorRuta(
//     LatLng origen,
//     LatLng destino, {
//     double radioBusquedaKm = 0.5,
//   }) async {
//     print('🚀 CALCULANDO MEJOR RUTA: $origen → $destino');

//     if (_puntosRuta.isEmpty) {
//       await _cargarPuntosRuta();
//     }

//     final todasLasRutas = await _rutaController.obtenerRutas();
//     final rutasRecomendadas = <RutaCompleta>[];

//     final rutasDirectas = await _buscarRutasDirectas(
//       origen,
//       destino,
//       todasLasRutas,
//       radioBusquedaKm,
//     );

//     if (rutasDirectas.isNotEmpty) {
//       print('✅ Encontradas ${rutasDirectas.length} rutas directas');
//       rutasRecomendadas.addAll(rutasDirectas);
//     }

//     if (rutasDirectas.isEmpty) {
//       print('🔍 Buscando rutas con transbordo...');
//       final rutasConTransbordo = await _buscarRutasConTransbordo(
//         origen,
//         destino,
//         todasLasRutas,
//         radioBusquedaKm,
//       );

//       if (rutasConTransbordo.isNotEmpty) {
//         print(
//           '✅ Encontradas ${rutasConTransbordo.length} rutas con transbordo',
//         );
//         rutasRecomendadas.addAll(rutasConTransbordo);
//       }
//     }

//     rutasRecomendadas.sort((a, b) => a.tiempoTotal.compareTo(b.tiempoTotal));

//     return ResultadoRuta(
//       rutasRecomendadas: rutasRecomendadas.take(3).toList(),
//       hayRutasDirectas: rutasDirectas.isNotEmpty,
//       mensaje: _generarMensajeResultado(rutasRecomendadas),
//       origen: origen,
//       destino: destino,
//     );
//   }

//   // 🔥 BUSCAR RUTAS DIRECTAS
//   Future<List<RutaCompleta>> _buscarRutasDirectas(
//     LatLng origen,
//     LatLng destino,
//     List<Ruta> todasLasRutas,
//     double radioKm,
//   ) async {
//     final rutasDirectas = <RutaCompleta>[];

//     for (final ruta in todasLasRutas) {
//       final puntosRuta = _puntosRuta
//           .where((p) => p.RutaId == ruta.IdRuta)
//           .toList();

//       if (puntosRuta.length < 2) continue;

//       final puntoCercanoOrigen = _encontrarPuntoMasCercano(origen, puntosRuta);
//       final distanciaOrigen = _calcularDistanciaKm(
//         origen.latitude,
//         origen.longitude,
//         puntoCercanoOrigen.latitud,
//         puntoCercanoOrigen.longitud,
//       );

//       final puntoCercanoDestino = _encontrarPuntoMasCercano(
//         destino,
//         puntosRuta,
//       );
//       final distanciaDestino = _calcularDistanciaKm(
//         destino.latitude,
//         destino.longitude,
//         puntoCercanoDestino.latitud,
//         puntoCercanoDestino.longitud,
//       );

//       final ordenCorrecto = _verificarOrdenRuta(
//         puntosRuta,
//         puntoCercanoOrigen,
//         puntoCercanoDestino,
//       );

//       if (distanciaOrigen <= radioKm &&
//           distanciaDestino <= radioKm &&
//           ordenCorrecto) {
//         // Crear segmento de ruta directa
//         final tiempoCaminandoOrigen = _calcularTiempoCaminando(
//           distanciaOrigen * 1000,
//         );
//         final tiempoCaminandoDestino = _calcularTiempoCaminando(
//           distanciaDestino * 1000,
//         );
//         final tiempoBus = _estimarTiempoBus(
//           ruta,
//           puntoCercanoOrigen,
//           puntoCercanoDestino,
//         );

//         final segmentos = [
//           SegmentoRuta(
//             puntoInicio: origen,
//             puntoFin: LatLng(
//               puntoCercanoOrigen.latitud,
//               puntoCercanoOrigen.longitud,
//             ),
//             tiempoEstimado: tiempoCaminandoOrigen,
//             distancia: distanciaOrigen,
//             tipo: 'CAMINANDO',
//             instruccion:
//                 'Camina ${distanciaOrigen.toStringAsFixed(1)} km hasta la parada',
//           ),
//           SegmentoRuta(
//             ruta: ruta,
//             puntoInicio: LatLng(
//               puntoCercanoOrigen.latitud,
//               puntoCercanoOrigen.longitud,
//             ),
//             puntoFin: LatLng(
//               puntoCercanoDestino.latitud,
//               puntoCercanoDestino.longitud,
//             ),
//             tiempoEstimado: tiempoBus,
//             distancia: _calcularDistanciaEntrePuntos(
//               puntoCercanoOrigen,
//               puntoCercanoDestino,
//             ),
//             tipo: 'BUS',
//             instruccion: 'Toma el bus ${ruta.nombre}',
//           ),
//           SegmentoRuta(
//             puntoInicio: LatLng(
//               puntoCercanoDestino.latitud,
//               puntoCercanoDestino.longitud,
//             ),
//             puntoFin: destino,
//             tiempoEstimado: tiempoCaminandoDestino,
//             distancia: distanciaDestino,
//             tipo: 'CAMINANDO',
//             instruccion:
//                 'Camina ${distanciaDestino.toStringAsFixed(1)} km hasta tu destino',
//           ),
//         ];

//         final tiempoTotal =
//             tiempoCaminandoOrigen + tiempoBus + tiempoCaminandoDestino;
//         final distanciaTotal =
//             distanciaOrigen +
//             _calcularDistanciaEntrePuntos(
//               puntoCercanoOrigen,
//               puntoCercanoDestino,
//             ) +
//             distanciaDestino;

//         rutasDirectas.add(
//           RutaCompleta(
//             segmentos: segmentos,
//             tiempoTotal: tiempoTotal,
//             distanciaTotal: distanciaTotal,
//             tipo: 'DIRECTA',
//             instrucciones: 'Toma el bus ${ruta.nombre} directamente',
//             prioridad: 1,
//           ),
//         );
//       }
//     }

//     return rutasDirectas;
//   }

//   Future<List<RutaCompleta>> _buscarRutasConTransbordo(
//     LatLng origen,
//     LatLng destino,
//     List<Ruta> todasLasRutas,
//     double radioKm,
//   ) async {
//     final rutasConTransbordo = <RutaCompleta>[];

//     final rutasCercaOrigenInfo = await _buscarRutasCercanas(
//       origen,
//       todasLasRutas,
//       radioKm,
//     );
//     final rutasCercaDestinoInfo = await _buscarRutasCercanas(
//       destino,
//       todasLasRutas,
//       radioKm,
//     );

//     final rutasCercaOrigen = rutasCercaOrigenInfo
//         .map((info) => info.ruta)
//         .toList();
//     final rutasCercaDestino = rutasCercaDestinoInfo
//         .map((info) => info.ruta)
//         .toList();

//     for (final rutaOrigen in rutasCercaOrigen) {
//       for (final rutaDestino in rutasCercaDestino) {
//         if (rutaOrigen.IdRuta != rutaDestino.IdRuta) {
//           final transbordo = await _encontrarMejorTransbordo(
//             rutaOrigen,
//             rutaDestino,
//           );
//           if (transbordo != null) {
//             final rutaCompleta = await _crearRutaConTransbordo(
//               origen,
//               destino,
//               rutaOrigen,
//               rutaDestino,
//               transbordo,
//             );
//             rutasConTransbordo.add(rutaCompleta);
//           }
//         }
//       }
//     }

//     return rutasConTransbordo;
//   }

//   Future<RutaCompleta> _crearRutaConTransbordo(
//     LatLng origen,
//     LatLng destino,
//     Ruta rutaOrigen,
//     Ruta rutaDestino,
//     PuntoTransbordo transbordo,
//   ) async {
//     final puntosRutaOrigen = _puntosRuta
//         .where((p) => p.RutaId == rutaOrigen.IdRuta)
//         .toList();
//     final puntosRutaDestino = _puntosRuta
//         .where((p) => p.RutaId == rutaDestino.IdRuta)
//         .toList();

//     final puntoOrigenCercano = _encontrarPuntoMasCercano(
//       origen,
//       puntosRutaOrigen,
//     );
//     final puntoTransbordoOrigen = _encontrarPuntoMasCercano(
//       transbordo.ubicacion,
//       puntosRutaOrigen,
//     );
//     final puntoTransbordoDestino = _encontrarPuntoMasCercano(
//       transbordo.ubicacion,
//       puntosRutaDestino,
//     );
//     final puntoDestinoCercano = _encontrarPuntoMasCercano(
//       destino,
//       puntosRutaDestino,
//     );

//     final distanciaOrigen = _calcularDistanciaKm(
//       origen.latitude,
//       origen.longitude,
//       puntoOrigenCercano.latitud,
//       puntoOrigenCercano.longitud,
//     );

//     final distanciaTransbordo = _calcularDistanciaKm(
//       puntoTransbordoOrigen.latitud,
//       puntoTransbordoOrigen.longitud,
//       puntoTransbordoDestino.latitud,
//       puntoTransbordoDestino.longitud,
//     );

//     final distanciaDestino = _calcularDistanciaKm(
//       puntoDestinoCercano.latitud,
//       puntoDestinoCercano.longitud,
//       destino.latitude,
//       destino.longitude,
//     );

//     final tiempoCaminandoOrigen = _calcularTiempoCaminando(
//       distanciaOrigen * 1000,
//     );
//     final tiempoBus1 = _estimarTiempoBus(
//       rutaOrigen,
//       puntoOrigenCercano,
//       puntoTransbordoOrigen,
//     );
//     final tiempoCaminandoTransbordo = _calcularTiempoCaminando(
//       distanciaTransbordo * 1000,
//     );
//     final tiempoBus2 = _estimarTiempoBus(
//       rutaDestino,
//       puntoTransbordoDestino,
//       puntoDestinoCercano,
//     );
//     final tiempoCaminandoDestino = _calcularTiempoCaminando(
//       distanciaDestino * 1000,
//     );

//     final segmentos = [
//       SegmentoRuta(
//         puntoInicio: origen,
//         puntoFin: LatLng(
//           puntoOrigenCercano.latitud,
//           puntoOrigenCercano.longitud,
//         ),
//         tiempoEstimado: tiempoCaminandoOrigen,
//         distancia: distanciaOrigen,
//         tipo: 'CAMINANDO',
//         instruccion:
//             'Camina ${distanciaOrigen.toStringAsFixed(1)} km hasta la parada',
//       ),
//       SegmentoRuta(
//         ruta: rutaOrigen,
//         puntoInicio: LatLng(
//           puntoOrigenCercano.latitud,
//           puntoOrigenCercano.longitud,
//         ),
//         puntoFin: LatLng(
//           puntoTransbordoOrigen.latitud,
//           puntoTransbordoOrigen.longitud,
//         ),
//         tiempoEstimado: tiempoBus1,
//         distancia: _calcularDistanciaEntrePuntos(
//           puntoOrigenCercano,
//           puntoTransbordoOrigen,
//         ),
//         tipo: 'BUS',
//         instruccion: 'Toma el bus ${rutaOrigen.nombre}',
//       ),
//       // Caminar entre paradas (transbordo)
//       SegmentoRuta(
//         puntoInicio: LatLng(
//           puntoTransbordoOrigen.latitud,
//           puntoTransbordoOrigen.longitud,
//         ),
//         puntoFin: LatLng(
//           puntoTransbordoDestino.latitud,
//           puntoTransbordoDestino.longitud,
//         ),
//         tiempoEstimado: tiempoCaminandoTransbordo,
//         distancia: distanciaTransbordo,
//         tipo: 'CAMINANDO',
//         instruccion:
//             'Baja y camina ${distanciaTransbordo.toStringAsFixed(1)} km hasta la siguiente parada',
//       ),
//       SegmentoRuta(
//         ruta: rutaDestino,
//         puntoInicio: LatLng(
//           puntoTransbordoDestino.latitud,
//           puntoTransbordoDestino.longitud,
//         ),
//         puntoFin: LatLng(
//           puntoDestinoCercano.latitud,
//           puntoDestinoCercano.longitud,
//         ),
//         tiempoEstimado: tiempoBus2,
//         distancia: _calcularDistanciaEntrePuntos(
//           puntoTransbordoDestino,
//           puntoDestinoCercano,
//         ),
//         tipo: 'BUS',
//         instruccion: 'Toma el bus ${rutaDestino.nombre}',
//       ),
//       SegmentoRuta(
//         puntoInicio: LatLng(
//           puntoDestinoCercano.latitud,
//           puntoDestinoCercano.longitud,
//         ),
//         puntoFin: destino,
//         tiempoEstimado: tiempoCaminandoDestino,
//         distancia: distanciaDestino,
//         tipo: 'CAMINANDO',
//         instruccion:
//             'Camina ${distanciaDestino.toStringAsFixed(1)} km hasta tu destino',
//       ),
//     ];

//     final tiempoTotal =
//         tiempoCaminandoOrigen +
//         tiempoBus1 +
//         tiempoCaminandoTransbordo +
//         tiempoBus2 +
//         tiempoCaminandoDestino;
//     final distanciaTotal =
//         distanciaOrigen +
//         _calcularDistanciaEntrePuntos(
//           puntoOrigenCercano,
//           puntoTransbordoOrigen,
//         ) +
//         distanciaTransbordo +
//         _calcularDistanciaEntrePuntos(
//           puntoTransbordoDestino,
//           puntoDestinoCercano,
//         ) +
//         distanciaDestino;

//     return RutaCompleta(
//       segmentos: segmentos,
//       tiempoTotal: tiempoTotal,
//       distanciaTotal: distanciaTotal,
//       tipo: 'CON_TRANSBORDO',
//       instrucciones:
//           'Toma bus ${rutaOrigen.nombre}, transborda en ${transbordo.nombreParada} y toma bus ${rutaDestino.nombre}',
//       prioridad: 2,
//     );
//   }

//   // 🔥 ENCONTRAR MEJOR PUNTO DE TRANSBORDO
//   Future<PuntoTransbordo?> _encontrarMejorTransbordo(
//     Ruta rutaOrigen,
//     Ruta rutaDestino,
//   ) async {
//     final puntosOrigen = _puntosRuta
//         .where((p) => p.RutaId == rutaOrigen.IdRuta)
//         .toList();
//     final puntosDestino = _puntosRuta
//         .where((p) => p.RutaId == rutaDestino.IdRuta)
//         .toList();

//     PuntoTransbordo? mejorTransbordo;
//     double mejorDistancia = double.maxFinite;

//     for (final puntoOrigen in puntosOrigen) {
//       for (final puntoDestino in puntosDestino) {
//         final distancia = _calcularDistanciaKm(
//           puntoOrigen.latitud,
//           puntoOrigen.longitud,
//           puntoDestino.latitud,
//           puntoDestino.longitud,
//         );

//         if (distancia <= 0.5 && distancia < mejorDistancia) {
//           mejorDistancia = distancia;
//           final tiempoCaminando = _calcularTiempoCaminando(distancia * 1000);

//           mejorTransbordo = PuntoTransbordo(
//             ubicacion: LatLng(puntoOrigen.latitud, puntoOrigen.longitud),
//             distanciaCaminando: distancia,
//             tiempoCaminando: tiempoCaminando,
//             rutaOrigen: rutaOrigen,
//             rutaDestino: rutaDestino,
//             nombreParada: 'Parada de transbordo',
//           );
//         }
//       }
//     }

//     return mejorTransbordo;
//   }

//   Future<List<RutaCercanaInfo>> _buscarRutasCercanas(
//     LatLng punto,
//     List<Ruta> todasLasRutas,
//     double radioKm,
//   ) async {
//     final rutasCercanas = <RutaCercanaInfo>[];

//     for (final ruta in todasLasRutas) {
//       final puntosRuta = _puntosRuta
//           .where((p) => p.RutaId == ruta.IdRuta)
//           .toList();
//       if (puntosRuta.isEmpty) continue;

//       final puntoCercano = _encontrarPuntoMasCercano(punto, puntosRuta);
//       final distancia = _calcularDistanciaKm(
//         punto.latitude,
//         punto.longitude,
//         puntoCercano.latitud,
//         puntoCercano.longitud,
//       );

//       if (distancia <= radioKm) {
//         rutasCercanas.add(
//           RutaCercanaInfo(
//             ruta: ruta,
//             puntoCercano: LatLng(puntoCercano.latitud, puntoCercano.longitud),
//             distancia: distancia,
//           ),
//         );
//       }
//     }

//     return rutasCercanas;
//   }

//   bool _verificarOrdenRuta(
//     List<PuntoRuta> puntosRuta,
//     PuntoRuta puntoOrigen,
//     PuntoRuta puntoDestino,
//   ) {
//     puntosRuta.sort((a, b) => a.orden.compareTo(b.orden));

//     int indiceOrigen = -1;
//     int indiceDestino = -1;

//     for (int i = 0; i < puntosRuta.length; i++) {
//       if (puntosRuta[i].IdPunto == puntoOrigen.IdPunto) {
//         indiceOrigen = i;
//       }
//       if (puntosRuta[i].IdPunto == puntoDestino.IdPunto) {
//         indiceDestino = i;
//       }
//     }

//     print('DEBUG: Origen=$indiceOrigen, Destino=$indiceDestino');
//     return indiceOrigen != -1 &&
//         indiceDestino != -1 &&
//         indiceOrigen < indiceDestino;
//   }

//   double _calcularDistanciaEntrePuntos(PuntoRuta p1, PuntoRuta p2) {
//     return _calcularDistanciaKm(
//       p1.latitud,
//       p1.longitud,
//       p2.latitud,
//       p2.longitud,
//     );
//   }

//   PuntoRuta _encontrarPuntoMasCercano(
//     LatLng ubicacion,
//     List<PuntoRuta> puntosRuta,
//   ) {
//     // PRIMERO ordenar por orden de ruta
//     puntosRuta.sort((a, b) => a.orden.compareTo(b.orden));

//     PuntoRuta puntoMasCercano = puntosRuta.first;
//     double distanciaMinima = double.maxFinite;

//     for (final punto in puntosRuta) {
//       final distancia = _calcularDistanciaKm(
//         ubicacion.latitude,
//         ubicacion.longitude,
//         punto.latitud,
//         punto.longitud,
//       );

//       if (distancia < distanciaMinima) {
//         distanciaMinima = distancia;
//         puntoMasCercano = punto;
//       }
//     }

//     print(
//       '📍 Punto cercano: ID=${puntoMasCercano.IdPunto}, Orden=${puntoMasCercano.orden}',
//     );
//     return puntoMasCercano;
//   }

//   double _calcularDistanciaKm(
//     double lat1,
//     double lon1,
//     double lat2,
//     double lon2,
//   ) {
//     const radioTierra = 6371.0;
//     final dLat = _toRadians(lat2 - lat1);
//     final dLon = _toRadians(lon2 - lon1);
//     final a =
//         sin(dLat / 2) * sin(dLat / 2) +
//         cos(_toRadians(lat1)) *
//             cos(_toRadians(lat2)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return radioTierra * c;
//   }

//   double _toRadians(double degrees) => degrees * pi / 180;

//   int _calcularTiempoCaminando(double distanciaMetros) {
//     return (distanciaMetros / 80).round();
//   }

//   int _estimarTiempoBus(Ruta ruta, PuntoRuta inicio, PuntoRuta fin) {
//     final distancia = _calcularDistanciaEntrePuntos(inicio, fin);
//     return (distancia / 20 * 60 + distancia * 0.5).round();
//   }

//   Future<void> _cargarPuntosRuta() async {
//     try {
//       _puntosRuta = await _puntoRutaController.obtenerPuntosRuta();
//       print('📍 Puntos de ruta cargados: ${_puntosRuta.length}');
//     } catch (e) {
//       print('❌ Error cargando puntos de ruta: $e');
//       _puntosRuta = [];
//     }
//   }

//   String _generarMensajeResultado(List<RutaCompleta> rutas) {
//     if (rutas.isEmpty) return 'No se encontraron rutas disponibles';
//     if (rutas.first.esDirecta) return '¡Ruta directa encontrada!';
//     return 'Ruta con transbordo disponible';
//   }
// }

// class RutaCercanaInfo {
//   final Ruta ruta;
//   final LatLng puntoCercano;
//   final double distancia;

//   RutaCercanaInfo({
//     required this.ruta,
//     required this.puntoCercano,
//     required this.distancia,
//   });
// }

// Future<RutaCompleta> _crearRutaConTransbordo(
//   LatLng origen,
//   LatLng destino,
//   Ruta rutaOrigen,
//   Ruta rutaDestino,
//   PuntoTransbordo transbordo,
// ) async {
//   return RutaCompleta(
//     segmentos: [],
//     tiempoTotal: 0,
//     distanciaTotal: 0,
//     tipo: 'CON_TRANSBORDO',
//     instrucciones: 'Transbordo en ${transbordo.nombreParada}',
//     prioridad: 2,
//   );
// }

import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rutasfrontend/data/services/punto_transbordo.dart';
import 'package:rutasfrontend/data/services/resultado_ruta.dart';
import 'package:rutasfrontend/data/services/ruta_completa.dart';
import 'package:rutasfrontend/data/services/segmento_ruta.dart';
import 'package:rutasfrontend/data/services/bus_cercano_info.dart';
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

  // ✅ NUEVO: Cache de buses activos
  List<Bus> _busesActivos = [];
  DateTime _ultimaActualizacionBuses = DateTime.now().subtract(
    Duration(minutes: 10),
  );

  Future<ResultadoRuta> calcularMejorRuta(
    LatLng origen,
    LatLng destino, {
    double radioBusquedaKm = 0.5,
  }) async {
    print('🚀 CALCULANDO MEJOR RUTA: $origen → $destino');

    if (_puntosRuta.isEmpty) {
      await _cargarPuntosRuta();
    }

    // ✅ NUEVO: Cargar buses activos
    await _cargarBusesActivos();

    final todasLasRutas = await _rutaController.obtenerRutas();
    final rutasRecomendadas = <RutaCompleta>[];

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

    // ✅ NUEVO: Buscar bus más cercano para cada ruta
    print(
      '🔍 Buscando buses más cercanos para ${rutasRecomendadas.length} rutas...',
    );
    for (final ruta in rutasRecomendadas) {
      await _encontrarBusMasCercanoParaRuta(ruta, origen);
    }

    // ✅ NUEVO: Ordenar por tiempo total incluyendo espera
    rutasRecomendadas.sort(
      (a, b) => a.tiempoTotalConEspera.compareTo(b.tiempoTotalConEspera),
    );

    return ResultadoRuta(
      rutasRecomendadas: rutasRecomendadas.take(3).toList(),
      hayRutasDirectas: rutasDirectas.isNotEmpty,
      mensaje: _generarMensajeResultado(rutasRecomendadas),
      origen: origen,
      destino: destino,
    );
  }

  // ✅ NUEVO: Cargar buses activos desde simulación
  Future<void> _cargarBusesActivos() async {
    try {
      final ahora = DateTime.now();
      if (_busesActivos.isEmpty ||
          ahora.difference(_ultimaActualizacionBuses).inMinutes > 2) {
        print('🔄 Cargando buses activos desde simulación...');
        _busesActivos = await _busService.obtenerBusesActivos();
        _ultimaActualizacionBuses = ahora;
        print('✅ ${_busesActivos.length} buses activos cargados');
      }
    } catch (e) {
      print('❌ Error cargando buses activos: $e');
      _busesActivos = [];
    }
  }

  // ✅ NUEVO: Encontrar bus más cercano para una ruta
  Future<void> _encontrarBusMasCercanoParaRuta(
    RutaCompleta ruta,
    LatLng origenUsuario,
  ) async {
    try {
      // Buscar segmento de bus en la ruta
      final segmentosBus = ruta.segmentos
          .where((segmento) => segmento.tipo == 'BUS')
          .toList();
      if (segmentosBus.isEmpty) {
        _agregarInfoSinBusDisponible(ruta);
        return;
      }

      final segmentoBus = segmentosBus.first;
      if (segmentoBus.ruta == null) {
        _agregarInfoSinBusDisponible(ruta);
        return;
      }

      final rutaId = segmentoBus.ruta!.IdRuta;

      // Filtrar buses de esta ruta específica
      final busesDeRuta = _busesActivos.where((bus) {
        return bus.RutaId == rutaId && bus.tieneUbicacionValida;
      }).toList();

      if (busesDeRuta.isEmpty) {
        print('ℹ️ No hay buses activos para la ruta $rutaId');
        _agregarInfoSinBusDisponible(ruta);
        return;
      }

      print(
        '🎯 Buscando bus más cercano entre ${busesDeRuta.length} buses para ruta ${segmentoBus.ruta!.nombre}',
      );

      // Encontrar el bus más cercano al usuario
      Bus? busMasCercano;
      double distanciaMinima = double.maxFinite;
      LatLng? ubicacionBusMasCercano;

      for (final bus in busesDeRuta) {
        final ubicacionBus = LatLng(bus.latitud!, bus.longitud!);
        final distancia = _calcularDistanciaKm(
          origenUsuario.latitude,
          origenUsuario.longitude,
          bus.latitud!,
          bus.longitud!,
        );

        if (distancia < distanciaMinima) {
          distanciaMinima = distancia;
          busMasCercano = bus;
          ubicacionBusMasCercano = ubicacionBus;
        }
      }

      if (busMasCercano != null && ubicacionBusMasCercano != null) {
        final tiempoEstimado = _calcularTiempoLlegadaBus(
          distanciaMinima,
          busMasCercano.velocidad ?? 25.0,
        );

        final busCercanoInfo = BusCercanoInfo(
          bus: busMasCercano,
          distanciaKm: distanciaMinima,
          tiempoEstimadoMinutos: tiempoEstimado,
          ubicacionBus: ubicacionBusMasCercano,
        );

        // Actualizar la ruta con la información del bus
        _actualizarRutaConBusCercano(ruta, busCercanoInfo, tiempoEstimado);

        print('✅ Bus más cercano encontrado: ${busCercanoInfo.toString()}');
      } else {
        _agregarInfoSinBusDisponible(ruta);
      }
    } catch (e) {
      print('❌ Error buscando bus más cercano: $e');
      _agregarInfoSinBusDisponible(ruta);
    }
  }

  // ✅ NUEVO: Calcular tiempo de llegada del bus
  int _calcularTiempoLlegadaBus(double distanciaKm, double velocidadBus) {
    // Velocidad promedio en ciudad (20-30 km/h)
    double velocidadEfectiva = velocidadBus > 0 ? velocidadBus : 25.0;

    // Considerar tráfico y paradas (reducir velocidad efectiva)
    velocidadEfectiva = velocidadEfectiva * 0.7;

    // Tiempo en minutos = (distancia / velocidad) * 60
    double tiempoHoras = distanciaKm / velocidadEfectiva;
    int tiempoMinutos = (tiempoHoras * 60).round();

    // Agregar tiempo adicional por tráfico y paradas
    tiempoMinutos += (distanciaKm * 0.5).round();

    return tiempoMinutos.clamp(1, 120);
  }

  // ✅ NUEVO: Actualizar ruta con información del bus
  void _actualizarRutaConBusCercano(
    RutaCompleta ruta,
    BusCercanoInfo busCercanoInfo,
    int tiempoEspera,
  ) {
    try {
      // Actualizar campos de la ruta usando dynamic para compatibilidad
      (ruta as dynamic).busCercano = busCercanoInfo;
      (ruta as dynamic).tiempoEsperaBus = tiempoEspera;

      // Actualizar instrucciones
      final nuevaInstruccion =
          '${ruta.instrucciones} - ${busCercanoInfo.toString()}';
      (ruta as dynamic).instrucciones = nuevaInstruccion;
    } catch (e) {
      print('⚠️ Error actualizando ruta con bus: $e');
    }
  }

  // ✅ NUEVO: Manejar casos sin buses disponibles
  void _agregarInfoSinBusDisponible(RutaCompleta ruta) {
    try {
      (ruta as dynamic).busCercano = null;
      (ruta as dynamic).tiempoEsperaBus = 0;
      (ruta as dynamic).instrucciones =
          '${ruta.instrucciones} - Bus no disponible, consulta horarios';
    } catch (e) {
      print('⚠️ Error actualizando ruta sin bus: $e');
    }
  }

  // 🔥 BUSCAR RUTAS DIRECTAS (TODO TU CÓDIGO ORIGINAL)
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

  // 🔥 TODO TU CÓDIGO ORIGINAL RESTANTE (SIN CAMBIOS)
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
    return (distanciaMetros / 80).round();
  }

  int _estimarTiempoBus(Ruta ruta, PuntoRuta inicio, PuntoRuta fin) {
    final distancia = _calcularDistanciaEntrePuntos(inicio, fin);
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

  // ✅ NUEVO: Mensaje mejorado que incluye info de buses
  String _generarMensajeResultado(List<RutaCompleta> rutas) {
    if (rutas.isEmpty) return 'No se encontraron rutas disponibles';

    final rutasConBus = rutas.where((ruta) => ruta.tieneBusDisponible).length;
    if (rutasConBus > 0) {
      return '¡Encontradas $rutasConBus rutas con buses disponibles!';
    }

    if (rutas.first.esDirecta) return '¡Ruta directa encontrada!';
    return 'Ruta con transbordo disponible';
  }
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
