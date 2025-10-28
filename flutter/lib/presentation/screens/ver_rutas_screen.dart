// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../../data/models/rutas.dart';
// import '../../data/models/punto_ruta.dart';
// import '../../presentation/controllers/ruta_controller.dart';
// import '../../presentation/controllers/punto_ruta_controller.dart';

// class VerRutasScreen extends StatefulWidget {
//   const VerRutasScreen({super.key});

//   @override
//   State<VerRutasScreen> createState() => _VerRutasScreenState();
// }

// class _VerRutasScreenState extends State<VerRutasScreen> {
//   final RutaController _rutaController = RutaController();
//   final PuntoRutaController _puntoRutaController = PuntoRutaController();

//   List<Ruta> _rutas = [];
//   List<PuntoRuta> _puntosRuta = [];
//   Ruta? _rutaSeleccionada;
//   bool _cargando = true;
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};

//   @override
//   void initState() {
//     super.initState();
//     _cargarDatos();
//   }

//   Future<void> _cargarDatos() async {
//     try {
//       setState(() => _cargando = true);

//       // Cargar rutas y puntos
//       _rutas = await _rutaController.obtenerRutas();
//       _puntosRuta = await _puntoRutaController.obtenerPuntosRuta();

//       if (_rutas.isNotEmpty) {
//         _seleccionarRuta(_rutas.first);
//       }
//     } catch (e) {
//       _mostrarSnackBar('Error al cargar datos: $e');
//     } finally {
//       setState(() => _cargando = false);
//     }
//   }

//   void _seleccionarRuta(Ruta ruta) {
//     setState(() {
//       _rutaSeleccionada = ruta;
//       _actualizarMapa();
//     });
//   }

//   void _actualizarMapa() {
//     if (_rutaSeleccionada == null) return;

//     // Filtrar puntos de la ruta seleccionada
//     final puntosDeRuta =
//         _puntosRuta
//             .where((punto) => punto.RutaId == _rutaSeleccionada!.IdRuta)
//             .toList()
//           ..sort((a, b) => a.orden.compareTo(b.orden));

//     // Limpiar marcadores y polylines
//     _markers.clear();
//     _polylines.clear();

//     // Crear marcadores
//     for (int i = 0; i < puntosDeRuta.length; i++) {
//       final punto = puntosDeRuta[i];
//       final latLng = LatLng(punto.latitud, punto.longitud);

//       _markers.add(
//         Marker(
//           markerId: MarkerId('punto_${punto.IdPunto}'),
//           position: latLng,
//           infoWindow: InfoWindow(
//             title: 'Punto ${i + 1}',
//             snippet: 'Orden: ${punto.orden}',
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             i == 0
//                 ? BitmapDescriptor
//                       .hueGreen // Primer punto verde
//                 : i == puntosDeRuta.length - 1
//                 ? BitmapDescriptor
//                       .hueRed // Último punto rojo
//                 : BitmapDescriptor.hueBlue, // Puntos intermedios azules
//           ),
//         ),
//       );
//     }

//     // Crear polyline si hay suficientes puntos
//     if (puntosDeRuta.length >= 2) {
//       final puntosLatLng = puntosDeRuta
//           .map((punto) => LatLng(punto.latitud, punto.longitud))
//           .toList();

//       _polylines.add(
//         Polyline(
//           polylineId: PolylineId('ruta_${_rutaSeleccionada!.IdRuta}'),
//           color: _obtenerColorRuta(_rutaSeleccionada!.color),
//           width: 5,
//           points: puntosLatLng,
//         ),
//       );
//     }

//     // Mover cámara al primer punto si existe
//     if (puntosDeRuta.isNotEmpty && _mapController != null) {
//       final primerPunto = puntosDeRuta.first;
//       _mapController!.animateCamera(
//         CameraUpdate.newLatLngZoom(
//           LatLng(primerPunto.latitud, primerPunto.longitud),
//           13,
//         ),
//       );
//     }
//   }

//   Color _obtenerColorRuta(String? colorHex) {
//     try {
//       if (colorHex != null && colorHex.isNotEmpty) {
//         return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
//       }
//     } catch (e) {
//       print('Error parsing color: $e');
//     }
//     return Colors.blue; // Color por defecto
//   }

//   void _mostrarSnackBar(String mensaje) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
//     );
//   }

//   void _mostrarDetallesRuta(Ruta ruta) {
//     final puntosDeRuta =
//         _puntosRuta.where((punto) => punto.RutaId == ruta.IdRuta).toList()
//           ..sort((a, b) => a.orden.compareTo(b.orden));

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(ruta.nombre),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (ruta.descripcion != null)
//                 Text('Descripción: ${ruta.descripcion!}'),
//               if (ruta.color != null) Text('Color: ${ruta.color!}'),
//               Text(
//                 'Fecha: ${ruta.FechaRegistro.day}/${ruta.FechaRegistro.month}/${ruta.FechaRegistro.year}',
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Puntos de la ruta (${puntosDeRuta.length}):',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               ...puntosDeRuta.map(
//                 (punto) => ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.blue,
//                     child: Text(
//                       punto.orden.toString(),
//                       style: const TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                   ),
//                   title: Text('Lat: ${punto.latitud.toStringAsFixed(5)}'),
//                   subtitle: Text('Lng: ${punto.longitud.toStringAsFixed(5)}'),
//                   dense: true,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cerrar'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mis Rutas'),
//         backgroundColor: Colors.indigo,
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos),
//         ],
//       ),
//       body: _cargando
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 // 🔹 Selector de rutas
//                 if (_rutas.isNotEmpty)
//                   Container(
//                     height: 70,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     color: Colors.grey[50],
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Seleccionar Ruta:',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         Expanded(
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: _rutas.length,
//                             itemBuilder: (context, index) {
//                               final ruta = _rutas[index];
//                               final isSelected =
//                                   _rutaSeleccionada?.IdRuta == ruta.IdRuta;
//                               final puntosDeRuta = _puntosRuta
//                                   .where((punto) => punto.RutaId == ruta.IdRuta)
//                                   .length;

