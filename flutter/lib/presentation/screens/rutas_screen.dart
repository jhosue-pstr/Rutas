// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../data/models/rutas.dart';
// import '../../data/models/punto_ruta.dart';
// import '../../data/models/ubicacion_bus.dart';
// import '../../presentation/controllers/ruta_controller.dart';
// import '../../presentation/controllers/punto_ruta_controller.dart';
// import '../../presentation/controllers/simulacion_controller.dart';

// class RutasScreen extends StatefulWidget {
//   const RutasScreen({super.key});

//   @override
//   State<RutasScreen> createState() => _RutasScreenState();
// }

// class _RutasScreenState extends State<RutasScreen> {
//   final RutaController _rutaController = RutaController();
//   final PuntoRutaController _puntoRutaController = PuntoRutaController();
//   final SimulacionController _simulacionController = SimulacionController();

//   final String apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M";

//   List<Ruta> _rutas = [];
//   List<PuntoRuta> _puntosRuta = [];
//   Ruta? _rutaSeleccionada;
//   bool _cargando = true;
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   Map<String, UbicacionBus> _ubicacionesBuses = {};
//   StreamSubscription? _ubicacionesSubscription;
//   bool _mostrarTodasLasRutas = false;
//   bool _rutasDibujadas = false;

//   // Colores de la app
//   final Color _azulPrincipal = const Color(0xFF3F51B5);
//   final Color _verdeBrillante = const Color(0xFF8BC34A);
//   final Color _naranjaDinamico = const Color(0xFFFF9800);
//   final Color _azulCielo = const Color(0xFF2196F3);
//   final Color _grisNeutro = const Color(0xFFE0E0E0);
//   final Color _grisOscuro = const Color(0xFF424242);

//   @override
//   void initState() {
//     super.initState();
//     _cargarDatos();
//     _iniciarSimulacion();
//   }

//   Future<void> _cargarDatos() async {
//     try {
//       setState(() => _cargando = true);

//       _rutas = await _rutaController.obtenerRutas();
//       _puntosRuta = await _puntoRutaController.obtenerPuntosRuta();

//       if (_rutas.isNotEmpty) {
//         _seleccionarRuta(_rutas.first);
//       }
//     } catch (e) {
//       _mostrarSnackBar('Error al cargar datos: $e', esError: true);
//     } finally {
//       setState(() => _cargando = false);
//     }
//   }

//   Future<void> _iniciarSimulacion() async {
//     try {
//       await _simulacionController.conectarWebSocket();

//       _ubicacionesSubscription = _simulacionController.ubicacionesStream.listen(
//         (ubicaciones) {
//           _actualizarBuses(ubicaciones);
//         },
//       );
//     } catch (e) {
//       print('Error iniciando simulación: $e');
//     }
//   }

//   void _actualizarBuses(Map<String, UbicacionBus> nuevasUbicaciones) {
//     setState(() {
//       _ubicacionesBuses = nuevasUbicaciones;
//       _agregarBusesTiempoReal();
//     });
//   }

//   void _seleccionarRuta(Ruta ruta) {
//     setState(() {
//       _rutaSeleccionada = ruta;
//       _mostrarTodasLasRutas = false;
//       _rutasDibujadas = false;
//       _actualizarMapa();
//     });
//   }

//   void _cambiarModoVisualizacion() {
//     setState(() {
//       _mostrarTodasLasRutas = !_mostrarTodasLasRutas;
//       _rutasDibujadas = false;
//       _actualizarMapa();
//     });
//   }

//   Future<void> _actualizarMapa() async {
//     if (!_rutasDibujadas) {
//       _markers.clear();
//       _polylines.clear();

//       if (_mostrarTodasLasRutas) {
//         // 🔥 CORREGIDO: Mostrar todas las rutas
//         for (final ruta in _rutas) {
//           await _agregarRutaAlMapa(ruta);
//         }
//       } else if (_rutaSeleccionada != null) {
//         // 🔥 CORREGIDO: Mostrar SOLO la ruta seleccionada
//         await _agregarRutaAlMapa(_rutaSeleccionada!);
//       }

//       _rutasDibujadas = true;
//     }

//     _agregarBusesTiempoReal();
//     setState(() {});
//   }

//   Future<void> _agregarRutaAlMapa(Ruta ruta) async {
//     final puntosDeRuta =
//         _puntosRuta.where((punto) => punto.RutaId == ruta.IdRuta).toList()
//           ..sort((a, b) => a.orden.compareTo(b.orden));

