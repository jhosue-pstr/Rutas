import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rutasfrontend/presentation/controllers/bus_controller.dart';
import 'package:rutasfrontend/presentation/widgets/detalle_ruta_widget.dart';
import 'package:rutasfrontend/presentation/widgets/rutas_mapa_widget.dart';
import 'dart:convert';
import '../widgets/app_drawer.dart';
import '../widgets/mapa_widget.dart';
import '../widgets/busqueda_widget.dart';
import '../widgets/resultados_ruta_widget.dart';

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
  Set<Polyline> _rutasBuses = {};

  bool _mostrandoRutasBuses = false;
  dynamic _resultadoRutas;

  final TextEditingController _origenCtrl = TextEditingController();
  final TextEditingController _destinoCtrl = TextEditingController();
  final BusControllerMejorado _busController = BusControllerMejorado();

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

  void _actualizarMarcadores() {
    _markers.clear();

    if (_origen != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('origen'),
          position: _origen!,
          infoWindow: const InfoWindow(title: 'Origen'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (_destino != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destino'),
          position: _destino!,
          infoWindow: const InfoWindow(title: 'Destino'),
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

  // ✅ CALCULAR RUTAS DE BUSES MEJORADO
  Future<void> _calcularRutasBuses() async {
    if (_origen == null || _destino == null) {
      _mostrarSnackbar('Selecciona origen y destino primero');
      return;
    }

    setState(() => _cargando = true);

    try {
      print('🚀 Calculando rutas de buses...');

      final resultado = await _busController.calcularMejorRuta(
        _origen!,
        _destino!,
      );

      setState(() {
        _resultadoRutas = resultado;
        _mostrandoRutasBuses = true;
      });

      // ✅ MOSTRAR RESULTADOS EN MODAL
      _mostrarResultadosRutas(resultado);
    } catch (e, stackTrace) {
      print('❌ Error calculando rutas: $e');
      print('Stack trace: $stackTrace');
      _mostrarSnackbar('Error calculando rutas: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _mostrarResultadosRutas(dynamic resultado) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultadosRutaWidget(
          resultado: resultado,
          onVolver: () {
            Navigator.pop(context);
            setState(() {
              _mostrandoRutasBuses = false;
              _rutasBuses.clear();
            });
          },
          onVerDetalle: (ruta) {
            Navigator.pop(context); // Cierra resultados
            _mostrarDetalleRuta(ruta);
          },
          onVerEnMapa: (ruta) {
            Navigator.pop(context); // Cierra resultados
            _mostrarRutaEnMapa(ruta);
          },
        ),
      ),
    );
  }

  // ✅ MOSTRAR DETALLE DE RUTA
  void _mostrarDetalleRuta(dynamic ruta) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetalleRutaWidget(ruta: ruta)),
    );
  }

  // ✅ MOSTRAR RUTA EN MAPA
  void _mostrarRutaEnMapa(dynamic ruta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapaRutaWidget(rutaEspecifica: ruta),
      ),
    );
  }

  // ✅ MOSTRAR TODAS LAS RUTAS DEL SISTEMA
  void _mostrarTodasLasRutas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapaRutaWidget(mostrarTodasLasRutas: true),
      ),
    );
  }

  // ✅ SNACKBAR HELPER
  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
    );
  }

  // ✅ LIMPIAR TODO
  void _limpiarRutas() {
    setState(() {
      _polylines.clear();
      _rutasBuses.clear();
      _mostrandoRutasBuses = false;
      _resultadoRutas = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        title: const Text('Rutas App'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _mostrarTodasLasRutas,
            tooltip: 'Ver todas las rutas',
          ),
        ],
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
          // ✅ MAPA PRINCIPAL
          MapaWidget(
            onMapTap: _onMapTap,
            onUbicacionObtenida: _onUbicacionObtenida,
            markersExternos: _markers,
            polylinesExternos: _polylines,
            rutasBuses: _rutasBuses,
          ),

          // ✅ BÚSQUEDA
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
                padding: const EdgeInsets.all(12),
                color: Colors.orange.withOpacity(0.9),
                child: Text(
                  _seleccionOrigen
                      ? '📍 Toca en el mapa para seleccionar ORIGEN'
                      : '🎯 Toca en el mapa para seleccionar DESTINO',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // ✅ BOTONES FLOTANTES MEJORADOS
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                // BOTÓN BUSCAR RUTAS DE BUSES
                FloatingActionButton(
                  heroTag: "btn_buscar_buses",
                  onPressed: _calcularRutasBuses,
                  backgroundColor: _origen != null && _destino != null
                      ? const Color(0xFF8BC34A)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.directions_bus),
                ),
                const SizedBox(height: 10),

                // BOTÓN LIMPIAR RUTAS
                if (_mostrandoRutasBuses || _polylines.isNotEmpty)
                  FloatingActionButton(
                    heroTag: "btn_limpiar",
                    onPressed: _limpiarRutas,
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    mini: true,
                    child: const Icon(Icons.clear),
                  ),

                if (_mostrandoRutasBuses || _polylines.isNotEmpty)
                  const SizedBox(height: 10),

                // BOTÓN MI UBICACIÓN
                FloatingActionButton(
                  heroTag: "btn_mi_ubicacion",
                  onPressed: () {},
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

          // ✅ INDICADOR DE RUTAS ACTIVAS
          if (_mostrandoRutasBuses)
            Positioned(
              bottom: 150,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Rutas de buses activas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ✅ LOADING
          if (_cargando)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
              ),
            ),
        ],
      ),
    );
  }
}