//                               return Container(
//                                 margin: const EdgeInsets.only(right: 8),
//                                 child: ChoiceChip(
//                                   label: Text(
//                                     '${ruta.nombre} ($puntosDeRuta pts)',
//                                   ),
//                                   selected: isSelected,
//                                   onSelected: (selected) {
//                                     if (selected) _seleccionarRuta(ruta);
//                                   },
//                                   backgroundColor: Colors.white,
//                                   selectedColor: Colors.blue[100],
//                                   labelStyle: TextStyle(
//                                     color: isSelected
//                                         ? Colors.blue[900]
//                                         : Colors.grey[700],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // 🔹 Mapa
//                 Expanded(
//                   child: Stack(
//                     children: [
//                       GoogleMap(
//                         initialCameraPosition: const CameraPosition(
//                           target: LatLng(-15.47353, -70.12007),
//                           zoom: 13,
//                         ),
//                         onMapCreated: (controller) {
//                           _mapController = controller;
//                           if (_rutaSeleccionada != null) {
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               _actualizarMapa();
//                             });
//                           }
//                         },
//                         markers: _markers,
//                         polylines: _polylines,
//                         myLocationEnabled: true,
//                         myLocationButtonEnabled: true,
//                       ),

//                       // 🔹 Información de la ruta seleccionada
//                       if (_rutaSeleccionada != null)
//                         Positioned(
//                           top: 10,
//                           left: 10,
//                           child: Card(
//                             child: Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     _rutaSeleccionada!.nombre,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   if (_rutaSeleccionada!.descripcion != null)
//                                     Text(
//                                       _rutaSeleccionada!.descripcion!,
//                                       style: TextStyle(color: Colors.grey[600]),
//                                     ),
//                                   Text(
//                                     '${_puntosRuta.where((p) => p.RutaId == _rutaSeleccionada!.IdRuta).length} puntos',
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.blue,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButton: _rutaSeleccionada != null
//           ? FloatingActionButton(
//               onPressed: () => _mostrarDetallesRuta(_rutaSeleccionada!),
//               backgroundColor: Colors.indigo,
//               child: const Icon(Icons.info_outline, color: Colors.white),
//             )
//           : null,
//     );
//   }
// }

// screens/ver_rutas_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  void _actualizarMapa() {
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

    // Crear marcadores de puntos de ruta
    for (int i = 0; i < puntosDeRuta.length; i++) {
      final punto = puntosDeRuta[i];
      final latLng = LatLng(punto.latitud, punto.longitud);

      _markers.add(
        Marker(
          markerId: MarkerId('punto_${punto.IdPunto}'),
          position: latLng,
          infoWindow: InfoWindow(
            title: 'Punto ${i + 1}',
            snippet: 'Orden: ${punto.orden}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0
                ? BitmapDescriptor
                      .hueGreen // Primer punto verde
                : i == puntosDeRuta.length - 1
                ? BitmapDescriptor
                      .hueRed // Último punto rojo
                : BitmapDescriptor.hueBlue, // Puntos intermedios azules
          ),
        ),
      );
    }

    // Crear marcadores de buses en tiempo real
    _ubicacionesBuses.forEach((busId, ubicacion) {
      if (ubicacion.rutaId == _rutaSeleccionada!.IdRuta) {
        _markers.add(
          Marker(
            markerId: MarkerId('bus_$busId'),
            position: LatLng(ubicacion.latitud, ubicacion.longitud),
            infoWindow: InfoWindow(
              title: 'Bus ${ubicacion.placa}',
              snippet: 'En movimiento',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    });

    // Crear polyline si hay suficientes puntos
    if (puntosDeRuta.length >= 2) {
      final puntosLatLng = puntosDeRuta
          .map((punto) => LatLng(punto.latitud, punto.longitud))
          .toList();

      _polylines.add(
        Polyline(
          polylineId: PolylineId('ruta_${_rutaSeleccionada!.IdRuta}'),
          color: _obtenerColorRuta(_rutaSeleccionada!.color),
          width: 5,
          points: puntosLatLng,
        ),
      );
    }

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
                'Puntos de la ruta (${puntosDeRuta.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...puntosDeRuta.map(
                (punto) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      punto.orden.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text('Lat: ${punto.latitud.toStringAsFixed(5)}'),
                  subtitle: Text('Lng: ${punto.longitud.toStringAsFixed(5)}'),
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