//     if (puntosDeRuta.length < 2) return;

//     _crearMarcadoresImportantes(puntosDeRuta, ruta);
//     await _crearRutaConDirectionsAPI(puntosDeRuta, ruta);
//   }

//   void _crearMarcadoresImportantes(List<PuntoRuta> puntosDeRuta, Ruta ruta) {
//     for (int i = 0; i < puntosDeRuta.length; i++) {
//       final punto = puntosDeRuta[i];
//       final latLng = LatLng(punto.latitud, punto.longitud);

//       if (_debeMostrarMarcador(i, puntosDeRuta.length, punto.tipoPunto)) {
//         _markers.add(
//           Marker(
//             markerId: MarkerId('punto_${ruta.IdRuta}_${punto.IdPunto}'),
//             position: latLng,
//             infoWindow: InfoWindow(
//               title: _obtenerTituloMarcador(
//                 i,
//                 puntosDeRuta.length,
//                 punto.tipoPunto,
//               ),
//               snippet: 'Ruta: ${ruta.nombre}',
//             ),
//             icon: _obtenerIconoMarcador(
//               i,
//               puntosDeRuta.length,
//               punto.tipoPunto,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   bool _debeMostrarMarcador(int index, int totalPuntos, String tipoPunto) {
//     if (index == 0 || index == totalPuntos - 1) return true;
//     if (tipoPunto == 'medio') return true;
//     if (totalPuntos > 15 && index % 10 == 0) return true;
//     return false;
//   }

//   String _obtenerTituloMarcador(int index, int totalPuntos, String tipoPunto) {
//     if (index == 0) return '🏁 Inicio';
//     if (index == totalPuntos - 1) return '🎯 Fin';
//     if (tipoPunto == 'medio') return '🔄 Punto Medio';
//     return 'Punto ${index + 1}';
//   }

//   BitmapDescriptor _obtenerIconoMarcador(
//     int index,
//     int totalPuntos,
//     String tipoPunto,
//   ) {
//     if (index == 0)
//       return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//     if (index == totalPuntos - 1)
//       return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//     if (tipoPunto == 'medio')
//       return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
//     return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
//   }

//   Future<void> _crearRutaConDirectionsAPI(
//     List<PuntoRuta> puntosDeRuta,
//     Ruta ruta,
//   ) async {
//     try {
//       final List<LatLng> puntosRutaCompleta = [];

//       for (int i = 0; i < puntosDeRuta.length - 1; i++) {
//         final origen = LatLng(
//           puntosDeRuta[i].latitud,
//           puntosDeRuta[i].longitud,
//         );
//         final destino = LatLng(
//           puntosDeRuta[i + 1].latitud,
//           puntosDeRuta[i + 1].longitud,
//         );

//         final url =
//             "https://maps.googleapis.com/maps/api/directions/json?"
//             "origin=${origen.latitude},${origen.longitude}&"
//             "destination=${destino.latitude},${destino.longitude}&"
//             "mode=driving&"
//             "key=$apiKey";

//         final res = await http.get(Uri.parse(url));

//         if (res.statusCode == 200) {
//           final data = jsonDecode(res.body);
//           if (data['status'] == "OK" && data['routes'].isNotEmpty) {
//             final steps = data['routes'][0]['overview_polyline']['points'];
//             final segmentoRuta = _decodePolyline(steps);

//             if (i == 0) {
//               puntosRutaCompleta.addAll(segmentoRuta);
//             } else {
//               puntosRutaCompleta.addAll(segmentoRuta.skip(1));
//             }
//           } else {
//             puntosRutaCompleta.addAll([origen, destino]);
//           }
//         } else {
//           puntosRutaCompleta.addAll([origen, destino]);
//         }
//       }

//       _polylines.add(
//         Polyline(
//           polylineId: PolylineId('ruta_${ruta.IdRuta}'),
//           color: _obtenerColorRuta(ruta.color),
//           width: _mostrarTodasLasRutas ? 4 : 6,
//           points: puntosRutaCompleta,
//         ),
//       );
//     } catch (e) {
//       print('Error creando ruta con Directions API: $e');
//       _crearPolylineRecta(puntosDeRuta, ruta);
//     }
//   }

