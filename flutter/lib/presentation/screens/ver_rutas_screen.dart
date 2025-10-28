import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/rutas.dart';
import '../../data/models/punto_ruta.dart';
import '../../data/models/ubicacion_bus.dart';
import '../../presentation/controllers/ruta_controller.dart';
import '../../presentation/controllers/punto_ruta_controller.dart';
import '../../presentation/controllers/simulacion_controller.dart';

class VerRutasScreen extends StatefulWidget {
  const VerRutasScreen({super.key});

  @override
  State<VerRutasScreen> createState() => _VerRutasScreenState();
}

class _VerRutasScreenState extends State<VerRutasScreen> {
  final RutaController _rutaController = RutaController();
  final PuntoRutaController _puntoRutaController = PuntoRutaController();
  final SimulacionController _simulacionController = SimulacionController();

  final String apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M"; // Tu API Key

  List<Ruta> _rutas = [];
  List<PuntoRuta> _puntosRuta = [];
  Ruta? _rutaSeleccionada;
  bool _cargando = true;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Map<String, UbicacionBus> _ubicacionesBuses = {};
  StreamSubscription? _ubicacionesSubscription;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _iniciarSimulacion();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() => _cargando = true);

      // Cargar rutas y puntos
      _rutas = await _rutaController.obtenerRutas();
      _puntosRuta = await _puntoRutaController.obtenerPuntosRuta();

      if (_rutas.isNotEmpty) {
        _seleccionarRuta(_rutas.first);
      }
    } catch (e) {
      _mostrarSnackBar('Error al cargar datos: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _iniciarSimulacion() async {
    try {
      await _simulacionController.conectarWebSocket();

      _ubicacionesSubscription = _simulacionController.ubicacionesStream.listen(
        (ubicaciones) {
          setState(() {
            _ubicacionesBuses = ubicaciones;
            _actualizarMapa();
          });
        },
      );
    } catch (e) {
      print('Error iniciando simulación: $e');
    }
  }

  void _seleccionarRuta(Ruta ruta) {
    setState(() {
      _rutaSeleccionada = ruta;
      _actualizarMapa();
    });
  }

  // 🔹 ACTUALIZAR MAPA CON RUTAS REALES
  Future<void> _actualizarMapa() async {
    if (_rutaSeleccionada == null) return;

    // Filtrar puntos de la ruta seleccionada
    final puntosDeRuta =
        _puntosRuta
            .where((punto) => punto.RutaId == _rutaSeleccionada!.IdRuta)
            .toList()
          ..sort((a, b) => a.orden.compareTo(b.orden));

    // Limpiar marcadores y polylines
    _markers.clear();
    _polylines.clear();

    // 🔹 CREAR MARCADORES SOLO PARA PUNTOS IMPORTANTES
    _crearMarcadoresImportantes(puntosDeRuta);

    // 🔹 CREAR RUTA CON GOOGLE DIRECTIONS API
    if (puntosDeRuta.length >= 2) {
      await _crearRutaConDirectionsAPI(puntosDeRuta);
    }

    // 🔹 AGREGAR BUSES EN TIEMPO REAL
    _agregarBusesTiempoReal();

    // Mover cámara al primer punto si existe
    if (puntosDeRuta.isNotEmpty && _mapController != null) {
      final primerPunto = puntosDeRuta.first;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(primerPunto.latitud, primerPunto.longitud),
          13,
        ),
      );
    }
  }

  // 🔹 CREAR MARCADORES SOLO PARA PUNTOS IMPORTANTES
  void _crearMarcadoresImportantes(List<PuntoRuta> puntosDeRuta) {
    for (int i = 0; i < puntosDeRuta.length; i++) {
      final punto = puntosDeRuta[i];
      final latLng = LatLng(punto.latitud, punto.longitud);

      // 🔹 MOSTRAR SOLO PUNTOS IMPORTANTES
      if (_debeMostrarMarcador(i, puntosDeRuta.length, punto.tipoPunto)) {
        _markers.add(
          Marker(
            markerId: MarkerId('punto_${punto.IdPunto}'),
            position: latLng,
            infoWindow: InfoWindow(
              title: _obtenerTituloMarcador(
                i,
                puntosDeRuta.length,
                punto.tipoPunto,
              ),
              snippet: 'Orden: ${punto.orden}',
            ),
            icon: _obtenerIconoMarcador(
              i,
              puntosDeRuta.length,
              punto.tipoPunto,
            ),
          ),
        );
      }
    }
  }

  // 🔹 DECIDIR SI MOSTRAR UN MARCADOR
  bool _debeMostrarMarcador(int index, int totalPuntos, String tipoPunto) {
    // Siempre mostrar primer y último punto
    if (index == 0 || index == totalPuntos - 1) return true;

    // Mostrar puntos marcados como "medio"
    if (tipoPunto == 'medio') return true;

    // Mostrar algunos puntos intermedios si hay muchos (cada 10 puntos)
    if (totalPuntos > 15 && index % 10 == 0) return true;

    return false;
  }

  // 🔹 OBTENER TÍTULO DEL MARCADOR
  String _obtenerTituloMarcador(int index, int totalPuntos, String tipoPunto) {
    if (index == 0) return '🏁 Inicio';
    if (index == totalPuntos - 1) return '🎯 Fin';
    if (tipoPunto == 'medio') return '🔄 Punto Medio';
    return 'Punto ${index + 1}';
  }

  // 🔹 OBTENER ICONO DEL MARCADOR
  BitmapDescriptor _obtenerIconoMarcador(
    int index,
    int totalPuntos,
    String tipoPunto,
  ) {
    if (index == 0)
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    if (index == totalPuntos - 1)
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    if (tipoPunto == 'medio')
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  // 🔹 CREAR RUTA CON GOOGLE DIRECTIONS API
  Future<void> _crearRutaConDirectionsAPI(List<PuntoRuta> puntosDeRuta) async {
    try {
      final List<LatLng> puntosRutaCompleta = [];

      // Calcular rutas entre cada par de puntos consecutivos
      for (int i = 0; i < puntosDeRuta.length - 1; i++) {
        final origen = LatLng(
          puntosDeRuta[i].latitud,
          puntosDeRuta[i].longitud,
        );
        final destino = LatLng(
          puntosDeRuta[i + 1].latitud,
          puntosDeRuta[i + 1].longitud,
        );

        final url =
            "https://maps.googleapis.com/maps/api/directions/json?"
            "origin=${origen.latitude},${origen.longitude}&"
            "destination=${destino.latitude},${destino.longitude}&"
            "mode=driving&" // Seguir calles
            "key=$apiKey";

        final res = await http.get(Uri.parse(url));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == "OK" && data['routes'].isNotEmpty) {
            final steps = data['routes'][0]['overview_polyline']['points'];
            final segmentoRuta = _decodePolyline(steps);

            // Agregar segmento a la ruta completa
            if (i == 0) {
              puntosRutaCompleta.addAll(segmentoRuta);
            } else {
              // Evitar duplicar el último punto del segmento anterior
              puntosRutaCompleta.addAll(segmentoRuta.skip(1));
            }
          } else {
            // Si falla la API, usar línea recta entre estos puntos
            puntosRutaCompleta.addAll([origen, destino]);
          }
        } else {
          // Error HTTP, usar línea recta
          puntosRutaCompleta.addAll([origen, destino]);
        }
      }

      // Crear polyline con la ruta completa
      _polylines.add(
        Polyline(
          polylineId: PolylineId('ruta_${_rutaSeleccionada!.IdRuta}'),
          color: _obtenerColorRuta(_rutaSeleccionada!.color),
          width: 6,
          points: puntosRutaCompleta,
        ),
      );

      setState(() {});
    } catch (e) {
      print('❌ Error creando ruta con Directions API: $e');
      // En caso de error, crear polyline con líneas rectas
      _crearPolylineRecta(puntosDeRuta);
    }
  }

  // 🔹 CREAR POLYLINE CON LÍNEAS RECTAS (fallback)
  void _crearPolylineRecta(List<PuntoRuta> puntosDeRuta) {
    final puntosLatLng = puntosDeRuta
        .map((p) => LatLng(p.latitud, p.longitud))
        .toList();
    _polylines.add(
      Polyline(
        polylineId: PolylineId('ruta_${_rutaSeleccionada!.IdRuta}'),
        color: _obtenerColorRuta(_rutaSeleccionada!.color),
        width: 5,
        points: puntosLatLng,
      ),
    );
    setState(() {});
  }

  // 🔹 DECODIFICAR POLYLINE DE GOOGLE
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

  // 🔹 AGREGAR BUSES EN TIEMPO REAL
  void _agregarBusesTiempoReal() {
    _ubicacionesBuses.forEach((busId, ubicacion) {
      if (ubicacion.rutaId == _rutaSeleccionada!.IdRuta) {
        _markers.add(
          Marker(
            markerId: MarkerId('bus_$busId'),
            position: LatLng(ubicacion.latitud, ubicacion.longitud),
            infoWindow: InfoWindow(
              title: 'Bus ${ubicacion.placa}',
              snippet: 'Ruta ${_rutaSeleccionada!.nombre}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    });
  }

  Color _obtenerColorRuta(String? colorHex) {
    try {
      if (colorHex != null && colorHex.isNotEmpty) {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      }
    } catch (e) {
      print('Error parsing color: $e');
    }
    return Colors.blue; // Color por defecto
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
    );
  }

  void _mostrarDetallesRuta(Ruta ruta) {
    final puntosDeRuta =
        _puntosRuta.where((punto) => punto.RutaId == ruta.IdRuta).toList()
          ..sort((a, b) => a.orden.compareTo(b.orden));

    // Contar buses activos en esta ruta
    final busesActivos = _ubicacionesBuses.values
        .where((ubicacion) => ubicacion.rutaId == ruta.IdRuta)
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ruta.nombre),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ruta.descripcion != null)
                Text('Descripción: ${ruta.descripcion!}'),
              if (ruta.color != null) Text('Color: ${ruta.color!}'),
              Text(
                'Fecha: ${ruta.FechaRegistro.day}/${ruta.FechaRegistro.month}/${ruta.FechaRegistro.year}',
              ),
              Text(
                'Buses activos: $busesActivos',
                style: TextStyle(
                  color: busesActivos > 0 ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Puntos importantes (${puntosDeRuta.where((p) => _debeMostrarMarcador(p.orden - 1, puntosDeRuta.length, p.tipoPunto)).length}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...puntosDeRuta
                  .where(
                    (p) => _debeMostrarMarcador(
                      p.orden - 1,
                      puntosDeRuta.length,
                      p.tipoPunto,
                    ),
                  )
                  .map(
                    (punto) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _obtenerColorPunto(
                          punto.orden - 1,
                          puntosDeRuta.length,
                          punto.tipoPunto,
                        ),
                        child: Text(
                          punto.orden.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        _obtenerTituloMarcador(
                          punto.orden - 1,
                          puntosDeRuta.length,
                          punto.tipoPunto,
                        ),
                      ),
                      subtitle: Text(
                        'Lat: ${punto.latitud.toStringAsFixed(5)}, Lng: ${punto.longitud.toStringAsFixed(5)}',
                      ),
                      dense: true,
                    ),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Color _obtenerColorPunto(int index, int totalPuntos, String tipoPunto) {
    if (index == 0) return Colors.green;
    if (index == totalPuntos - 1) return Colors.red;
    if (tipoPunto == 'medio') return Colors.orange;
    return Colors.blue;
  }

  @override
  void dispose() {
    _ubicacionesSubscription?.cancel();
    _simulacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutas'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos),
          IconButton(
            icon: Icon(
              _simulacionController.estaConectado ? Icons.wifi : Icons.wifi_off,
              color: _simulacionController.estaConectado
                  ? Colors.green
                  : Colors.red,
            ),
            onPressed: () {
              _mostrarSnackBar(
                _simulacionController.estaConectado
                    ? 'Conectado al servidor de buses'
                    : 'Desconectado del servidor',
              );
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔹 Selector de rutas
                if (_rutas.isNotEmpty)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.grey[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seleccionar Ruta:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _rutas.length,
                            itemBuilder: (context, index) {
                              final ruta = _rutas[index];
                              final isSelected =
                                  _rutaSeleccionada?.IdRuta == ruta.IdRuta;
                              final puntosDeRuta = _puntosRuta
                                  .where((punto) => punto.RutaId == ruta.IdRuta)
                                  .length;
                              final busesActivos = _ubicacionesBuses.values
                                  .where(
                                    (ubicacion) =>
                                        ubicacion.rutaId == ruta.IdRuta,
                                  )
                                  .length;

                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    '${ruta.nombre} ($puntosDeRuta pts)',
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) _seleccionarRuta(ruta);
                                  },
                                  backgroundColor: busesActivos > 0
                                      ? Colors.green[50]
                                      : Colors.white,
                                  selectedColor: Colors.blue[100],
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.blue[900]
                                        : busesActivos > 0
                                        ? Colors.green[800]
                                        : Colors.grey[700],
                                    fontWeight: busesActivos > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // 🔹 Mapa
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(-15.47353, -70.12007),
                          zoom: 13,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          if (_rutaSeleccionada != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _actualizarMapa();
                            });
                          }
                        },
                        markers: _markers,
                        polylines: _polylines,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),

                      // 🔹 Información de la ruta seleccionada
                      if (_rutaSeleccionada != null)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _rutaSeleccionada!.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_rutaSeleccionada!.descripcion != null)
                                    Text(
                                      _rutaSeleccionada!.descripcion!,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  Text(
                                    '${_puntosRuta.where((p) => p.RutaId == _rutaSeleccionada!.IdRuta).length} puntos',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    '${_ubicacionesBuses.values.where((ubicacion) => ubicacion.rutaId == _rutaSeleccionada!.IdRuta).length} buses activos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _ubicacionesBuses.values.any(
                                            (ubicacion) =>
                                                ubicacion.rutaId ==
                                                _rutaSeleccionada!.IdRuta,
                                          )
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _rutaSeleccionada != null
          ? FloatingActionButton(
              onPressed: () => _mostrarDetallesRuta(_rutaSeleccionada!),
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.info_outline, color: Colors.white),
            )
          : null,
    );
  }
}
