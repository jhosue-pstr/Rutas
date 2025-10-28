import 'package:flutter/material.dart';
import 'package:rutasfrontend/data/models/bus_favorito.dart';
import 'package:rutasfrontend/presentation/controllers/bus_favorito_controller.dart';

class BusFavoritoScreen extends StatefulWidget {
  final String? token;
  final Map<String, dynamic>? user;

  const BusFavoritoScreen({Key? key, this.token, this.user}) : super(key: key);

  @override
  State<BusFavoritoScreen> createState() => _BusFavoritoScreenState();
}

class _BusFavoritoScreenState extends State<BusFavoritoScreen> {
  List<BusFavorito> _busesFavoritos = [];
  bool _cargando = false;
  late BusFavoritoController _controller;
  String? _error;

  final TextEditingController _idBusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = BusFavoritoController(widget.token);
    _cargarBusesFavoritos();
  }

  Future<void> _cargarBusesFavoritos() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final usuarioId = widget.user?['IdUsuario'] ?? 0;
      print('🔄 Cargando buses favoritos para usuario: $usuarioId');

      final buses = await _controller.obtenerBusesFavoritosPorUsuario(
        usuarioId,
      );

      if (!mounted) return;

      setState(() {
        _busesFavoritos = buses;
        print('✅ Buses cargados: ${buses.length}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
      _mostrarError('Error al cargar buses favoritos: $e');
      print('❌ Error cargando buses: $e');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _agregarBusFavorito() async {
    if (_idBusController.text.isEmpty) {
      _mostrarError('Por favor ingresa el ID del bus');
      return;
    }

    final idBus = int.tryParse(_idBusController.text);
    if (idBus == null) {
      _mostrarError('Por favor ingresa un ID de bus válido');
      return;
    }

    try {
      final usuarioId = widget.user?['IdUsuario'] ?? 0;

      final nuevoBus = BusFavoritoCreate(idBus: idBus, idUsuario: usuarioId);

      await _controller.agregarBusFavorito(nuevoBus);
      _idBusController.clear();

      _cargarBusesFavoritos();
      _mostrarExito('Bus agregado a favoritos');
    } catch (e) {
      _mostrarError('Error al agregar bus favorito: $e');
    }
  }

  Future<void> _eliminarBusFavorito(int id) async {
    try {
      await _controller.eliminarBusFavorito(id);
      _cargarBusesFavoritos();
      _mostrarExito('Bus eliminado de favoritos');
    } catch (e) {
      _mostrarError('Error al eliminar bus favorito: $e');
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

  Widget _buildBody() {
    if (_cargando) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando buses favoritos...',
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
            SizedBox(height: 16),
            Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF424242),
              ),
            ),
            SizedBox(height: 8),
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarBusesFavoritos,
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

    return _busesFavoritos.isEmpty ? _buildVacio() : _buildListaBuses();
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
              color: const Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF9C27B0).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.directions_bus_outlined,
              size: 70,
              color: const Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tienes buses favoritos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Agrega tus buses preferidos para\nacceder rápidamente a ellos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF424242).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _mostrarDialogoAgregarBus,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              'Agregar Primer Bus',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaBuses() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _busesFavoritos.length,
      itemBuilder: (context, index) {
        final bus = _busesFavoritos[index];
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
                // Acción al tocar el bus
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // ÍCONO DEL BUS
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_bus_rounded,
                        size: 32,
                        color: const Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // INFORMACIÓN DEL BUS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bus.nombreBus,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_number,
                                size: 16,
                                color: const Color(0xFF3F51B5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ID Bus: ${bus.idBus}',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF424242,
                                  ).withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID Favorito: ${bus.idBusFavorito}',
                            style: TextStyle(
                              color: const Color(0xFF424242).withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BOTÓN ELIMINAR
                    IconButton(
                      onPressed: () => _mostrarDialogoEliminar(bus.id),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: const Color(0xFFE91E63),
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

  void _mostrarDialogoAgregarBus() {
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
              // ENCABEZADO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  size: 40,
                  color: const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Agregar Bus Favorito',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 20),

              // FORMULARIO SIMPLIFICADO (solo ID del bus)
              TextField(
                controller: _idBusController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ID del Bus',
                  labelStyle: TextStyle(color: const Color(0xFF424242)),
                  hintText: 'Ingresa el ID numérico del bus',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFF9C27B0)),
                  ),
                  prefixIcon: Icon(
                    Icons.confirmation_number,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nota: Solo necesitas el ID del bus que quieres agregar a favoritos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF424242).withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // BOTONES
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
                        _agregarBusFavorito();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
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
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Eliminar Bus Favorito',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '¿Estás seguro de que quieres eliminar este bus de tus favoritos?',
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
                        _eliminarBusFavorito(id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: Text(
          'Mis Buses Favoritos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (_busesFavoritos.isNotEmpty)
            IconButton(
              icon: Icon(Icons.add, size: 24),
              onPressed: _mostrarDialogoAgregarBus,
              tooltip: 'Agregar bus favorito',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _busesFavoritos.isNotEmpty
          ? FloatingActionButton(
              onPressed: _mostrarDialogoAgregarBus,
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
