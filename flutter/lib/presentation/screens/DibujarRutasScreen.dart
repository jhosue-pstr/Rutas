// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../data/models/rutas.dart';
// import '../../data/models/punto_ruta.dart';
// import '../../presentation/controllers/ruta_controller.dart';
// import '../../presentation/controllers/punto_ruta_controller.dart';

// class DibujarRutasScreen extends StatefulWidget {
//   const DibujarRutasScreen({super.key});

//   @override
//   State<DibujarRutasScreen> createState() => _DibujarRutasScreenState();
// }

// class _DibujarRutasScreenState extends State<DibujarRutasScreen> {
//   final RutaController _rutaController = RutaController();
//   final PuntoRutaController _puntoRutaController = PuntoRutaController();
//   final TextEditingController _nombreCtrl = TextEditingController();
//   final TextEditingController _descripcionCtrl = TextEditingController();
//   final TextEditingController _colorCtrl = TextEditingController(
//     text: '#2196F3',
//   );

//   final String apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M"; // Tu API Key

//   final List<String> coloresHex = [
//     '#2196F3',
//     '#F44336',
//     '#4CAF50',
//     '#FFEB3B',
//     '#9C27B0',
//     '#FF9800',
//     '#00BCD4',
//     '#E91E63',
//     '#795548',
//     '#607D8B',
//   ];
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   List<LatLng> _puntosRuta = [];
//   bool _dibujando = false;
//   bool _guardando = false;
//   bool _calculandoRuta = false;

//   void _agregarPunto(LatLng punto) async {
//     setState(() {
//       _puntosRuta.add(punto);
//       _markers.add(
//         Marker(
//           markerId: MarkerId('punto_${_puntosRuta.length}'),
//           position: punto,
//           infoWindow: InfoWindow(
//             title: 'Punto ${_puntosRuta.length}',
//             snippet:
//                 '${punto.latitude.toStringAsFixed(5)}, ${punto.longitude.toStringAsFixed(5)}',
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             _puntosRuta.length % 2 == 0
//                 ? BitmapDescriptor.hueBlue
//                 : BitmapDescriptor.hueRed,
//           ),
//         ),
//       );
//     });

//     // Calcular ruta real entre puntos
//     await _calcularRutaReal();
//     _moverCamaraAlUltimoPunto();
//   }

//   // 🔹 CALCULAR RUTA REAL ENTRE PUNTOS USANDO GOOGLE DIRECTIONS API
//   Future<void> _calcularRutaReal() async {
//     if (_puntosRuta.length < 2) {
//       _actualizarPolylineRecta(); // Si solo hay un punto, usa línea recta
//       return;
//     }

//     setState(() => _calculandoRuta = true);

//     try {
//       final List<LatLng> puntosRutaCompleta = [];

//       // Calcular rutas entre cada par de puntos consecutivos
//       for (int i = 0; i < _puntosRuta.length - 1; i++) {
//         final origen = _puntosRuta[i];
//         final destino = _puntosRuta[i + 1];

//         final url =
//             "https://maps.googleapis.com/maps/api/directions/json?"
//             "origin=${origen.latitude},${origen.longitude}&"
//             "destination=${destino.latitude},${destino.longitude}&"
//             "mode=driving&" // Usar modo driving para seguir calles
//             "key=$apiKey";

//         final res = await http.get(Uri.parse(url));

//         if (res.statusCode == 200) {
//           final data = jsonDecode(res.body);
//           if (data['status'] == "OK" && data['routes'].isNotEmpty) {
//             final steps = data['routes'][0]['overview_polyline']['points'];
//             final segmentoRuta = _decodePolyline(steps);

//             // Agregar segmento a la ruta completa
//             if (i == 0) {
//               puntosRutaCompleta.addAll(segmentoRuta);
//             } else {
//               // Evitar duplicar el último punto del segmento anterior
//               puntosRutaCompleta.addAll(segmentoRuta.skip(1));
//             }
//           } else {
//             // Si falla la API, usar línea recta entre estos puntos
//             puntosRutaCompleta.addAll([origen, destino]);
//           }
//         } else {
//           // Si hay error HTTP, usar línea recta
//           puntosRutaCompleta.addAll([origen, destino]);
//         }
//       }

