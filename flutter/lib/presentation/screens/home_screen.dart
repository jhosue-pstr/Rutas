// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final String apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M";

//   GoogleMapController? _mapController;
//   LatLng? _origen;
//   LatLng? _destino;
//   bool _cargando = false;
//   bool _seleccionOrigen = false;
//   bool _seleccionDestino = false;
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};

//   final TextEditingController _origenCtrl = TextEditingController();
//   final TextEditingController _destinoCtrl = TextEditingController();

//   List<String> _sugerenciasOrigen = [];
//   List<String> _sugerenciasDestino = [];

//   @override
//   void initState() {
//     super.initState();
//     _obtenerUbicacionActual();
//   }

//   Future<void> _obtenerUbicacionActual() async {
//     setState(() => _cargando = true);

//     bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
//     if (!servicioHabilitado) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Activa el GPS')));
//       setState(() => _cargando = false);
//       return;
//     }

//     LocationPermission permiso = await Geolocator.checkPermission();
//     if (permiso == LocationPermission.denied) {
//       permiso = await Geolocator.requestPermission();
//       if (permiso == LocationPermission.denied) {
//         setState(() => _cargando = false);
//         return;
//       }
//     }

//     Position posicion = await Geolocator.getCurrentPosition();
//     _origen = LatLng(posicion.latitude, posicion.longitude);
//     _origenCtrl.text = "Mi ubicación actual";
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('origen'),
//         position: _origen!,
//         infoWindow: const InfoWindow(title: "Origen"),
//       ),
//     );

//     setState(() => _cargando = false);
//     _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_origen!, 15));
//   }

//   Future<List<String>> _buscarLugares(String input, LatLng? ubicacion) async {
//     if (input.isEmpty) return [];
//     String locationParam = '';
//     if (ubicacion != null) {
//       locationParam =
//           "&location=${ubicacion.latitude},${ubicacion.longitude}&radius=5000&strictbounds=true";
//     }

