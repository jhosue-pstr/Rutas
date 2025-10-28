import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/noticia_controller.dart';

class CrearNoticiaScreen extends StatefulWidget {
  const CrearNoticiaScreen({super.key});

  @override
  State<CrearNoticiaScreen> createState() => _CrearNoticiaScreenState();
}

class _CrearNoticiaScreenState extends State<CrearNoticiaScreen> {
  final NoticiaController _controller = Get.find<NoticiaController>();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  
  File? _imagenFile;
  bool _guardando = false;

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imagenFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _mostrarError('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _guardarNoticia() async {
    if (!_formKey.currentState!.validate()) {
      _mostrarError('Por favor complete los campos requeridos');
      return;
    }

    if (_imagenFile == null) {
      _mostrarError('Por favor seleccione una imagen para la noticia');
      return;
    }

    setState(() => _guardando = true);

    try {
      await _controller.createNoticia(
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        imagen: _imagenFile!,
      );

      _mostrarExito('Noticia creada correctamente');
      
      // Limpiar formulario
      _formKey.currentState!.reset();
      setState(() {
        _imagenFile = null;
      });

      // Regresar después de un breve delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.pop(context);
      });
      
    } catch (e) {
      _mostrarError('Error al crear noticia: $e');
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

  Widget _buildImageSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Imagen de la Noticia *',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_imagenFile != null)
              Column(
                children: [
                  Image.file(
                    _imagenFile!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _imagenFile!.path.split('/').last,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Seleccionar imagen'),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarImagen(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarImagen(ImageSource.camera),
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
        title: const Text('Crear Noticia'),
        backgroundColor: Colors.indigo,
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
              onPressed: _guardarNoticia,
              tooltip: 'Guardar noticia',
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
                    // Selector de imagen
                    _buildImageSelector(),
                    
                    const SizedBox(height: 20),

                    // Campos del formulario
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Título
                            TextFormField(
                              controller: _nombreCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Título *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.title),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El título es obligatorio';
                                }
                                if (value.trim().length < 5) {
                                  return 'El título debe tener al menos 5 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Descripción
                            TextFormField(
                              controller: _descripcionCtrl,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Descripción *',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'La descripción es obligatoria';
                                }
                                if (value.trim().length < 10) {
                                  return 'La descripción debe tener al menos 10 caracteres';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón guardar
                    ElevatedButton(
                      onPressed: _guardando ? null : _guardarNoticia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
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
                              'Publicar Noticia',
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
    _descripcionCtrl.dispose();
    super.dispose();
  }
}