//       _actualizarPolylineConRutaReal(puntosRutaCompleta);
//     } catch (e) {
//       print('❌ Error calculando ruta: $e');
//       // En caso de error, usar línea recta
//       _actualizarPolylineRecta();
//     } finally {
//       setState(() => _calculandoRuta = false);
//     }
//   }

//   // 🔹 ACTUALIZAR POLYLINE CON RUTA REAL
//   void _actualizarPolylineConRutaReal(List<LatLng> puntosRutaCompleta) {
//     _polylines = {
//       Polyline(
//         polylineId: const PolylineId('ruta_dibujada'),
//         color: _obtenerColorPolyline(),
//         width: 6,
//         points: puntosRutaCompleta,
//       ),
//     };
//     setState(() {});
//   }

//   // 🔹 ACTUALIZAR POLYLINE CON LÍNEA RECTA (fallback)
//   void _actualizarPolylineRecta() {
//     _polylines = {
//       Polyline(
//         polylineId: const PolylineId('ruta_dibujada'),
//         color: _obtenerColorPolyline(),
//         width: 5,
//         points: _puntosRuta,
//       ),
//     };
//     setState(() {});
//   }

//   Color _obtenerColorPolyline() {
//     try {
//       return Color(int.parse(_colorCtrl.text.replaceFirst('#', '0xFF')));
//     } catch (e) {
//       return Colors.blue;
//     }
//   }

//   // 🔹 DECODIFICAR POLYLINE DE GOOGLE
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

//   // 🔹 Reiniciar el dibujo
//   void _reiniciarDibujo() {
//     setState(() {
//       _puntosRuta.clear();
//       _markers.clear();
//       _polylines.clear();
//       _dibujando = false;
//     });
//   }

//   // 🔹 Mover cámara al último punto
//   void _moverCamaraAlUltimoPunto() {
//     if (_puntosRuta.isNotEmpty && _mapController != null) {
//       _mapController!.animateCamera(CameraUpdate.newLatLng(_puntosRuta.last));
//     }
//   }

//   // 🔹 Guardar la ruta en la base de datos
//   Future<void> _guardarRuta() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_puntosRuta.isEmpty) {
//       _mostrarSnackBar('Debes dibujar una ruta en el mapa');
//       return;
//     }

//     setState(() => _guardando = true);

//     try {
//       // 1. Crear la ruta
//       final rutaCreada = await _rutaController.crearRuta(
//         Ruta(
//           IdRuta: 0,
//           nombre: _nombreCtrl.text,
//           descripcion: _descripcionCtrl.text.isNotEmpty
//               ? _descripcionCtrl.text
//               : null,
//           color: _colorCtrl.text,
//           FechaRegistro: DateTime.now(),
//           puntos: [],
//           buses: null,
//         ),
//       );

//       // 2. Crear los puntos de ruta
//       for (int i = 0; i < _puntosRuta.length; i++) {
//         final punto = _puntosRuta[i];
//         await _puntoRutaController.crearPuntoRuta(
//           PuntoRuta(
//             IdPunto: 0,
//             RutaId: rutaCreada.IdRuta,
//             latitud: punto.latitude,
//             longitud: punto.longitude,
//             orden: i + 1,
//           ),
//         );
//       }

//       _mostrarSnackBar(
//         '✅ Ruta guardada correctamente con ${_puntosRuta.length} puntos',
//       );
//       _reiniciarDibujo();
//       _nombreCtrl.clear();
//       _descripcionCtrl.clear();
//       _colorCtrl.text = '#2196F3';
//     } catch (e) {
//       _mostrarSnackBar('❌ Error al guardar la ruta: $e');
//     } finally {
//       setState(() => _guardando = false);
//     }
//   }

//   void _mostrarSnackBar(String mensaje) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
//     );
//   }

