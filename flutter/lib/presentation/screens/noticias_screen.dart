import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rutasfrontend/presentation/screens/crear_noticia_screen.dart';
import '../controllers/noticia_controller.dart';
import '../../data/models/noticia.dart';
import '../widgets/app_drawer.dart';

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  final NoticiaController _controller = Get.put(NoticiaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Noticias',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.fetchNoticias(),
            tooltip: 'Actualizar noticias',
          ),
        ],
      ),
      drawer: AppDrawer(
        currentRoute: '/noticias',
        user: {
          'rol': 'admin',
          'nombre': 'Administrador',
          'correo': 'admin@rutas.com',
        },
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return _buildLoadingState();
        }
        
        if (_controller.noticias.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildNewsList();
      }),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  // 🔹 CORREGIDO: Recibe context como parámetro
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _agregarNoticia(context), // Pasar context aquí
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add, size: 28),
    );
  }

  // 🔹 CORREGIDO: Recibe context como parámetro
  void _agregarNoticia(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearNoticiaScreen()),
    );
  }

  // ... el resto de los métodos permanecen igual
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando noticias...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay noticias',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para crear la primera noticia',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    return Column(
      children: [
        // Header con contador
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Icon(Icons.article, color: Colors.indigo, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_controller.noticias.length} noticia${_controller.noticias.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        
        // Lista de noticias
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.noticias.length,
            itemBuilder: (context, index) {
              final noticia = _controller.noticias[index];
              return _buildNewsCard(noticia, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(Noticia noticia, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _verDetalleNoticia(noticia),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con título y acciones
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen o ícono
                    _buildNewsImage(noticia),
                    
                    const SizedBox(width: 12),
                    
                    // Contenido principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            noticia.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            _formatDate(noticia.fechaPublicacion),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Botones de acción
                    _buildActionButtons(noticia),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Descripción
                Text(
                  noticia.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Separador
                const SizedBox(height: 12),
                Divider(color: Colors.grey[300], height: 1),
                const SizedBox(height: 8),
                
                // Footer con indicador de estado
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: _isRecent(noticia.fechaPublicacion) 
                          ? Colors.green 
                          : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isRecent(noticia.fechaPublicacion) 
                          ? 'Reciente' 
                          : 'Publicada',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsImage(Noticia noticia) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: noticia.imagen.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: noticia.imagen,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    ),
                  ),
                ),
              ),
            )
          : _buildPlaceholderIcon(),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.article,
        size: 30,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildActionButtons(Noticia noticia) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Eliminar'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          _editarNoticia(noticia);
        } else if (value == 'delete') {
          _eliminarNoticia(noticia);
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy a las ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Ayer a las ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _isRecent(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays < 7; // Reciente si es menor a 7 días
  }

  void _editarNoticia(Noticia noticia) {
    // 🔹 CORREGIDO: Usar ScaffoldMessenger en lugar de Get.snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidad de editar noticia en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _eliminarNoticia(Noticia noticia) {
    // 🔹 CORREGIDO: Usar showDialog directo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Noticia',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 50,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              '¿Estás seguro de eliminar "${noticia.nombre}"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.deleteNoticia(noticia.idNoticia);
              Navigator.pop(context);
              // 🔹 CORREGIDO: Usar ScaffoldMessenger
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Noticia eliminada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _verDetalleNoticia(Noticia noticia) {
    showModalBottomSheet(
      context: context, // 🔹 CORREGIDO: Usar context del StatefulWidget
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Detalle de Noticia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (noticia.imagen.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: noticia.imagen,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => 
                                _buildDetailPlaceholder(),
                          ),
                        ),
                      ),
                    
                    Text(
                      noticia.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(Icons.calendar_today, 
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(noticia.fechaPublicacion),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      noticia.descripcion,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Imagen no disponible',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}