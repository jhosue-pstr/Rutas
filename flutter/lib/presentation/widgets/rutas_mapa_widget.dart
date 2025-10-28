import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rutasfrontend/data/services/ruta_completa.dart';
import '../../data/models/rutas.dart';
import '../../data/models/punto_ruta.dart';
import '../../presentation/controllers/ruta_controller.dart';
import '../../presentation/controllers/punto_ruta_controller.dart';

class MapaRutaWidget extends StatefulWidget {
  final RutaCompleta? rutaEspecifica;
  final bool mostrarTodasLasRutas;
  final Function(Set<Polyline>)? onRutasCargadas;

  const MapaRutaWidget({
    super.key,
    this.rutaEspecifica,
    this.mostrarTodasLasRutas = false,
    this.onRutasCargadas,
  });

  @override
  State<MapaRutaWidget> createState() => _MapaRutaWidgetState();
}

class _MapaRutaWidgetState extends State<MapaRutaWidget> {
  late GoogleMapController _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  final RutaController _rutaController = RutaController();
  final PuntoRutaController _puntoRutaController = PuntoRutaController();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _configurarMapa();
  }

  void _configurarMapa() async {
    if (widget.rutaEspecifica != null) {
      await _configurarRutaEspecifica();
    } else if (widget.mostrarTodasLasRutas) {
      await _configurarTodasLasRutas();
    }
    setState(() => _cargando = false);
  }

  Future<void> _configurarRutaEspecifica() async {
    _agregarMarkersRutaEspecifica();
    await _agregarPolylinesRutaEspecifica();
    widget.onRutasCargadas?.call(_polylines);
  }

  Future<void> _configurarTodasLasRutas() async {
    await _cargarYMostrarTodasLasRutas();
    widget.onRutasCargadas?.call(_polylines);
  }

  void _agregarMarkersRutaEspecifica() {
    final ruta = widget.rutaEspecifica!;

    _markers.add(
      Marker(
        markerId: const MarkerId('origen'),
        position: ruta.segmentos.first.puntoInicio,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Origen'),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('destino'),
        position: ruta.segmentos.last.puntoFin,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destino'),
      ),
    );

    int paradaCount = 1;
    for (final segmento in ruta.segmentos) {
      if (segmento.esBus) {
        _markers.add(
          Marker(
            markerId: MarkerId('parada_$paradaCount'),
            position: segmento.puntoInicio,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(
              title: 'Parada ${segmento.ruta?.nombre ?? 'Bus'}',
              snippet: 'Toma el bus ${segmento.ruta?.nombre}',
            ),
          ),
        );
        paradaCount++;
      }
    }
  }

  Future<void> _agregarPolylinesRutaEspecifica() async {
    final ruta = widget.rutaEspecifica!;

    for (final segmento in ruta.segmentos) {
      // ✅ CORREGIDO: Color diferenciado
      final color = segmento.esBus
          ? _hexToColor(
              segmento.ruta?.color ?? '#3F51B5',
            ) // Color de la BD para buses
          : Colors.green; // Verde para caminar

      try {
        final puntosOptimizados = await _obtenerRutaGoogleDirections(
          origen: segmento.puntoInicio,
          destino: segmento.puntoFin,
          mode: segmento.esCaminando ? 'walking' : 'driving',
        );

        _polylines.add(
          Polyline(
            polylineId: PolylineId('segmento_${segmento.hashCode}'),
            points: puntosOptimizados.isNotEmpty
                ? puntosOptimizados
                : [segmento.puntoInicio, segmento.puntoFin],
            color: color,
            width: segmento.esBus ? 5 : 3,
            patterns: segmento.esCaminando
                ? [
                    PatternItem.dash(10),
                    PatternItem.gap(5),
                  ] // ✅ Línea punteada para caminar
                : [], // ✅ Línea sólida para buses
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      } catch (e) {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('segmento_${segmento.hashCode}'),
            points: [segmento.puntoInicio, segmento.puntoFin],
            color: color, // ✅ Color correcto aquí también
            width: segmento.esBus ? 6 : 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }
    }
  }

  Future<void> _cargarYMostrarTodasLasRutas() async {
    try {
      final rutas = await _rutaController.obtenerRutas();
      final puntosRuta = await _puntoRutaController.obtenerPuntosRuta();

      for (final ruta in rutas) {
        final puntosDeRuta =
            puntosRuta.where((p) => p.RutaId == ruta.IdRuta).toList()
              ..sort((a, b) => a.orden.compareTo(b.orden));

        if (puntosDeRuta.length < 2) continue;

        try {
          final polyline = await _crearPolylineOptimizada(ruta, puntosDeRuta);
          _polylines.add(polyline);
        } catch (e) {
          final polylineBasica = _crearPolylineBasica(ruta, puntosDeRuta);
          _polylines.add(polylineBasica);
        }
      }

      _agregarMarkersTodasLasRutas(rutas, puntosRuta);
    } catch (e) {
      print('❌ Error cargando todas las rutas: $e');
    }
  }

  void _agregarMarkersTodasLasRutas(
    List<Ruta> rutas,
    List<PuntoRuta> puntosRuta,
  ) {
    for (final ruta in rutas) {
      final puntosDeRuta =
          puntosRuta.where((p) => p.RutaId == ruta.IdRuta).toList()
            ..sort((a, b) => a.orden.compareTo(b.orden));

      if (puntosDeRuta.isEmpty) continue;

      _markers.add(
        Marker(
          markerId: MarkerId('inicio_${ruta.IdRuta}'),
          position: LatLng(
            puntosDeRuta.first.latitud,
            puntosDeRuta.first.longitud,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Inicio: ${ruta.nombre}'),
        ),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('fin_${ruta.IdRuta}'),
          position: LatLng(
            puntosDeRuta.last.latitud,
            puntosDeRuta.last.longitud,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(title: 'Fin: ${ruta.nombre}'),
        ),
      );
    }
  }

  Future<Polyline> _crearPolylineOptimizada(
    Ruta ruta,
    List<PuntoRuta> puntosDeRuta,
  ) async {
    final puntosLatLng = puntosDeRuta
        .map((p) => LatLng(p.latitud, p.longitud))
        .toList();

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

          if (fin < puntos.length && segmentoOptimizado.isNotEmpty) {
            segmentos.addAll(
              segmentoOptimizado.sublist(0, segmentoOptimizado.length - 1),
            );
          } else {
            segmentos.addAll(segmentoOptimizado);
          }
        } catch (e) {
          segmentos.addAll(
            segmento.sublist(
              0,
              segmento.length - (fin < puntos.length ? 1 : 0),
            ),
          );
        }
      }
    }

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

  Future<List<LatLng>> _obtenerRutaGoogleDirections({
    required LatLng origen,
    required LatLng destino,
    List<LatLng> waypoints = const [],
    String mode = 'driving',
  }) async {
    const apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M";

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
        "&mode=$mode"
        "$waypointsParam"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final points = route['overview_polyline']['points'];

        final distancia = route['legs'][0]['distance']['value'];
        if (distancia > 50000) {
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
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _zoomToRoute() async {
    final bounds = _calcularBounds();
    await _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  LatLngBounds _calcularBounds() {
    if (_polylines.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(-15.6, -70.2),
        northeast: const LatLng(-15.4, -70.0),
      );
    }

    double minLat = double.maxFinite;
    double maxLat = double.negativeInfinity;
    double minLng = double.maxFinite;
    double maxLng = double.negativeInfinity;

    for (final polyline in _polylines) {
      for (final point in polyline.points) {
        minLat = point.latitude < minLat ? point.latitude : minLat;
        maxLat = point.latitude > maxLat ? point.latitude : maxLat;
        minLng = point.longitude < minLng ? point.longitude : minLng;
        maxLng = point.longitude > maxLng ? point.longitude : maxLng;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng puntoInicial = const LatLng(-15.4999, -70.1376);

    if (widget.rutaEspecifica != null) {
      puntoInicial = widget.rutaEspecifica!.segmentos.first.puntoInicio;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.rutaEspecifica != null ? 'Ruta Calculada' : 'Todas las Rutas',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: _zoomToRoute,
            tooltip: 'Ajustar vista',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _zoomToRoute(),
                );
              },
              initialCameraPosition: CameraPosition(
                target: puntoInicial,
                zoom: 14,
              ),
              polylines: _polylines,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
