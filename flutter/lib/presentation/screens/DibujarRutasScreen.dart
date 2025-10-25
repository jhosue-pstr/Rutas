import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _puntosRuta = [];
  bool _dibujando = false;
  bool _guardando = false;

  // 🔹 Agregar un punto al mapa
  void _agregarPunto(LatLng punto) {
    setState(() {
      _puntosRuta.add(punto);
      _markers.add(
        Marker(
          markerId: MarkerId('punto_${_puntosRuta.length}'),
          position: punto,
          infoWindow: InfoWindow(
            title: 'Punto ${_puntosRuta.length}',
            snippet:
                '${punto.latitude.toStringAsFixed(5)}, ${punto.longitude.toStringAsFixed(5)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _puntosRuta.length % 2 == 0
                ? BitmapDescriptor.hueBlue
                : BitmapDescriptor.hueRed,
          ),
        ),
      );

      _actualizarPolyline();
    });
  }

  // 🔹 Actualizar la línea en el mapa
  void _actualizarPolyline() {
    _polylines = {
      Polyline(
        polylineId: const PolylineId('ruta_dibujada'),
        color: _obtenerColorPolyline(),
        width: 5,
        points: _puntosRuta,
      ),
    };
  }

  // 🔹 Obtener color de la polyline
  Color _obtenerColorPolyline() {
    try {
      return Color(int.parse(_colorCtrl.text.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  // 🔹 Reiniciar el dibujo
  void _reiniciarDibujo() {
    setState(() {
      _puntosRuta.clear();
      _markers.clear();
      _polylines.clear();
      _dibujando = false;
    });
  }

  // 🔹 Mover cámara al último punto
  void _moverCamaraAlUltimoPunto() {
    if (_puntosRuta.isNotEmpty && _mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_puntosRuta.last));
    }
  }

  // 🔹 Guardar la ruta en la base de datos - CORREGIDO
  Future<void> _guardarRuta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_puntosRuta.isEmpty) {
      _mostrarSnackBar('Debes dibujar una ruta en el mapa');
      return;
    }

    setState(() => _guardando = true);

    try {
      // 🔹 1. PRIMERO crear la ruta (sin puntos)
      final rutaCreada = await _rutaController.crearRuta(
        Ruta(
          IdRuta: 0, // Se asignará automáticamente
          nombre: _nombreCtrl.text,
          descripcion: _descripcionCtrl.text.isNotEmpty
              ? _descripcionCtrl.text
              : null,
          color: _colorCtrl.text,
          FechaRegistro: DateTime.now(),
          puntos: [], // Inicialmente vacío
          buses: null,
        ),
      );

      // 🔹 2. LUEGO crear los puntos de ruta con el ID de la ruta creada
      for (int i = 0; i < _puntosRuta.length; i++) {
        final punto = _puntosRuta[i];
        await _puntoRutaController.crearPuntoRuta(
          PuntoRuta(
            IdPunto: 0, // Se asignará automáticamente
            RutaId: rutaCreada.IdRuta, // ID de la ruta recién creada
            latitud: punto.latitude,
            longitud: punto.longitude,
            orden: i + 1, // orden secuencial
          ),
        );
      }

      _mostrarSnackBar(
        '✅ Ruta guardada correctamente con ${_puntosRuta.length} puntos',
      );

      // 🔹 Limpiar todo después de guardar
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

  // 🔹 Mostrar diálogo de confirmación para reiniciar
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
          // 🔹 Formulario superior
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
                          child: TextFormField(
                            controller: _colorCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Color',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.color_lens),
                            ),
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
                      _moverCamaraAlUltimoPunto();
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),

                // 🔹 Indicador de estado
                if (_dibujando)
                  Positioned(
                    top: 10,
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
                            'Modo dibujo - ${_puntosRuta.length} puntos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 🔹 Botones de control
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