//   void _crearPolylineRecta(List<PuntoRuta> puntosDeRuta, Ruta ruta) {
//     final puntosLatLng = puntosDeRuta
//         .map((p) => LatLng(p.latitud, p.longitud))
//         .toList();
//     _polylines.add(
//       Polyline(
//         polylineId: PolylineId('ruta_${ruta.IdRuta}'),
//         color: _obtenerColorRuta(ruta.color),
//         width: _mostrarTodasLasRutas ? 3 : 5,
//         points: puntosLatLng,
//       ),
//     );
//   }

//   void _agregarBusesTiempoReal() {
//     _markers.removeWhere((marker) => marker.markerId.value.startsWith('bus_'));

//     _ubicacionesBuses.forEach((busId, ubicacion) {
//       final ruta = _rutas.firstWhere(
//         (r) => r.IdRuta == ubicacion.rutaId,
//         orElse: () => Ruta(
//           IdRuta: 0,
//           nombre: 'Desconocida',
//           FechaRegistro: DateTime.now(),
//         ),
//       );

//       _markers.add(
//         Marker(
//           markerId: MarkerId('bus_$busId'),
//           position: LatLng(ubicacion.latitud, ubicacion.longitud),
//           infoWindow: InfoWindow(
//             title: '🚌 Bus ${ubicacion.placa}',
//             snippet: 'Ruta ${ruta.nombre}',
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueOrange,
//           ),
//         ),
//       );
//     });
//   }

//   Color _obtenerColorRuta(String? colorHex) {
//     try {
//       if (colorHex != null && colorHex.isNotEmpty) {
//         return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
//       }
//     } catch (e) {
//       print('Error parsing color: $e');
//     }
//     return _azulPrincipal;
//   }

//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> poly = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;

//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;

//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;

//       poly.add(LatLng(lat / 1e5, lng / 1e5));
//     }
//     return poly;
//   }

//   void _mostrarSnackBar(String mensaje, {bool esError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               esError ? Icons.error : Icons.check_circle,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 8),
//             Expanded(child: Text(mensaje)),
//           ],
//         ),
//         backgroundColor: esError ? Colors.red : _verdeBrillante,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _mostrarDetallesRuta(Ruta ruta) {
//     final puntosDeRuta =
//         _puntosRuta.where((punto) => punto.RutaId == ruta.IdRuta).toList()
//           ..sort((a, b) => a.orden.compareTo(b.orden));

//     final busesActivos = _ubicacionesBuses.values
//         .where((ubicacion) => ubicacion.rutaId == ruta.IdRuta)
//         .length;

//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: _azulPrincipal.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(Icons.route, color: _azulPrincipal),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       ruta.nombre,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: _grisOscuro,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               if (ruta.descripcion != null)
//                 Text(
//                   ruta.descripcion!,
//                   style: TextStyle(color: _grisOscuro.withOpacity(0.7)),
//                 ),

//               const SizedBox(height: 12),

//               Row(
//                 children: [
//                   _buildEstadistica(
//                     icon: Icons.location_pin,
//                     value: puntosDeRuta.length.toString(),
//                     label: 'Puntos',
//                     color: _azulCielo,
//                   ),
//                   const SizedBox(width: 16),
//                   _buildEstadistica(
//                     icon: Icons.directions_bus,
//                     value: busesActivos.toString(),
//                     label: 'Buses Activos',
//                     color: busesActivos > 0 ? _verdeBrillante : Colors.grey,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               Text(
//                 'Puntos Importantes:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: _grisOscuro,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               Container(
//                 height: 200,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: puntosDeRuta.length,
//                   itemBuilder: (context, index) {
//                     final punto = puntosDeRuta[index];
//                     if (!_debeMostrarMarcador(
//                       index,
//                       puntosDeRuta.length,
//                       punto.tipoPunto,
//                     )) {
//                       return const SizedBox.shrink();
//                     }

