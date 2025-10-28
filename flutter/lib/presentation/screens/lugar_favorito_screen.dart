// lib/presentation/screens/lugar_favorito_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/lugar_favorito.dart';
import '../../presentation/controllers/lugar_favorito_controller.dart';

class LugarFavoritoScreen extends StatefulWidget {
  final String? token;
  final Map<String, dynamic>? user;

  const LugarFavoritoScreen({Key? key, this.token, this.user})
    : super(key: key);

  @override
  State<LugarFavoritoScreen> createState() => _LugarFavoritoScreenState();
}

class _LugarFavoritoScreenState extends State<LugarFavoritoScreen> {
  List<LugarFavorito> _lugaresFavoritos = [];
  bool _cargando = false;
  late LugarFavoritoController _controller;
  String? _error;

  // Controladores para el formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Variables para el mapa
  GoogleMapController? _mapController;
  double _zoomLevel = 12.0;
  LatLng _ubicacionActual = const LatLng(-17.3895, -66.1568);
  LatLng? _ubicacionSeleccionada;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _controller = LugarFavoritoController(widget.token);
    _cargarLugaresFavoritos();
    _agregarMarcadorInicial();
  }

  void _agregarMarcadorInicial() {
    _markers.add(
      Marker(
        markerId: const MarkerId('ubicacion_actual'),
        position: _ubicacionActual,
        infoWindow: const InfoWindow(title: 'Ubicación Actual'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  Future<void> _cargarLugaresFavoritos() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final usuarioId = widget.user?['IdUsuario'] ?? 0;
      final lugares = await _controller.obtenerLugaresFavoritosPorUsuario(
        usuarioId,
      );

      if (!mounted) return;

      setState(() {
        _lugaresFavoritos = lugares;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
      _mostrarError('Error al cargar lugares favoritos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _ubicacionSeleccionada = location;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('ubicacion_seleccionada'),
          position: location,
          infoWindow: InfoWindow(
            title: 'Ubicación Seleccionada',
            snippet:
                'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    });
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
    setState(() {
      _zoomLevel += 1.0;
    });
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
    setState(() {
      _zoomLevel -= 1.0;
    });
  }

  void _resetZoom() {
    _mapController?.animateCamera(CameraUpdate.zoomTo(12.0));
    setState(() {
      _zoomLevel = 12.0;
    });
  }

  void _goToMyLocation() {
    _mapController?.animateCamera(CameraUpdate.newLatLng(_ubicacionActual));
  }

  Future<void> _agregarLugarFavorito() async {
    if (_nombreController.text.isEmpty) {
      _mostrarError('Por favor ingresa un nombre para el lugar');
      return;
    }

    if (_ubicacionSeleccionada == null) {
      _mostrarError('Por favor selecciona una ubicación en el mapa');
      return;
    }

    try {
      final usuarioId = widget.user?['IdUsuario'] ?? 0;
      final nuevoLugar = LugarFavoritoCreate(
        nombre: _nombreController.text,
        latitud: _ubicacionSeleccionada!.latitude,
        longitud: _ubicacionSeleccionada!.longitude,
        descripcion: _descripcionController.text.isEmpty
            ? null
            : _descripcionController.text,
        color: "#2196F3",
        idUsuario: usuarioId,
      );

      await _controller.agregarLugarFavorito(nuevoLugar);
      _nombreController.clear();
      _descripcionController.clear();
      setState(() {
        _ubicacionSeleccionada = null;
        _agregarMarcadorInicial();
      });
      _cargarLugaresFavoritos();
      _mostrarExito('Lugar agregado a favoritos');
    } catch (e) {
      _mostrarError('Error al agregar lugar favorito: $e');
    }
  }

  Future<void> _eliminarLugarFavorito(int id) async {
    try {
      await _controller.eliminarLugarFavorito(id);
      _cargarLugaresFavoritos();
      _mostrarExito('Lugar eliminado de favoritos');
    } catch (e) {
      _mostrarError('Error al eliminar lugar favorito: $e');
    }
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFF8BC34A),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFFFF9800),
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2196F3).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 70,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tienes lugares favoritos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Agrega tus lugares preferidos para\nacceder rápidamente a ellos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF424242).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _mostrarDialogoAgregarLugar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              'Agregar Primer Lugar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaLugares() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lugaresFavoritos.length,
      itemBuilder: (context, index) {
        final lugar = _lugaresFavoritos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(lugar.latitud, lugar.longitud),
                    14.0,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 32,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lugar.nombre,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (lugar.descripcion != null) ...[
                            Text(
                              lugar.descripcion!,
                              style: TextStyle(
                                color: const Color(0xFF424242).withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                          ],
                          Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                size: 14,
                                color: const Color(0xFF3F51B5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${lugar.latitud.toStringAsFixed(4)}, ${lugar.longitud.toStringAsFixed(4)}',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF424242,
                                  ).withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _mostrarDialogoEliminar(lugar.id),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: const Color(0xFFFF9800),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapa() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4, // 40% de la pantalla
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _ubicacionActual,
                zoom: _zoomLevel,
              ),
              markers: _markers,
              onTap: _onMapTap,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // Desactivamos el botón nativo
              zoomControlsEnabled: false, // Desactivamos controles nativos
              compassEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
            ),
          ),

          // CONTROLES DE ZOOM PERSONALIZADOS
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                // BOTÓN ZOOM IN
                _buildBotonControl(
                  icon: Icons.add,
                  onTap: _zoomIn,
                  color: const Color(0xFF2196F3),
                  tooltip: 'Acercar',
                ),
                const SizedBox(height: 8),
                // BOTÓN ZOOM OUT
                _buildBotonControl(
                  icon: Icons.remove,
                  onTap: _zoomOut,
                  color: const Color(0xFF2196F3),
                  tooltip: 'Alejar',
                ),
                const SizedBox(height: 8),
                // BOTÓN RESET ZOOM
                _buildBotonControl(
                  icon: Icons.center_focus_strong,
                  onTap: _resetZoom,
                  color: const Color(0xFF3F51B5),
                  tooltip: 'Zoom por defecto',
                ),
              ],
            ),
          ),

          // BOTÓN MI UBICACIÓN
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildBotonControl(
              icon: Icons.my_location,
              onTap: _goToMyLocation,
              color: const Color(0xFF8BC34A),
              tooltip: 'Mi ubicación',
            ),
          ),

          // INDICADOR DE ZOOM
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.zoom_in_map,
                    size: 16,
                    color: const Color(0xFF424242),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Zoom: ${_zoomLevel.toStringAsFixed(1)}x',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF424242),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonControl({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarLugar() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_location_alt_rounded,
                  size: 40,
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Agregar Lugar Favorito',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del lugar *',
                  labelStyle: TextStyle(color: const Color(0xFF424242)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFF2196F3)),
                  ),
                  prefixIcon: Icon(Icons.place, color: const Color(0xFF2196F3)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  labelStyle: TextStyle(color: const Color(0xFF424242)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFF2196F3)),
                  ),
                  prefixIcon: Icon(
                    Icons.description,
                    color: const Color(0xFF3F51B5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8BC34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8BC34A).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF8BC34A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _ubicacionSeleccionada == null
                            ? 'Toca en el mapa para seleccionar ubicación'
                            : 'Ubicación seleccionada: ${_ubicacionSeleccionada!.latitude.toStringAsFixed(4)}, ${_ubicacionSeleccionada!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: const Color(0xFF424242),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF424242),
                        side: BorderSide(color: const Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _agregarLugarFavorito();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                      ),
                      child: Text('Agregar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar(int id) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 40,
                  color: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Eliminar Lugar Favorito',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '¿Estás seguro de que quieres eliminar este lugar de tus favoritos?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF424242).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF424242),
                        side: BorderSide(color: const Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _eliminarLugarFavorito(id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando lugares favoritos...',
              style: TextStyle(color: const Color(0xFF424242), fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: const Color(0xFFFF9800)),
            const SizedBox(height: 16),
            Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF424242).withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarLugaresFavoritos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
              ),
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildMapa(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.favorite, color: const Color(0xFFE91E63), size: 20),
              const SizedBox(width: 8),
              Text(
                'Mis Lugares Favoritos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF424242),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _lugaresFavoritos.isEmpty
              ? _buildVacio()
              : _buildListaLugares(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: Text(
          'Mis Lugares Favoritos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (_lugaresFavoritos.isNotEmpty)
            IconButton(
              icon: Icon(Icons.add, size: 24),
              onPressed: _mostrarDialogoAgregarLugar,
              tooltip: 'Agregar lugar favorito',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _lugaresFavoritos.isNotEmpty
          ? FloatingActionButton(
              onPressed: _mostrarDialogoAgregarLugar,
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
