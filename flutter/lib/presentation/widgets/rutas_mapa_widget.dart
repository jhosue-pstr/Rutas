import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/rutas.dart';
import '../../data/models/punto_ruta.dart';
import '../../presentation/controllers/ruta_controller.dart';
import '../../presentation/controllers/punto_ruta_controller.dart';

class RutasMapaWidget extends StatefulWidget {
  final Function(Set<Polyline>)? onRutasCargadas;

  const RutasMapaWidget({Key? key, this.onRutasCargadas}) : super(key: key);

  @override
  State<RutasMapaWidget> createState() => _RutasMapaWidgetState();
}

class _RutasMapaWidgetState extends State<RutasMapaWidget> {
  final RutaController _rutaController = RutaController();
  final PuntoRutaController _puntoRutaController = PuntoRutaController();

  List<Ruta> _rutas = [];
  List<PuntoRuta> _puntosRuta = [];
  Set<Polyline> _polylinesRutas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRutasYPuntos();
  }

  Future<void> _cargarRutasYPuntos() async {
    try {
      _rutas = await _rutaController.obtenerRutas();
      _puntosRuta = await _puntoRutaController.obtenerPuntosRuta();
      await _generarPolylinesRutas();
      setState(() => _cargando = false);
    } catch (e) {
      print('❌ Error cargando rutas: $e');
      setState(() => _cargando = false);
    }
  }

  Future<void> _generarPolylinesRutas() async {
    _polylinesRutas.clear();

    for (final ruta in _rutas) {
      final puntosDeRuta =
          _puntosRuta.where((p) => p.RutaId == ruta.IdRuta).toList()
            ..sort((a, b) => a.orden.compareTo(b.orden));

      if (puntosDeRuta.length < 2) continue;

      try {
        final polyline = await _crearPolylineOptimizada(ruta, puntosDeRuta);
        _polylinesRutas.add(polyline);

        print(
          '✅ Ruta ${ruta.nombre} optimizada con ${polyline.points.length} puntos',
        );
      } catch (e) {
        print('❌ Error en ruta ${ruta.nombre}: $e');
        // Crear polyline básica como fallback
        final polylineBasica = _crearPolylineBasica(ruta, puntosDeRuta);
        _polylinesRutas.add(polylineBasica);
      }
    }

    widget.onRutasCargadas?.call(_polylinesRutas);
  }

  Future<Polyline> _crearPolylineOptimizada(
    Ruta ruta,
    List<PuntoRuta> puntosDeRuta,
  ) async {
    final puntosLatLng = puntosDeRuta
        .map((p) => LatLng(p.latitud, p.longitud))
        .toList();

    // Para rutas con muchos puntos, dividir en segmentos
    if (puntosLatLng.length > 10) {
      return await _crearPolylineSegmentada(ruta, puntosLatLng);
    } else {
      return await _crearPolylineCompleta(ruta, puntosLatLng);
    }
  }

  Future<Polyline> _crearPolylineCompleta(
    Ruta ruta,
    List<LatLng> puntos,
  ) async {
    try {
      final rutaOptimizada = await _obtenerRutaGoogleDirections(
        origen: puntos.first,
        destino: puntos.last,
        waypoints: puntos.sublist(1, puntos.length - 1),
      );

      return Polyline(
        polylineId: PolylineId('ruta_${ruta.IdRuta}'),
        points: rutaOptimizada.isNotEmpty ? rutaOptimizada : puntos,
        color: _hexToColor(ruta.color ?? '#3F51B5'),
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );
    } catch (e) {
      // Si falla, usar puntos directos
      return _crearPolylineBasica(ruta, puntos);
    }
  }

  Future<Polyline> _crearPolylineSegmentada(
    Ruta ruta,
    List<LatLng> puntos,
  ) async {
    final segmentos = <LatLng>[];
    const maxPuntosPorSegmento = 8;

    for (int i = 0; i < puntos.length - 1; i += maxPuntosPorSegmento - 1) {
      final fin = (i + maxPuntosPorSegmento < puntos.length)
          ? i + maxPuntosPorSegmento
          : puntos.length;
      final segmento = puntos.sublist(i, fin);

      if (segmento.length >= 2) {
        try {
          final segmentoOptimizado = await _obtenerRutaGoogleDirections(
            origen: segmento.first,
            destino: segmento.last,
            waypoints: segmento.length > 2
                ? segmento.sublist(1, segmento.length - 1)
                : [],
          );

          // Eliminar el último punto para evitar duplicados (excepto en el último segmento)
          if (fin < puntos.length && segmentoOptimizado.isNotEmpty) {
            segmentos.addAll(
              segmentoOptimizado.sublist(0, segmentoOptimizado.length - 1),
            );
          } else {
            segmentos.addAll(segmentoOptimizado);
          }
        } catch (e) {
          // Si falla un segmento, usar los puntos originales
          segmentos.addAll(
            segmento.sublist(
              0,
              segmento.length - (fin < puntos.length ? 1 : 0),
            ),
          );
        }
      }
    }

    // Asegurar que el último punto esté incluido
    if (segmentos.isEmpty || segmentos.last != puntos.last) {
      segmentos.add(puntos.last);
    }

    return Polyline(
      polylineId: PolylineId('ruta_${ruta.IdRuta}'),
      points: segmentos,
      color: _hexToColor(ruta.color ?? '#3F51B5'),
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  Polyline _crearPolylineBasica(dynamic ruta, List<dynamic> puntos) {
    List<LatLng> puntosLatLng;

    if (puntos.first is PuntoRuta) {
      puntosLatLng = (puntos as List<PuntoRuta>)
          .map((p) => LatLng(p.latitud, p.longitud))
          .toList();
    } else {
      puntosLatLng = puntos as List<LatLng>;
    }

    return Polyline(
      polylineId: PolylineId('ruta_${ruta.IdRuta}'),
      points: puntosLatLng,
      color: _hexToColor(ruta.color ?? '#3F51B5'),
      width: 4,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  // ✅ API DE DIRECTIONS MEJORADA
  Future<List<LatLng>> _obtenerRutaGoogleDirections({
    required LatLng origen,
    required LatLng destino,
    List<LatLng> waypoints = const [],
  }) async {
    const apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M";

    // Limitar waypoints para evitar errores (máximo 23 waypoints)
    final waypointsLimitados = waypoints.length > 23
        ? waypoints.sublist(0, 23)
        : waypoints;

    String waypointsParam = '';
    if (waypointsLimitados.isNotEmpty) {
      waypointsParam =
          '&waypoints=optimize:true|${waypointsLimitados.map((p) => 'via:${p.latitude},${p.longitude}').join('|')}';
    }

    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${origen.latitude},${origen.longitude}"
        "&destination=${destino.latitude},${destino.longitude}"
        "&mode=driving"
        "$waypointsParam"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final points = route['overview_polyline']['points'];

        // Verificar que la ruta tenga distancia razonable
        final distancia = route['legs'][0]['distance']['value']; // en metros
        if (distancia > 50000) {
          // Más de 50km - probablemente error
          throw Exception('Distancia de ruta no válida: ${distancia}m');
        }

        return _decodePolyline(points);
      } else {
        throw Exception(
          'API Error: ${data['status']} - ${data['error_message'] ?? ''}',
        );
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return poly;
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink(); // Widget invisible
  }
}