//     final url =
//         "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apiKey$locationParam";
//     final res = await http.get(Uri.parse(url));
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       if (data['status'] == "OK") {
//         return List<String>.from(
//           data['predictions'].map((p) => p['description']),
//         );
//       }
//     }
//     return [];
//   }

//   Future<LatLng?> _geocode(String direccion) async {
//     final url =
//         "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(direccion)}&key=$apiKey";
//     final res = await http.get(Uri.parse(url));
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       if (data['status'] == "OK" && data['results'].isNotEmpty) {
//         final loc = data['results'][0]['geometry']['location'];
//         return LatLng(loc['lat'], loc['lng']);
//       }
//     }
//     return null;
//   }

//   Future<void> _trazarRuta() async {
//     if (_origen == null || _destino == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Selecciona origen y destino')),
//       );
//       return;
//     }

//     final url =
//         "https://maps.googleapis.com/maps/api/directions/json?origin=${_origen!.latitude},${_origen!.longitude}&destination=${_destino!.latitude},${_destino!.longitude}&mode=walking&key=$apiKey";

//     final res = await http.get(Uri.parse(url));
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       if (data['status'] == "OK" && data['routes'].isNotEmpty) {
//         final steps = data['routes'][0]['overview_polyline']['points'];
//         _polylines.clear();
//         _polylines.add(
//           Polyline(
//             polylineId: const PolylineId('ruta'),
//             color: Colors.green,
//             width: 5,
//             points: _decodePolyline(steps),
//           ),
//         );
//         setState(() {});
//         _mapController?.animateCamera(
//           CameraUpdate.newLatLngBounds(
//             _boundsFromLatLngList([_origen!, _destino!]),
//             50,
//           ),
//         );

//         final duracion = data['routes'][0]['legs'][0]['duration']['text'];
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Tiempo estimado: $duracion')));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No se pudo trazar la ruta')),
//         );
//       }
//     }
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

//   LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
//     double south = list.first.latitude,
//         north = list.first.latitude,
//         west = list.first.longitude,
//         east = list.first.longitude;
//     for (var coord in list) {
//       if (coord.latitude > north) north = coord.latitude;
//       if (coord.latitude < south) south = coord.latitude;
//       if (coord.longitude > east) east = coord.longitude;
//       if (coord.longitude < west) west = coord.longitude;
//     }
//     return LatLngBounds(
//       southwest: LatLng(south, west),
//       northeast: LatLng(north, east),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: const CameraPosition(
//               target: LatLng(-15.47353, -70.12007),
//               zoom: 13,
//             ),
//             onMapCreated: (controller) => _mapController = controller,
//             markers: _markers,
//             polylines: _polylines,
//             myLocationEnabled: true,
//             zoomControlsEnabled: false,
//             onTap: (pos) {
//               if (_seleccionOrigen) {
//                 _origen = pos;
//                 _markers.removeWhere((m) => m.markerId.value == 'origen');
//                 _markers.add(
//                   Marker(
//                     markerId: const MarkerId('origen'),
//                     position: pos,
//                     infoWindow: const InfoWindow(title: 'Origen'),
//                   ),
//                 );
//                 _origenCtrl.text = "Seleccionado en mapa";
//                 _seleccionOrigen = false;
//               } else if (_seleccionDestino) {
//                 _destino = pos;
//                 _markers.removeWhere((m) => m.markerId.value == 'destino');
//                 _markers.add(
//                   Marker(
//                     markerId: const MarkerId('destino'),
//                     position: pos,
//                     infoWindow: const InfoWindow(title: 'Destino'),
//                   ),
//                 );
//                 _destinoCtrl.text = "Seleccionado en mapa";
//                 _seleccionDestino = false;
//               }
//               setState(() {});
//             },
//           ),
//           Positioned(
//             top: 15, // <-- 10 píxeles más abajo
//             left: 10,
//             right: 10,
//             child: Column(
//               children: [
//                 _campoAutocomplete(_origenCtrl, true),
//                 const SizedBox(height: 8),
//                 _campoAutocomplete(_destinoCtrl, false),
//               ],
//             ),
//           ),
//           if (_cargando) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           FloatingActionButton.extended(
//             heroTag: "btn_trazar_ruta",
//             onPressed: _trazarRuta,
//             icon: const Icon(Icons.alt_route),
//             label: const Text('Trazar ruta'),
//           ),
//           const SizedBox(width: 15),
//           FloatingActionButton(
//             heroTag: "btn_mi_ubicacion",
//             onPressed: _obtenerUbicacionActual,
//             child: const Icon(Icons.my_location),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _campoAutocomplete(TextEditingController ctrl, bool esOrigen) {
//     return Column(
//       children: [
//         TextField(
//           controller: ctrl,
//           decoration: InputDecoration(
//             hintText: esOrigen ? 'Punto de partida' : 'Destino',
//             prefixIcon: IconButton(
//               icon: Icon(esOrigen ? Icons.location_on : Icons.flag),
//               onPressed: () {
//                 if (esOrigen) {
//                   _seleccionOrigen = true;
//                   _seleccionDestino = false;
//                 } else {
//                   _seleccionDestino = true;
//                   _seleccionOrigen = false;
//                 }
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       esOrigen
//                           ? 'Toca en el mapa para seleccionar el origen'
//                           : 'Toca en el mapa para seleccionar el destino',
//                     ),
//                   ),
//                 );
//               },
//             ),
//             filled: true,
//             fillColor: Colors.white.withOpacity(0.9),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//           onChanged: (value) async {
//             final sugerencias = await _buscarLugares(
//               value,
//               esOrigen ? _origen : _destino,
//             );
//             setState(() {
//               if (esOrigen) {
//                 _sugerenciasOrigen = sugerencias;
//               } else {
//                 _sugerenciasDestino = sugerencias;
//               }
//             });
//           },
//         ),
//         ...((esOrigen ? _sugerenciasOrigen : _sugerenciasDestino)
//             .map(
//               (s) => ListTile(
//                 title: Text(s),
//                 onTap: () async {
//                   ctrl.text = s;
//                   LatLng? pos = await _geocode(s);
//                   if (pos != null) {
//                     if (esOrigen) {
//                       _origen = pos;
//                       _markers.removeWhere((m) => m.markerId.value == 'origen');
//                       _markers.add(
//                         Marker(
//                           markerId: const MarkerId('origen'),
//                           position: pos,
//                           infoWindow: const InfoWindow(title: 'Origen'),
//                         ),
//                       );
//                     } else {
//                       _destino = pos;
//                       _markers.removeWhere(
//                         (m) => m.markerId.value == 'destino',
//                       );
//                       _markers.add(
//                         Marker(
//                           markerId: const MarkerId('destino'),
//                           position: pos,
//                           infoWindow: const InfoWindow(title: 'Destino'),
//                         ),
//                       );
//                     }
//                   }
//                   setState(() {
//                     if (esOrigen) {
//                       _sugerenciasOrigen = [];
//                     } else {
//                       _sugerenciasDestino = [];
//                     }
//                   });
//                 },
//               ),
//             )
//             .toList()),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/rutas.dart';
import '../../data/models/bus.dart';
import '../../presentation/controllers/ruta_controller.dart';
import '../../presentation/controllers/bus_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M";

  GoogleMapController? _mapController;
  LatLng? _origen;
  LatLng? _destino;
  bool _cargando = false;
  bool _seleccionOrigen = false;
  bool _seleccionDestino = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final TextEditingController _origenCtrl = TextEditingController();
  final TextEditingController _destinoCtrl = TextEditingController();

  List<String> _sugerenciasOrigen = [];
  List<String> _sugerenciasDestino = [];

  // Nuevas variables para el sistema de buses
  final RutaController _rutaController = RutaController();
  final BusController _busController = BusController();
  List<Ruta> _todasLasRutas = [];
  List<Bus> _todosLosBuses = [];
  List<RutaRecomendacion> _rutasRecomendadas = [];
  bool _mostrarResultados = false;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
    _cargarDatosBuses();
  }

  Future<void> _cargarDatosBuses() async {
    try {
      _todasLasRutas = await _rutaController.obtenerRutas();
      _todosLosBuses = await _busController.obtenerBuses();
      print(
        '✅ Datos cargados: ${_todasLasRutas.length} rutas, ${_todosLosBuses.length} buses',
      );
    } catch (e) {
      print('❌ Error cargando datos de buses: $e');
    }
  }

  Future<void> _obtenerUbicacionActual() async {
    setState(() => _cargando = true);

    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Activa el GPS')));
      setState(() => _cargando = false);
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        setState(() => _cargando = false);
        return;
      }
    }

    try {
      Position posicion = await Geolocator.getCurrentPosition();
      _origen = LatLng(posicion.latitude, posicion.longitude);
      _origenCtrl.text = "Mi ubicación actual";
      _markers.add(
        Marker(
          markerId: const MarkerId('origen'),
          position: _origen!,
          infoWindow: const InfoWindow(title: "Origen"),
        ),
      );

      setState(() => _cargando = false);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_origen!, 15));
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error obteniendo ubicación: $e')));
    }
  }

  // 🔹 CALCULAR RUTAS DE BUSES - VERSIÓN ROBUSTA
  Future<void> _calcularRutasBuses() async {
    if (_origen == null || _destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona origen y destino')),
      );
      return;
    }

    setState(() {
      _cargando = true;
      _mostrarResultados = false;
      _rutasRecomendadas = [];
    });

    try {
      print('📍 Calculando rutas desde: $_origen hasta: $_destino');

      // 1. Verificar que tenemos datos
      if (_todosLosBuses.isEmpty || _todasLasRutas.isEmpty) {
        await _cargarDatosBuses();
      }

      // 2. Buscar buses cerca con validaciones
      List<Bus> busesCercaOrigen = [];
      List<Bus> busesCercaDestino = [];

      try {
        busesCercaOrigen = await _busController.obtenerBusesCercaDe(
          _origen!,
          _todosLosBuses,
          _todasLasRutas,
        );
        busesCercaDestino = await _busController.obtenerBusesCercaDe(
          _destino!,
          _todosLosBuses,
          _todasLasRutas,
        );

        print('🚌 Buses cerca origen: ${busesCercaOrigen.length}');
        print('🎯 Buses cerca destino: ${busesCercaDestino.length}');
      } catch (e) {
        print('❌ Error buscando buses cerca: $e');
        throw Exception('No se pudieron encontrar buses cerca de tu ubicación');
      }

      // 3. Validar que hay buses disponibles
      if (busesCercaOrigen.isEmpty || busesCercaDestino.isEmpty) {
        throw Exception(
          'No hay buses disponibles cerca de tu ubicación o destino',
        );
      }

      // 4. Calcular rutas recomendadas
      _rutasRecomendadas = _busController.calcularRutasRecomendadas(
        busesCercaOrigen,
        busesCercaDestino,
        _origen!,
        _destino!,
        _todasLasRutas,
      );

      print('📊 Rutas calculadas: ${_rutasRecomendadas.length}');

      // 5. Trazar ruta en el mapa
      await _trazarRutaEnMapa();

      setState(() {
        _mostrarResultados = true;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      print('❌ Error en _calcularRutasBuses: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // 🔹 TRAZAR RUTA EN EL MAPA
  Future<void> _trazarRutaEnMapa() async {
    if (_origen == null || _destino == null) return;

    try {
      final url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${_origen!.latitude},${_origen!.longitude}&destination=${_destino!.latitude},${_destino!.longitude}&mode=walking&key=$apiKey";

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == "OK" && data['routes'].isNotEmpty) {
          final steps = data['routes'][0]['overview_polyline']['points'];
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('ruta'),
              color: Colors.green,
              width: 5,
              points: _decodePolyline(steps),
            ),
          );
          setState(() {});
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList([_origen!, _destino!]),
              50,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error trazando ruta: $e');
    }
  }

  // 🔹 MOSTRAR DETALLES DE RUTA
  void _mostrarDetallesRuta(RutaRecomendacion rutaRecomendada) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ruta Recomendada',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            // Tiempo total
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tiempo estimado'),
                        Text(
                          '${rutaRecomendada.tiempoTotal} min',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Buses a tomar
            const SizedBox(height: 16),
            const Text(
              'Buses a tomar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...rutaRecomendada.buses.map(
              (busInfo) => ListTile(
                leading: const Icon(Icons.directions_bus, color: Colors.green),
                title: Text('Bus ${busInfo.bus.placa}'),
                subtitle: Text('Ruta: ${busInfo.ruta.nombre}'),
                trailing: Text('${busInfo.tiempoEstimado} min'),
              ),
            ),

            // Instrucciones
            const SizedBox(height: 16),
            const Text(
              'Instrucciones:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.directions_walk,
                      color: Colors.orange,
                    ),
                    title: const Text('Camina hasta la parada'),
                    subtitle: Text(
                      '${rutaRecomendada.distanciaCaminando.toStringAsFixed(0)} m',
                    ),
                  ),
                  ...rutaRecomendada.buses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final busInfo = entry.value;
                    return ListTile(
                      leading: const Icon(
                        Icons.directions_bus,
                        color: Colors.green,
                      ),
                      title: Text('Toma el Bus ${busInfo.bus.placa}'),
                      subtitle: Text(
                        'Ruta: ${busInfo.ruta.nombre} - ${busInfo.tiempoEstimado} min',
                      ),
                    );
                  }),
                  ListTile(
                    leading: const Icon(
                      Icons.directions_walk,
                      color: Colors.orange,
                    ),
                    title: const Text('Camina hasta tu destino'),
                    subtitle: Text(
                      '${rutaRecomendada.distanciaDestino.toStringAsFixed(0)} m',
                    ),
                  ),
                ],
              ),
            ),

            // Botón de acción
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Comenzar Viaje'),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 WIDGET DE RESULTADOS
  Widget _buildResultados() {
    if (!_mostrarResultados) return const SizedBox();

    if (_rutasRecomendadas.isEmpty) {
      return Positioned(
        bottom: 80,
        left: 10,
        right: 10,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 40),
              SizedBox(height: 8),
              Text(
                'No se encontraron rutas disponibles',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                'Intenta con otro origen o destino',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Positioned(
      bottom: 80,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚌 Rutas Recomendadas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._rutasRecomendadas
                .take(3)
                .map(
                  (ruta) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.directions_bus,
                        color: Colors.green,
                      ),
                      title: Text(
                        '${ruta.buses.length} bus(es) - ${ruta.tiempoTotal} min',
                      ),
                      subtitle: Text(
                        ruta.buses.map((b) => b.bus.placa).join(' → '),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _mostrarDetallesRuta(ruta),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // 🔹 MÉTODOS EXISTENTES (sin cambios)
  Future<List<String>> _buscarLugares(String input, LatLng? ubicacion) async {
    if (input.isEmpty) return [];
    String locationParam = '';
    if (ubicacion != null) {
      locationParam =
          "&location=${ubicacion.latitude},${ubicacion.longitude}&radius=5000";
    }

    try {
      final url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apiKey$locationParam";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == "OK") {
          return List<String>.from(
            data['predictions'].map((p) => p['description']),
          );
        }
      }
    } catch (e) {
      print('Error buscando lugares: $e');
    }
    return [];
  }

  Future<LatLng?> _geocode(String direccion) async {
    try {
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(direccion)}&key=$apiKey";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == "OK" && data['results'].isNotEmpty) {
          final loc = data['results'][0]['geometry']['location'];
          return LatLng(loc['lat'], loc['lng']);
        }
      }
    } catch (e) {
      print('Error geocoding: $e');
    }
    return null;
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

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double south = list.first.latitude,
        north = list.first.latitude,
        west = list.first.longitude,
        east = list.first.longitude;
    for (var coord in list) {
      if (coord.latitude > north) north = coord.latitude;
      if (coord.latitude < south) south = coord.latitude;
      if (coord.longitude > east) east = coord.longitude;
      if (coord.longitude < west) west = coord.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-15.47353, -70.12007),
              zoom: 13,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            onTap: (pos) {
              if (_seleccionOrigen) {
                _origen = pos;
                _markers.removeWhere((m) => m.markerId.value == 'origen');
                _markers.add(
                  Marker(
                    markerId: const MarkerId('origen'),
                    position: pos,
                    infoWindow: const InfoWindow(title: 'Origen'),
                  ),
                );
                _origenCtrl.text = "Seleccionado en mapa";
                _seleccionOrigen = false;
              } else if (_seleccionDestino) {
                _destino = pos;
                _markers.removeWhere((m) => m.markerId.value == 'destino');
                _markers.add(
                  Marker(
                    markerId: const MarkerId('destino'),
                    position: pos,
                    infoWindow: const InfoWindow(title: 'Destino'),
                  ),
                );
                _destinoCtrl.text = "Seleccionado en mapa";
                _seleccionDestino = false;
              }
              setState(() {});
            },
          ),

          // Campos de búsqueda
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                _campoAutocomplete(_origenCtrl, true),
                const SizedBox(height: 8),
                _campoAutocomplete(_destinoCtrl, false),
              ],
            ),
          ),

          // Resultados de rutas
          _buildResultados(),

          if (_cargando) const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: "btn_calcular_ruta",
            onPressed: _calcularRutasBuses,
            icon: const Icon(Icons.directions_bus),
            label: const Text('Buscar buses'),
            backgroundColor: Colors.green,
          ),
          const SizedBox(width: 15),
          FloatingActionButton(
            heroTag: "btn_mi_ubicacion",
            onPressed: _obtenerUbicacionActual,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _campoAutocomplete(TextEditingController ctrl, bool esOrigen) {
    return Column(
      children: [
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: esOrigen ? 'Punto de partida' : 'Destino',
            prefixIcon: IconButton(
              icon: Icon(esOrigen ? Icons.location_on : Icons.flag),
              onPressed: () {
                setState(() {
                  if (esOrigen) {
                    _seleccionOrigen = true;
                    _seleccionDestino = false;
                  } else {
                    _seleccionDestino = true;
                    _seleccionOrigen = false;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esOrigen
                          ? 'Toca en el mapa para seleccionar el origen'
                          : 'Toca en el mapa para seleccionar el destino',
                    ),
                  ),
                );
              },
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.95),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (value) async {
            final sugerencias = await _buscarLugares(
              value,
              esOrigen ? _origen : _destino,
            );
            setState(() {
              if (esOrigen) {
                _sugerenciasOrigen = sugerencias;
              } else {
                _sugerenciasDestino = sugerencias;
              }
            });
          },
        ),
        ...((esOrigen ? _sugerenciasOrigen : _sugerenciasDestino)
            .map(
              (s) => ListTile(
                dense: true,
                title: Text(s),
                onTap: () async {
                  ctrl.text = s;
                  LatLng? pos = await _geocode(s);
                  if (pos != null) {
                    if (esOrigen) {
                      _origen = pos;
                      _markers.removeWhere((m) => m.markerId.value == 'origen');
                      _markers.add(
                        Marker(
                          markerId: const MarkerId('origen'),
                          position: pos,
                          infoWindow: const InfoWindow(title: 'Origen'),
                        ),
                      );
                    } else {
                      _destino = pos;
                      _markers.removeWhere(
                        (m) => m.markerId.value == 'destino',
                      );
                      _markers.add(
                        Marker(
                          markerId: const MarkerId('destino'),
                          position: pos,
                          infoWindow: const InfoWindow(title: 'Destino'),
                        ),
                      );
                    }
                  }
                  setState(() {
                    if (esOrigen) {
                      _sugerenciasOrigen = [];
                    } else {
                      _sugerenciasDestino = [];
                    }
                  });
                },
              ),
            )
            .toList()),
      ],
    );
  }
}
