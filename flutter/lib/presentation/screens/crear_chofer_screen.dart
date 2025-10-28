import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/chofer_controller.dart';

class CrearChoferScreen extends StatefulWidget {
  const CrearChoferScreen({super.key});

  @override
  State<CrearChoferScreen> createState() => _CrearChoferScreenState();
}

class _CrearChoferScreenState extends State<CrearChoferScreen> {
  final ChoferController _controller = Get.find<ChoferController>();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _dniCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  
  File? _fotoFile;
  File? _qrPagoFile;
  File? _licenciaImgFile;
  bool _estado = true;
  bool _guardando = false;

  Future<void> _seleccionarImagen(ImageSource source, {String tipo = 'foto'}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );
      
      if (pickedFile != null) {
        setState(() {
          switch (tipo) {
            case 'foto':
              _fotoFile = File(pickedFile.path);
              break;
            case 'qr_pago':
              _qrPagoFile = File(pickedFile.path);
              break;
            case 'licencia':
              _licenciaImgFile = File(pickedFile.path);
              break;
          }
        });
      }
    } catch (e) {
      _mostrarError('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _guardarChofer() async {
    if (!_formKey.currentState!.validate()) {
      _mostrarError('Por favor complete los campos requeridos');
      return;
    }

    if (_fotoFile == null) {
      _mostrarError('Por favor seleccione una foto del chofer');
      return;
    }

    setState(() => _guardando = true);

    try {
      await _controller.createChofer(
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim().isNotEmpty ? _apellidoCtrl.text.trim() : null,
        dni: _dniCtrl.text.trim().isNotEmpty ? _dniCtrl.text.trim() : null,
        telefono: _telefonoCtrl.text.trim().isNotEmpty ? _telefonoCtrl.text.trim() : null,
        foto: _fotoFile,
        qrPago: _qrPagoFile,
        licenciaImg: _licenciaImgFile,
      );

      _mostrarExito('Chofer creado correctamente');
      
      // Limpiar formulario
      _formKey.currentState!.reset();
      setState(() {
        _fotoFile = null;
        _qrPagoFile = null;
        _licenciaImgFile = null;
        _estado = true;
      });

      // Regresar después de un breve delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.pop(context);
      });
      
    } catch (e) {
      _mostrarError('Error al crear chofer: $e');
    } finally {
      setState(() => _guardando = false);
    }
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildImageSelector(String titulo, File? archivo, String tipo) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            
            if (archivo != null)
              Column(
                children: [
                  Image.file(
                    archivo,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    archivo.path.split('/').last,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo, size: 40, color: Colors.grey),
              ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarImagen(ImageSource.gallery, tipo: tipo),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarImagen(ImageSource.camera, tipo: tipo),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Chofer'),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_guardando)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _guardarChofer,
              tooltip: 'Guardar chofer',
            ),
        ],
      ),
      body: _guardando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Foto del chofer (requerida)
                    _buildImageSelector('Foto del Chofer *', _fotoFile, 'foto'),
                    
                    const SizedBox(height: 20),

                    // QR de Pago (opcional)
                    _buildImageSelector('QR de Pago (opcional)', _qrPagoFile, 'qr_pago'),
                    
                    const SizedBox(height: 20),

                    // Licencia (opcional)
                    _buildImageSelector('Licencia de Conducir (opcional)', _licenciaImgFile, 'licencia'),
                    
                    const SizedBox(height: 20),

                    // Campos del formulario
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Nombre
                            TextFormField(
                              controller: _nombreCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nombre *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre es obligatorio';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Apellido
                            TextFormField(
                              controller: _apellidoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Apellido',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // DNI
                            TextFormField(
                              controller: _dniCtrl,
                              decoration: const InputDecoration(
                                labelText: 'DNI',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            // Teléfono
                            TextFormField(
                              controller: _telefonoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            // Estado
                            SwitchListTile(
                              title: const Text('Estado Activo'),
                              value: _estado,
                              onChanged: (value) {
                                setState(() {
                                  _estado = value;
                                });
                              },
                              secondary: Icon(
                                _estado ? Icons.check_circle : Icons.remove_circle,
                                color: _estado ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón guardar
                    ElevatedButton(
                      onPressed: _guardando ? null : _guardarChofer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Guardar Chofer',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _dniCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }
}