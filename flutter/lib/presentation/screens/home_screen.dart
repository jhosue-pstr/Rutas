import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/app_drawer.dart';
import '../widgets/mapa_widget.dart';
import '../widgets/busqueda_widget.dart';
import '../widgets/rutas_mapa_widget.dart'; // ✅ IMPORTAR NUEVO WIDGET

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M";

  bool _cargando = false;
  LatLng? _origen;
  LatLng? _destino;
  bool _seleccionOrigen = false;
  bool _seleccionDestino = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Polyline> _rutasBuses = {}; // ✅ NUEVO: Rutas de buses

  // ✅ CONTROLADORES PARA LA BÚSQUEDA
  final TextEditingController _origenCtrl = TextEditingController();
  final TextEditingController _destinoCtrl = TextEditingController();

  void _onUbicacionObtenida(LatLng ubicacion) {
    setState(() {
      _origen = ubicacion;
      _origenCtrl.text = 'Mi ubicación actual';
    });
    _actualizarMarcadores();
  }

  void _onMapTap(LatLng position) {
    if (_seleccionOrigen) {
      setState(() {
        _origen = position;
        _seleccionOrigen = false;
        _origenCtrl.text = 'Seleccionado en mapa';
      });
      _actualizarMarcadores();
    } else if (_seleccionDestino) {
      setState(() {
        _destino = position;
        _seleccionDestino = false;
        _destinoCtrl.text = 'Seleccionado en mapa';
      });
      _actualizarMarcadores();
    }
  }

  // ✅ MANEJAR BÚSQUEDA DESDE WIDGET
  void _onDireccionEncontrada(LatLng? ubicacion, bool esOrigen) {
    setState(() {
      if (esOrigen) {
        _origen = ubicacion;
      } else {
        _destino = ubicacion;
      }
    });
    _actualizarMarcadores();
  }

  // ✅ MANEJAR RUTAS DE BUSES CARGADAS
  void _onRutasBusesCargadas(Set<Polyline> rutas) {
    setState(() {
      _rutasBuses = rutas;
    });
    print('✅ ${_rutasBuses.length} rutas de buses cargadas en el mapa');
  }

  void _actualizarMarcadores() {
    _markers.clear();

    if (_origen != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('origen'),
          position: _origen!,
          infoWindow: InfoWindow(title: 'Origen'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (_destino != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('destino'),
          position: _destino!,
          infoWindow: InfoWindow(title: 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    setState(() {});
  }

  void _activarSeleccionOrigen() {
    setState(() {
      _seleccionOrigen = true;
      _seleccionDestino = false;
    });
  }

  void _activarSeleccionDestino() {
    setState(() {
      _seleccionDestino = true;
      _seleccionOrigen = false;
    });
  }

  void _onLoadingChange(bool cargando) {
    setState(() {
      _cargando = cargando;
    });
  }

  void _calcularRutas() {
    if (_origen != null && _destino != null) {
      _trazarRutaEnMapa();
    }
  }

  // ✅ RUTA REAL POR CALLES - MODO DRIVING
  Future<void> _trazarRutaEnMapa() async {
    if (_origen == null || _destino == null) return;

    setState(() => _cargando = true);

    try {
      final url =
          "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${_origen!.latitude},${_origen!.longitude}"
          "&destination=${_destino!.latitude},${_destino!.longitude}"
          "&mode=driving" // ✅ CAMBIADO A DRIVING
          "&key=$apiKey";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == "OK" && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final List<LatLng> ruta = _decodePolyline(points);

          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: PolylineId('ruta'),
              color: Color(0xFF3F51B5),
              width: 4,
              patterns: [PatternItem.dash(10), PatternItem.gap(10)],
              points: ruta,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error trazando ruta: $e');
    }

    setState(() => _cargando = false);
  }

  // ✅ DECODIFICAR POLYLINE DE GOOGLE
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        title: const Text('Rutas App'),
        automaticallyImplyLeading: true,
      ),
      drawer: AppDrawer(
        currentRoute: '/home',
        user: {
          'nombre': 'Usuario',
          'correo': 'usuario@email.com',
          'rol': 'visitante',
        },
      ),
      body: Stack(
        children: [
          // ✅ MAPA CON RUTAS DE BUSES
          MapaWidget(
            onMapTap: _onMapTap,
            onUbicacionObtenida: _onUbicacionObtenida,
            markersExternos: _markers,
            polylinesExternos: _polylines,
            rutasBuses: _rutasBuses, // ✅ PASAR RUTAS DE BUSES
          ),

          // ✅ WIDGET PARA CARGAR RUTAS DE BUSES (invisible)
          RutasMapaWidget(
            onRutasCargadas: _onRutasBusesCargadas, // ✅ CALLBACK
          ),

          // ✅ BÚSQUEDA CON CONTROLADORES
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 10,
            right: 10,
            child: BusquedaWidget(
              origenCtrl: _origenCtrl,
              destinoCtrl: _destinoCtrl,
              onSeleccionarOrigen: _activarSeleccionOrigen,
              onSeleccionarDestino: _activarSeleccionDestino,
              onLoadingChange: _onLoadingChange,
              onDireccionEncontrada: _onDireccionEncontrada,
            ),
          ),

          // ✅ INDICADOR DE SELECCIÓN EN MAPA
          if (_seleccionOrigen || _seleccionDestino)
            Positioned(
              top: MediaQuery.of(context).padding.top + 140,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(12),
                color: Colors.orange.withOpacity(0.9),
                child: Text(
                  _seleccionOrigen
                      ? '📍 Toca en el mapa para seleccionar ORIGEN'
                      : '🎯 Toca en el mapa para seleccionar DESTINO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // ✅ BOTONES FLOTANTES
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "btn_buscar_buses",
                  onPressed: _calcularRutas,
                  backgroundColor: _origen != null && _destino != null
                      ? Color(0xFF8BC34A)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.directions_bus),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "btn_mi_ubicacion",
                  onPressed: () {},
                  backgroundColor: Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

          // ✅ LOADING
          if (_cargando)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
              ),
            ),
        ],
      ),
    );
  }
}