//   void _confirmarReinicio() {
//     if (_puntosRuta.isEmpty) return;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Reiniciar dibujo'),
//         content: const Text(
//           '¿Estás seguro de que quieres eliminar todos los puntos?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancelar'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _reiniciarDibujo();
//             },
//             child: const Text('Reiniciar', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dibujar Nueva Ruta'),
//         backgroundColor: Colors.indigo,
//         actions: [
//           if (_puntosRuta.isNotEmpty)
//             Chip(
//               label: Text('${_puntosRuta.length} pts'),
//               backgroundColor: Colors.white,
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 3,
//                           child: TextFormField(
//                             controller: _nombreCtrl,
//                             decoration: const InputDecoration(
//                               labelText: 'Nombre de la ruta *',
//                               border: OutlineInputBorder(),
//                               prefixIcon: Icon(Icons.route),
//                             ),
//                             validator: (value) => value == null || value.isEmpty
//                                 ? 'Ingrese el nombre de la ruta'
//                                 : null,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           flex: 1,
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: TextFormField(
//                                   controller: _colorCtrl,
//                                   decoration: const InputDecoration(
//                                     labelText: 'Color',
//                                     border: OutlineInputBorder(),
//                                     prefixIcon: Icon(Icons.color_lens),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               DropdownButton<String>(
//                                 value: _colorCtrl.text,
//                                 icon: const Icon(Icons.arrow_drop_down),
//                                 items: coloresHex.map((color) {
//                                   return DropdownMenuItem(
//                                     value: color,
//                                     child: Row(
//                                       children: [
//                                         Container(
//                                           width: 20,
//                                           height: 20,
//                                           margin: const EdgeInsets.only(
//                                             right: 8,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: Color(
//                                               int.parse(
//                                                     color.substring(1, 7),
//                                                     radix: 16,
//                                                   ) +
//                                                   0xFF000000,
//                                             ),
//                                             borderRadius: BorderRadius.circular(
//                                               4,
//                                             ),
//                                             border: Border.all(
//                                               color: Colors.grey.shade400,
//                                             ),
//                                           ),
//                                         ),
//                                         Text(color),
//                                       ],
//                                     ),
//                                   );
//                                 }).toList(),
//                                 onChanged: (nuevoColor) {
//                                   if (nuevoColor != null) {
//                                     setState(() {
//                                       _colorCtrl.text = nuevoColor;
//                                       _actualizarPolylineRecta(); // Actualizar color inmediatamente
//                                     });
//                                   }
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: _descripcionCtrl,
//                       maxLines: 2,
//                       decoration: const InputDecoration(
//                         labelText: 'Descripción (opcional)',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.description),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // 🔹 Mapa interactivo
//           Expanded(
//             flex: 7,
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: const CameraPosition(
//                     target: LatLng(-15.47353, -70.12007),
//                     zoom: 13,
//                   ),
//                   onMapCreated: (controller) => _mapController = controller,
//                   markers: _markers,
//                   polylines: _polylines,
//                   onTap: (pos) {
//                     if (_dibujando) {
//                       _agregarPunto(pos);
//                     }
//                   },
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                 ),

//                 // 🔹 Indicadores de estado
//                 if (_dibujando)
//                   Positioned(
//                     top: 10,
//                     left: 10,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.edit_location_alt,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Modo dibujo - ${_puntosRuta.length} puntos',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 if (_calculandoRuta)
//                   Positioned(
//                     top: 50,
//                     left: 10,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             width: 12,
//                             height: 12,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Calculando ruta...',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 // 🔹 Botones de control
//                 Positioned(
//                   bottom: 15,
//                   left: 10,
//                   right: 10,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       FloatingActionButton.extended(
//                         heroTag: "btn_dibujar",
//                         onPressed: () {
//                           setState(() => _dibujando = !_dibujando);
//                           _mostrarSnackBar(
//                             _dibujando
//                                 ? '🎯 Toca el mapa para agregar puntos (seguirá calles)'
//                                 : '⏸️ Dibujo pausado',
//                           );
//                         },
//                         label: Text(_dibujando ? 'Pausar' : 'Dibujar'),
//                         icon: Icon(
//                           _dibujando ? Icons.pause : Icons.edit_location_alt,
//                         ),
//                         backgroundColor: _dibujando
//                             ? Colors.orange
//                             : Colors.indigo,
//                         foregroundColor: Colors.white,
//                       ),

//                       FloatingActionButton.extended(
//                         heroTag: "btn_guardar",
//                         onPressed: _guardando ? null : _guardarRuta,
//                         label: _guardando
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Text('Guardar'),
//                         icon: _guardando
//                             ? const SizedBox.shrink()
//                             : const Icon(Icons.save),
//                         backgroundColor: _guardando
//                             ? Colors.grey
//                             : Colors.green,
//                         foregroundColor: Colors.white,
//                       ),

//                       FloatingActionButton(
//                         heroTag: "btn_reiniciar",
//                         onPressed: _puntosRuta.isNotEmpty
//                             ? _confirmarReinicio
//                             : null,
//                         backgroundColor: _puntosRuta.isNotEmpty
//                             ? Colors.red
//                             : Colors.grey,
//                         foregroundColor: Colors.white,
//                         child: const Icon(Icons.delete),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nombreCtrl.dispose();
//     _descripcionCtrl.dispose();
//     _colorCtrl.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/rutas.dart';
import '../../data/models/punto_ruta.dart';
import '../../presentation/controllers/ruta_controller.dart';
import '../../presentation/controllers/punto_ruta_controller.dart';

class DibujarRutasScreen extends StatefulWidget {
  const DibujarRutasScreen({super.key});

  @override
  State<DibujarRutasScreen> createState() => _DibujarRutasScreenState();
}

class _DibujarRutasScreenState extends State<DibujarRutasScreen> {
  final RutaController _rutaController = RutaController();
  final PuntoRutaController _puntoRutaController = PuntoRutaController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _colorCtrl = TextEditingController(
    text: '#2196F3',
  );

  final String apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M";

  final List<String> coloresHex = [
    '#2196F3',
    '#F44336',
    '#4CAF50',
    '#FFEB3B',
    '#9C27B0',
    '#FF9800',
    '#00BCD4',
    '#E91E63',
    '#795548',
    '#607D8B',
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<PuntoRuta> _puntosRuta =
      []; // Ahora almacena PuntoRuta en lugar de solo LatLng
  bool _dibujando = false;
  bool _guardando = false;
  bool _calculandoRuta = false;
  bool _usarRutasReales = true; // Toggle para Google Directions API
  bool _modoPuntoMedio = false; // Toggle para agregar puntos medios

  void _agregarPunto(LatLng punto) async {
    final nuevoPunto = PuntoRuta(
      IdPunto: 0,
      RutaId: 0, // Se asignará al guardar
      latitud: punto.latitude,
      longitud: punto.longitude,
      orden: _puntosRuta.length + 1,
      tipoPunto: _modoPuntoMedio ? 'medio' : 'normal', // Tipo de punto
    );

    setState(() {
      _puntosRuta.add(nuevoPunto);
      _actualizarMarcadores();
    });

    // Calcular ruta real entre puntos si está activado
    if (_usarRutasReales) {
      await _calcularRutaReal();
    } else {
      _actualizarPolylineRecta();
    }

    _moverCamaraAlUltimoPunto();
  }

  // 🔹 ACTUALIZAR MARCADORES MOSTRANDO SOLO PUNTOS IMPORTANTES
  void _actualizarMarcadores() {
    _markers.clear();

    for (int i = 0; i < _puntosRuta.length; i++) {
      final punto = _puntosRuta[i];
      final latLng = LatLng(punto.latitud, punto.longitud);

      // Determinar si mostrar este marcador
      bool mostrarMarcador = _debeMostrarMarcador(i);

      if (mostrarMarcador) {
        _markers.add(
          Marker(
            markerId: MarkerId('punto_${i + 1}'),
            position: latLng,
            infoWindow: InfoWindow(
              title: _obtenerTituloMarcador(i),
              snippet:
                  '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}',
            ),
            icon: _obtenerIconoMarcador(i),
          ),
        );
      }
    }
  }

  // 🔹 DETERMINAR SI MOSTRAR UN MARCADOR
  bool _debeMostrarMarcador(int index) {
    // Siempre mostrar primer y último punto
    if (index == 0 || index == _puntosRuta.length - 1) return true;

    // Mostrar puntos marcados como "medio"
    if (_puntosRuta[index].tipoPunto == 'medio') return true;

    // Mostrar algunos puntos intermedios si hay muchos (cada 5 puntos)
    if (_puntosRuta.length > 10 && index % 5 == 0) return true;

    return false;
  }

  // 🔹 OBTENER TÍTULO DEL MARCADOR
  String _obtenerTituloMarcador(int index) {
    if (index == 0) return '🏁 Inicio';
    if (index == _puntosRuta.length - 1) return '🎯 Fin';
    if (_puntosRuta[index].tipoPunto == 'medio') return '🔄 Punto Medio';
    return 'Punto ${index + 1}';
  }

  // 🔹 OBTENER ICONO DEL MARCADOR
  BitmapDescriptor _obtenerIconoMarcador(int index) {
    if (index == 0)
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    if (index == _puntosRuta.length - 1)
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    if (_puntosRuta[index].tipoPunto == 'medio')
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  // 🔹 CALCULAR RUTA REAL ENTRE PUNTOS
  Future<void> _calcularRutaReal() async {
    if (_puntosRuta.length < 2) {
      _actualizarPolylineRecta();
      return;
    }

    setState(() => _calculandoRuta = true);

    try {
      final List<LatLng> puntosRutaCompleta = [];

      for (int i = 0; i < _puntosRuta.length - 1; i++) {
        final origen = LatLng(_puntosRuta[i].latitud, _puntosRuta[i].longitud);
        final destino = LatLng(
          _puntosRuta[i + 1].latitud,
          _puntosRuta[i + 1].longitud,
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

      _actualizarPolylineConRutaReal(puntosRutaCompleta);
    } catch (e) {
      print('❌ Error calculando ruta: $e');
      _actualizarPolylineRecta();
    } finally {
      setState(() => _calculandoRuta = false);
    }
  }

  // 🔹 ACTUALIZAR POLYLINE CON RUTA REAL
  void _actualizarPolylineConRutaReal(List<LatLng> puntosRutaCompleta) {
    _polylines = {
      Polyline(
        polylineId: const PolylineId('ruta_dibujada'),
        color: _obtenerColorPolyline(),
        width: 6,
        points: puntosRutaCompleta,
      ),
    };
    setState(() {});
  }

  // 🔹 ACTUALIZAR POLYLINE CON LÍNEA RECTA
  void _actualizarPolylineRecta() {
    final puntosLatLng = _puntosRuta
        .map((p) => LatLng(p.latitud, p.longitud))
        .toList();
    _polylines = {
      Polyline(
        polylineId: const PolylineId('ruta_dibujada'),
        color: _obtenerColorPolyline(),
        width: 5,
        points: puntosLatLng,
      ),
    };
    setState(() {});
  }

  Color _obtenerColorPolyline() {
    try {
      return Color(int.parse(_colorCtrl.text.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
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

  // 🔹 REINICIAR DIBUJO
  void _reiniciarDibujo() {
    setState(() {
      _puntosRuta.clear();
      _markers.clear();
      _polylines.clear();
      _dibujando = false;
      _modoPuntoMedio = false;
    });
  }

  // 🔹 MOVER CÁMARA AL ÚLTIMO PUNTO
  void _moverCamaraAlUltimoPunto() {
    if (_puntosRuta.isNotEmpty && _mapController != null) {
      final ultimoPunto = _puntosRuta.last;
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(ultimoPunto.latitud, ultimoPunto.longitud),
        ),
      );
    }
  }

  // 🔹 GUARDAR RUTA EN BASE DE DATOS
  Future<void> _guardarRuta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_puntosRuta.isEmpty) {
      _mostrarSnackBar('Debes dibujar una ruta en el mapa');
      return;
    }

    setState(() => _guardando = true);

    try {
      // 1. Crear la ruta
      final rutaCreada = await _rutaController.crearRuta(
        Ruta(
          IdRuta: 0,
          nombre: _nombreCtrl.text,
          descripcion: _descripcionCtrl.text.isNotEmpty
              ? _descripcionCtrl.text
              : null,
          color: _colorCtrl.text,
          FechaRegistro: DateTime.now(),
          puntos: [],
          buses: null,
        ),
      );

      // 2. Crear los puntos de ruta
      for (int i = 0; i < _puntosRuta.length; i++) {
        final punto = _puntosRuta[i];
        await _puntoRutaController.crearPuntoRuta(
          PuntoRuta(
            IdPunto: 0,
            RutaId: rutaCreada.IdRuta,
            latitud: punto.latitud,
            longitud: punto.longitud,
            orden: i + 1,
            tipoPunto: punto.tipoPunto, // Guardar el tipo de punto
          ),
        );
      }

      _mostrarSnackBar(
        '✅ Ruta guardada correctamente con ${_puntosRuta.length} puntos',
      );
      _reiniciarDibujo();
      _nombreCtrl.clear();
      _descripcionCtrl.clear();
      _colorCtrl.text = '#2196F3';
    } catch (e) {
      _mostrarSnackBar('❌ Error al guardar la ruta: $e');
    } finally {
      setState(() => _guardando = false);
    }
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
    );
  }

  void _confirmarReinicio() {
    if (_puntosRuta.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar dibujo'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos los puntos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reiniciarDibujo();
            },
            child: const Text('Reiniciar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dibujar Nueva Ruta'),
        backgroundColor: Colors.indigo,
        actions: [
          if (_puntosRuta.isNotEmpty)
            Chip(
              label: Text('${_puntosRuta.length} pts'),
              backgroundColor: Colors.white,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _nombreCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la ruta *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.route),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Ingrese el nombre de la ruta'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _colorCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Color',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.color_lens),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _colorCtrl.text,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: coloresHex.map((color) {
                                  return DropdownMenuItem(
                                    value: color,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              int.parse(
                                                    color.substring(1, 7),
                                                    radix: 16,
                                                  ) +
                                                  0xFF000000,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ),
                                        Text(color),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (nuevoColor) {
                                  if (nuevoColor != null) {
                                    setState(() {
                                      _colorCtrl.text = nuevoColor;
                                      if (_usarRutasReales) {
                                        _calcularRutaReal();
                                      } else {
                                        _actualizarPolylineRecta();
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descripcionCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Mapa interactivo
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-15.47353, -70.12007),
                    zoom: 13,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  polylines: _polylines,
                  onTap: (pos) {
                    if (_dibujando) {
                      _agregarPunto(pos);
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),

                // 🔹 TOGGLE CONTROLES SUPERIORES
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      // Toggle Rutas Reales
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _usarRutasReales ? Icons.route : Icons.straight,
                              size: 16,
                              color: _usarRutasReales
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _usarRutasReales ? 'Calles' : 'Recta',
                              style: TextStyle(
                                color: _usarRutasReales
                                    ? Colors.green
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Switch(
                              value: _usarRutasReales,
                              onChanged: (value) {
                                setState(() {
                                  _usarRutasReales = value;
                                  if (_puntosRuta.length >= 2) {
                                    if (_usarRutasReales) {
                                      _calcularRutaReal();
                                    } else {
                                      _actualizarPolylineRecta();
                                    }
                                  }
                                });
                              },
                              activeColor: Colors.green,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Toggle Punto Medio
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _modoPuntoMedio ? Icons.flag : Icons.location_on,
                              size: 16,
                              color: _modoPuntoMedio
                                  ? Colors.orange
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _modoPuntoMedio ? 'Punto Medio' : 'Normal',
                              style: TextStyle(
                                color: _modoPuntoMedio
                                    ? Colors.orange
                                    : Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Switch(
                              value: _modoPuntoMedio,
                              onChanged: _dibujando
                                  ? (value) {
                                      setState(() {
                                        _modoPuntoMedio = value;
                                        _mostrarSnackBar(
                                          _modoPuntoMedio
                                              ? '🔄 Modo Punto Medio activado'
                                              : '📍 Modo Normal activado',
                                        );
                                      });
                                    }
                                  : null,
                              activeColor: Colors.orange,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 INDICADORES DE ESTADO
                if (_dibujando)
                  Positioned(
                    top: 50,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_location_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Dibujando - ${_puntosRuta.length} puntos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_calculandoRuta)
                  Positioned(
                    top: 50,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Calculando...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 🔹 BOTONES DE CONTROL INFERIORES
                Positioned(
                  bottom: 15,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "btn_dibujar",
                        onPressed: () {
                          setState(() => _dibujando = !_dibujando);
                          _mostrarSnackBar(
                            _dibujando
                                ? '🎯 Toca el mapa para agregar puntos'
                                : '⏸️ Dibujo pausado',
                          );
                        },
                        label: Text(_dibujando ? 'Pausar' : 'Dibujar'),
                        icon: Icon(
                          _dibujando ? Icons.pause : Icons.edit_location_alt,
                        ),
                        backgroundColor: _dibujando
                            ? Colors.orange
                            : Colors.indigo,
                        foregroundColor: Colors.white,
                      ),

                      FloatingActionButton.extended(
                        heroTag: "btn_guardar",
                        onPressed: _guardando ? null : _guardarRuta,
                        label: _guardando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Guardar'),
                        icon: _guardando
                            ? const SizedBox.shrink()
                            : const Icon(Icons.save),
                        backgroundColor: _guardando
                            ? Colors.grey
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),

                      FloatingActionButton(
                        heroTag: "btn_reiniciar",
                        onPressed: _puntosRuta.isNotEmpty
                            ? _confirmarReinicio
                            : null,
                        backgroundColor: _puntosRuta.isNotEmpty
                            ? Colors.red
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }
}
