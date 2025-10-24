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
//             top: 10,
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
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           FloatingActionButton(
//             heroTag: "btn_mi_ubicacion",
//             onPressed: _obtenerUbicacionActual,
//             child: const Icon(Icons.my_location),
//           ),
//           const SizedBox(height: 8),
//           FloatingActionButton.extended(
//             heroTag: "btn_trazar_ruta",
//             onPressed: _trazarRuta,
//             icon: const Icon(Icons.alt_route),
//             label: const Text('Trazar ruta'),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey = "";

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

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
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
  }

  Future<List<String>> _buscarLugares(String input, LatLng? ubicacion) async {
    if (input.isEmpty) return [];
    String locationParam = '';
    if (ubicacion != null) {
      locationParam =
          "&location=${ubicacion.latitude},${ubicacion.longitude}&radius=5000&strictbounds=true";
    }

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
    return [];
  }

  Future<LatLng?> _geocode(String direccion) async {
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
    return null;
  }

  Future<void> _trazarRuta() async {
    if (_origen == null || _destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona origen y destino')),
      );
      return;
    }

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

        final duracion = data['routes'][0]['legs'][0]['duration']['text'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tiempo estimado: $duracion')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo trazar la ruta')),
        );
      }
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
          Positioned(
            top: 15, // <-- 10 píxeles más abajo
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
          if (_cargando) const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: "btn_trazar_ruta",
            onPressed: _trazarRuta,
            icon: const Icon(Icons.alt_route),
            label: const Text('Trazar ruta'),
          ),
          const SizedBox(width: 15),
          FloatingActionButton(
            heroTag: "btn_mi_ubicacion",
            onPressed: _obtenerUbicacionActual,
            child: const Icon(Icons.my_location),
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
                if (esOrigen) {
                  _seleccionOrigen = true;
                  _seleccionDestino = false;
                } else {
                  _seleccionDestino = true;
                  _seleccionOrigen = false;
                }
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
            fillColor: Colors.white.withOpacity(0.9),
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