//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: _obtenerColorPunto(
//                           index,
//                           puntosDeRuta.length,
//                           punto.tipoPunto,
//                         ),
//                         child: Text(
//                           (index + 1).toString(),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         _obtenerTituloMarcador(
//                           index,
//                           puntosDeRuta.length,
//                           punto.tipoPunto,
//                         ),
//                         style: TextStyle(fontSize: 14, color: _grisOscuro),
//                       ),
//                       subtitle: Text(
//                         'Lat: ${punto.latitud.toStringAsFixed(5)}\nLng: ${punto.longitud.toStringAsFixed(5)}',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: _grisOscuro.withOpacity(0.6),
//                         ),
//                       ),
//                       dense: true,
//                       contentPadding: EdgeInsets.zero,
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(height: 16),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _azulPrincipal,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: const Text('Cerrar'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEstadistica({
//     required IconData icon,
//     required String value,
//     required String label,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 20),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 10,
//                 color: _grisOscuro.withOpacity(0.6),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _obtenerColorPunto(int index, int totalPuntos, String tipoPunto) {
//     if (index == 0) return _verdeBrillante;
//     if (index == totalPuntos - 1) return Colors.red;
//     if (tipoPunto == 'medio') return _naranjaDinamico;
//     return _azulCielo;
//   }

//   @override
//   void dispose() {
//     _ubicacionesSubscription?.cancel();
//     _simulacionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: _azulPrincipal,
//         foregroundColor: Colors.white,
//         title: const Text('Rutas de Buses'),
//         automaticallyImplyLeading: true,
//         actions: [
//           IconButton(
//             icon: Icon(
//               _mostrarTodasLasRutas ? Icons.visibility_off : Icons.visibility,
//             ),
//             onPressed: _cambiarModoVisualizacion,
//             tooltip: _mostrarTodasLasRutas
//                 ? 'Mostrar una ruta'
//                 : 'Ver todas las rutas',
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _cargarDatos,
//             tooltip: 'Actualizar rutas',
//           ),
//         ],
//       ),
//       body: _cargando
//           ? _buildPantallaCarga() // 🔥 PANTALLA DE CARGA MEJORADA
//           : Column(
//               children: [
//                 if (_rutas.isNotEmpty && !_mostrarTodasLasRutas)
//                   _buildSelectorRutas(),

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
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             _actualizarMapa();
//                           });
//                         },
//                         markers: _markers,
//                         polylines: _polylines,
//                         myLocationEnabled: true,
//                         myLocationButtonEnabled: false,
//                       ),

//                       if (_rutaSeleccionada != null && !_mostrarTodasLasRutas)
//                         Positioned(
//                           top: 16,
//                           left: 16,
//                           right: 16,
//                           child: _buildTarjetaInfoRuta(),
//                         ),

//                       Positioned(
//                         bottom: 100,
//                         right: 16,
//                         child: FloatingActionButton(
//                           heroTag: "btn_ubicacion",
//                           onPressed: () {
//                             _mapController?.animateCamera(
//                               CameraUpdate.newLatLngZoom(
//                                 const LatLng(-15.47353, -70.12007),
//                                 13,
//                               ),
//                             );
//                           },
//                           backgroundColor: _azulPrincipal,
//                           foregroundColor: Colors.white,
//                           mini: true,
//                           child: const Icon(Icons.my_location),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButton: _rutaSeleccionada != null && !_mostrarTodasLasRutas
//           ? FloatingActionButton(
//               onPressed: () => _mostrarDetallesRuta(_rutaSeleccionada!),
//               backgroundColor: _naranjaDinamico,
//               foregroundColor: Colors.white,
//               child: const Icon(Icons.info_outline),
//             )
//           : null,
//     );
//   }

//   // 🔥 PANTALLA DE CARGA MEJORADA Y ELEGANTE
//   Widget _buildPantallaCarga() {
//     return Container(
//       color: Colors.white,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Animación de carga personalizada
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               // Círculo de fondo animado
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: _azulPrincipal.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//               ),

//               // Ícono animado
//               Column(
//                 children: [
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 1000),
//                     curve: Curves.easeInOut,
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: _azulPrincipal,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: _azulPrincipal.withOpacity(0.3),
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.directions_bus,
//                       color: Colors.white,
//                       size: 40,
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Texto de carga con animación de puntos
//                   _buildTextoAnimado(),

//                   const SizedBox(height: 30),

//                   // Barra de progreso
//                   SizedBox(
//                     width: 200,
//                     child: LinearProgressIndicator(
//                       backgroundColor: _grisNeutro,
//                       valueColor: AlwaysStoppedAnimation<Color>(_azulPrincipal),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Texto informativo
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 40),
//                     child: Text(
//                       'Cargando rutas y ubicaciones en tiempo real...',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: _grisOscuro.withOpacity(0.7),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // 🔥 TEXTO CON ANIMACIÓN DE PUNTOS
//   Widget _buildTextoAnimado() {
//     return TweenAnimationBuilder<String>(
//       tween: Tween<String>(begin: 'Cargando rutas', end: 'Cargando rutas...'),
//       duration: const Duration(milliseconds: 1500),
//       builder: (context, value, child) {
//         return Text(
//           value,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: _grisOscuro,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSelectorRutas() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Selecciona una ruta:',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: _grisOscuro,
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 50,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _rutas.length,
//               itemBuilder: (context, index) {
//                 final ruta = _rutas[index];
//                 final isSelected = _rutaSeleccionada?.IdRuta == ruta.IdRuta;
//                 final busesActivos = _ubicacionesBuses.values
//                     .where((ubicacion) => ubicacion.rutaId == ruta.IdRuta)
//                     .length;

//                 return Container(
//                   margin: const EdgeInsets.only(right: 8),
//                   child: ChoiceChip(
//                     label: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(ruta.nombre),
//                         if (busesActivos > 0) ...[
//                           const SizedBox(width: 4),
//                           Icon(
//                             Icons.directions_bus,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                           Text(
//                             '$busesActivos',
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ],
//                       ],
//                     ),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       if (selected) _seleccionarRuta(ruta);
//                     },
//                     backgroundColor: busesActivos > 0
//                         ? _verdeBrillante.withOpacity(0.2)
//                         : _grisNeutro,
//                     selectedColor: _azulPrincipal,
//                     labelStyle: TextStyle(
//                       color: isSelected
//                           ? Colors.white
//                           : busesActivos > 0
//                           ? _verdeBrillante
//                           : _grisOscuro,
//                       fontWeight: busesActivos > 0
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTarjetaInfoRuta() {
//     if (_rutaSeleccionada == null) return const SizedBox.shrink();

//     final puntosDeRuta = _puntosRuta
//         .where((punto) => punto.RutaId == _rutaSeleccionada!.IdRuta)
//         .length;

//     final busesActivos = _ubicacionesBuses.values
//         .where((ubicacion) => ubicacion.rutaId == _rutaSeleccionada!.IdRuta)
//         .length;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: _azulPrincipal.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Icon(Icons.route, size: 20, color: _azulPrincipal),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     _rutaSeleccionada!.nombre,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: _grisOscuro,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 _buildMiniEstadistica(
//                   icon: Icons.location_pin,
//                   value: puntosDeRuta.toString(),
//                   color: _azulCielo,
//                 ),
//                 const SizedBox(width: 12),
//                 _buildMiniEstadistica(
//                   icon: Icons.directions_bus,
//                   value: busesActivos.toString(),
//                   color: busesActivos > 0 ? _verdeBrillante : Colors.grey,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMiniEstadistica({
//     required IconData icon,
//     required String value,
//     required Color color,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: color),
//         const SizedBox(width: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }
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

class RutasScreen extends StatefulWidget {
  const RutasScreen({super.key});

  @override
  State<RutasScreen> createState() => _RutasScreenState();
}

class _RutasScreenState extends State<RutasScreen> {
  final RutaController _rutaController = RutaController();
  final PuntoRutaController _puntoRutaController = PuntoRutaController();
  final SimulacionController _simulacionController = SimulacionController();

  final String apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M";

  List<Ruta> _rutas = [];
  List<PuntoRuta> _puntosRuta = [];
  Ruta? _rutaSeleccionada;
  bool _cargando = true;
  bool _cambiandoRuta = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Map<String, UbicacionBus> _ubicacionesBuses = {};
  StreamSubscription? _ubicacionesSubscription;
  bool _mostrarTodasLasRutas = false;
  bool _rutasDibujadas = false;

  // Colores de la app
  final Color _azulPrincipal = const Color(0xFF3F51B5);
  final Color _verdeBrillante = const Color(0xFF8BC34A);
  final Color _naranjaDinamico = const Color(0xFFFF9800);
  final Color _azulCielo = const Color(0xFF2196F3);
  final Color _grisNeutro = const Color(0xFFE0E0E0);
  final Color _grisOscuro = const Color(0xFF424242);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _iniciarSimulacion();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() => _cargando = true);

      _rutas = await _rutaController.obtenerRutas();
      _puntosRuta = await _puntoRutaController.obtenerPuntosRuta();

      if (_rutas.isNotEmpty) {
        _seleccionarRuta(_rutas.first);
      }
    } catch (e) {
      _mostrarSnackBar('Error al cargar datos: $e', esError: true);
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _iniciarSimulacion() async {
    try {
      await _simulacionController.conectarWebSocket();

      _ubicacionesSubscription = _simulacionController.ubicacionesStream.listen(
        (ubicaciones) {
          _actualizarBuses(ubicaciones);
        },
      );
    } catch (e) {
      print('Error iniciando simulación: $e');
    }
  }

  void _actualizarBuses(Map<String, UbicacionBus> nuevasUbicaciones) {
    setState(() {
      _ubicacionesBuses = nuevasUbicaciones;
      _agregarBusesTiempoReal();
    });
  }

  void _seleccionarRuta(Ruta ruta) async {
    setState(() {
      _cambiandoRuta = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _rutaSeleccionada = ruta;
      _mostrarTodasLasRutas = false;
      _rutasDibujadas = false;
      _cambiandoRuta = false;
      _actualizarMapa();
    });
  }

  void _cambiarModoVisualizacion() {
    setState(() {
      _mostrarTodasLasRutas = !_mostrarTodasLasRutas;
      _rutasDibujadas = false;
      _actualizarMapa();
    });
  }

  Future<void> _actualizarMapa() async {
    if (!_rutasDibujadas) {
      _markers.clear();
      _polylines.clear();

      if (_mostrarTodasLasRutas) {
        for (final ruta in _rutas) {
          await _agregarRutaAlMapa(ruta);
        }
      } else if (_rutaSeleccionada != null) {
        await _agregarRutaAlMapa(_rutaSeleccionada!);
      }

      _rutasDibujadas = true;
    }

    _agregarBusesTiempoReal();
    setState(() {});
  }

  Future<void> _agregarRutaAlMapa(Ruta ruta) async {
    final puntosDeRuta =
        _puntosRuta.where((punto) => punto.RutaId == ruta.IdRuta).toList()
          ..sort((a, b) => a.orden.compareTo(b.orden));

    if (puntosDeRuta.length < 2) return;

    _crearMarcadoresImportantes(puntosDeRuta, ruta);
    await _crearRutaConDirectionsAPI(puntosDeRuta, ruta);
  }

  void _crearMarcadoresImportantes(List<PuntoRuta> puntosDeRuta, Ruta ruta) {
    for (int i = 0; i < puntosDeRuta.length; i++) {
      final punto = puntosDeRuta[i];
      final latLng = LatLng(punto.latitud, punto.longitud);

      if (_debeMostrarMarcador(i, puntosDeRuta.length, punto.tipoPunto)) {
        _markers.add(
          Marker(
            markerId: MarkerId('punto_${ruta.IdRuta}_${punto.IdPunto}'),
            position: latLng,
            infoWindow: InfoWindow(
              title: _obtenerTituloMarcador(
                i,
                puntosDeRuta.length,
                punto.tipoPunto,
              ),
              snippet: 'Ruta: ${ruta.nombre}',
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

  bool _debeMostrarMarcador(int index, int totalPuntos, String tipoPunto) {
    if (index == 0 || index == totalPuntos - 1) return true;
    if (tipoPunto == 'medio') return true;
    if (totalPuntos > 15 && index % 10 == 0) return true;
    return false;
  }

  String _obtenerTituloMarcador(int index, int totalPuntos, String tipoPunto) {
    if (index == 0) return '🏁 Inicio';
    if (index == totalPuntos - 1) return '🎯 Fin';
    if (tipoPunto == 'medio') return '🔄 Punto Medio';
    return 'Punto ${index + 1}';
  }

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

  Future<void> _crearRutaConDirectionsAPI(
    List<PuntoRuta> puntosDeRuta,
    Ruta ruta,
  ) async {
    try {
      final List<LatLng> puntosRutaCompleta = [];

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
            "mode=driving&"
            "key=$apiKey";

        final res = await http.get(Uri.parse(url));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == "OK" && data['routes'].isNotEmpty) {
            final steps = data['routes'][0]['overview_polyline']['points'];
            final segmentoRuta = _decodePolyline(steps);

            if (i == 0) {
              puntosRutaCompleta.addAll(segmentoRuta);
            } else {
              puntosRutaCompleta.addAll(segmentoRuta.skip(1));
            }
          } else {
            puntosRutaCompleta.addAll([origen, destino]);
          }
        } else {
          puntosRutaCompleta.addAll([origen, destino]);
        }
      }

      _polylines.add(
        Polyline(
          polylineId: PolylineId('ruta_${ruta.IdRuta}'),
          color: _obtenerColorRuta(ruta.color),
          width: _mostrarTodasLasRutas ? 4 : 6,
          points: puntosRutaCompleta,
        ),
      );
    } catch (e) {
      print('Error creando ruta con Directions API: $e');
      _crearPolylineRecta(puntosDeRuta, ruta);
    }
  }

  void _crearPolylineRecta(List<PuntoRuta> puntosDeRuta, Ruta ruta) {
    final puntosLatLng = puntosDeRuta
        .map((p) => LatLng(p.latitud, p.longitud))
        .toList();
    _polylines.add(
      Polyline(
        polylineId: PolylineId('ruta_${ruta.IdRuta}'),
        color: _obtenerColorRuta(ruta.color),
        width: _mostrarTodasLasRutas ? 3 : 5,
        points: puntosLatLng,
      ),
    );
  }

  void _agregarBusesTiempoReal() {
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('bus_'));

    final busesDeRutaSeleccionada = _ubicacionesBuses.entries.where((entry) {
      final ubicacion = entry.value;

      if (_mostrarTodasLasRutas) {
        return true;
      } else if (_rutaSeleccionada != null) {
        return ubicacion.rutaId == _rutaSeleccionada!.IdRuta;
      }
      return false;
    });

    busesDeRutaSeleccionada.forEach((entry) {
      final busId = entry.key;
      final ubicacion = entry.value;

      final ruta = _rutas.firstWhere(
        (r) => r.IdRuta == ubicacion.rutaId,
        orElse: () => Ruta(
          IdRuta: 0,
          nombre: 'Desconocida',
          FechaRegistro: DateTime.now(),
        ),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('bus_$busId'),
          position: LatLng(ubicacion.latitud, ubicacion.longitud),
          infoWindow: InfoWindow(
            title: '🚌 Bus ${ubicacion.placa}',
            snippet: 'Ruta ${ruta.nombre}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
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
    return _azulPrincipal;
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

  void _mostrarSnackBar(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              esError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: esError ? Colors.red : _verdeBrillante,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarDetallesRuta(Ruta ruta) {
    final puntosDeRuta =
        _puntosRuta.where((punto) => punto.RutaId == ruta.IdRuta).toList()
          ..sort((a, b) => a.orden.compareTo(b.orden));

    final busesActivos = _ubicacionesBuses.values
        .where((ubicacion) => ubicacion.rutaId == ruta.IdRuta)
        .length;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _azulPrincipal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.route, color: _azulPrincipal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ruta.nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _grisOscuro,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (ruta.descripcion != null)
                Text(
                  ruta.descripcion!,
                  style: TextStyle(color: _grisOscuro.withOpacity(0.7)),
                ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildEstadistica(
                    icon: Icons.location_pin,
                    value: puntosDeRuta.length.toString(),
                    label: 'Puntos',
                    color: _azulCielo,
                  ),
                  const SizedBox(width: 16),
                  _buildEstadistica(
                    icon: Icons.directions_bus,
                    value: busesActivos.toString(),
                    label: 'Buses Activos',
                    color: busesActivos > 0 ? _verdeBrillante : Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                'Puntos Importantes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _grisOscuro,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: puntosDeRuta.length,
                  itemBuilder: (context, index) {
                    final punto = puntosDeRuta[index];
                    if (!_debeMostrarMarcador(
                      index,
                      puntosDeRuta.length,
                      punto.tipoPunto,
                    )) {
                      return const SizedBox.shrink();
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _obtenerColorPunto(
                          index,
                          puntosDeRuta.length,
                          punto.tipoPunto,
                        ),
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        _obtenerTituloMarcador(
                          index,
                          puntosDeRuta.length,
                          punto.tipoPunto,
                        ),
                        style: TextStyle(fontSize: 14, color: _grisOscuro),
                      ),
                      subtitle: Text(
                        'Lat: ${punto.latitud.toStringAsFixed(5)}\nLng: ${punto.longitud.toStringAsFixed(5)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: _grisOscuro.withOpacity(0.6),
                        ),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _azulPrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadistica({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: _grisOscuro.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _obtenerColorPunto(int index, int totalPuntos, String tipoPunto) {
    if (index == 0) return _verdeBrillante;
    if (index == totalPuntos - 1) return Colors.red;
    if (tipoPunto == 'medio') return _naranjaDinamico;
    return _azulCielo;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _azulPrincipal,
        foregroundColor: Colors.white,
        title: const Text('Rutas de Buses'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(
              _mostrarTodasLasRutas ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: _cambiarModoVisualizacion,
            tooltip: _mostrarTodasLasRutas
                ? 'Mostrar una ruta'
                : 'Ver todas las rutas',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar rutas',
          ),
        ],
      ),
      body: _cargando || _cambiandoRuta
          ? _buildPantallaCarga()
          : Column(
              children: [
                if (_rutas.isNotEmpty && !_mostrarTodasLasRutas)
                  _buildSelectorRutas(),

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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _actualizarMapa();
                          });
                        },
                        markers: _markers,
                        polylines: _polylines,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      ),

                      if (_rutaSeleccionada != null && !_mostrarTodasLasRutas)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: _buildTarjetaInfoRuta(),
                        ),

                      Positioned(
                        bottom: 100,
                        right: 16,
                        child: FloatingActionButton(
                          heroTag: "btn_ubicacion",
                          onPressed: () {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                const LatLng(-15.47353, -70.12007),
                                13,
                              ),
                            );
                          },
                          backgroundColor: _azulPrincipal,
                          foregroundColor: Colors.white,
                          mini: true,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _rutaSeleccionada != null && !_mostrarTodasLasRutas
          ? FloatingActionButton(
              onPressed: () => _mostrarDetallesRuta(_rutaSeleccionada!),
              backgroundColor: _naranjaDinamico,
              foregroundColor: Colors.white,
              child: const Icon(Icons.info_outline),
            )
          : null,
    );
  }

  // 🔥 PANTALLA DE CARGA SIMPLIFICADA - SIN ANIMACIONES PROBLEMÁTICAS
  Widget _buildPantallaCarga() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Contenedor principal
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _azulPrincipal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono de bus
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _azulPrincipal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _azulPrincipal.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Texto simple sin animación
          Text(
            _cambiandoRuta ? 'Cambiando ruta...' : 'Cargando rutas...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _grisOscuro,
            ),
          ),

          const SizedBox(height: 30),

          // Barra de progreso
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: _grisNeutro,
              valueColor: AlwaysStoppedAnimation<Color>(_azulPrincipal),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 20),

          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _cambiandoRuta
                  ? 'Cargando la ruta seleccionada...'
                  : 'Obteniendo rutas y ubicaciones en tiempo real',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _grisOscuro.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorRutas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona una ruta:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _grisOscuro,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _rutas.length,
              itemBuilder: (context, index) {
                final ruta = _rutas[index];
                final isSelected = _rutaSeleccionada?.IdRuta == ruta.IdRuta;
                final busesActivos = _ubicacionesBuses.values
                    .where((ubicacion) => ubicacion.rutaId == ruta.IdRuta)
                    .length;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(ruta.nombre),
                        if (busesActivos > 0) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.directions_bus,
                            size: 16,
                            color: Colors.white,
                          ),
                          Text(
                            '$busesActivos',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _seleccionarRuta(ruta);
                    },
                    backgroundColor: busesActivos > 0
                        ? _verdeBrillante.withOpacity(0.2)
                        : _grisNeutro,
                    selectedColor: _azulPrincipal,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : busesActivos > 0
                          ? _verdeBrillante
                          : _grisOscuro,
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
    );
  }

  Widget _buildTarjetaInfoRuta() {
    if (_rutaSeleccionada == null) return const SizedBox.shrink();

    final puntosDeRuta = _puntosRuta
        .where((punto) => punto.RutaId == _rutaSeleccionada!.IdRuta)
        .length;

    final busesActivos = _ubicacionesBuses.values
        .where((ubicacion) => ubicacion.rutaId == _rutaSeleccionada!.IdRuta)
        .length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _azulPrincipal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.route, size: 20, color: _azulPrincipal),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _rutaSeleccionada!.nombre,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _grisOscuro,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMiniEstadistica(
                  icon: Icons.location_pin,
                  value: puntosDeRuta.toString(),
                  color: _azulCielo,
                ),
                const SizedBox(width: 12),
                _buildMiniEstadistica(
                  icon: Icons.directions_bus,
                  value: busesActivos.toString(),
                  color: busesActivos > 0 ? _verdeBrillante : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniEstadistica({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
