import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rutasfrontend/presentation/screens/crear_chofer_screen.dart';
import '../controllers/chofer_controller.dart';
import '../../data/models/chofer.dart';
import '../widgets/app_drawer.dart';

class ChoferScreen extends StatefulWidget {
  const ChoferScreen({super.key});

  @override
  State<ChoferScreen> createState() => _ChoferScreenState();
}

class _ChoferScreenState extends State<ChoferScreen> {
  final ChoferController _controller = Get.put(ChoferController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Choferes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.fetchChoferes(),
            tooltip: 'Actualizar choferes',
          ),
        ],
      ),
      drawer: AppDrawer(
        currentRoute: '/choferes',
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
        
        if (_controller.choferes.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildDriversList();
      }),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  // 🔹 CORREGIDO: Recibe context como parámetro
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _agregarChofer(context), // Pasar context aquí
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add, size: 28),
    );
  }

  // 🔹 CORREGIDO: Recibe context como parámetro
  void _agregarChofer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearChoferScreen()),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando choferes...',
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
            Icons.drive_eta_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay choferes registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar el primer chofer',
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

  Widget _buildDriversList() {
    return Column(
      children: [
        // Header con estadísticas
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Icon(Icons.drive_eta, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_controller.choferes.length} chofer${_controller.choferes.length != 1 ? 'es' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              _buildActiveDriversCount(),
            ],
          ),
        ),
        
        // Lista de choferes
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.choferes.length,
            itemBuilder: (context, index) {
              final chofer = _controller.choferes[index];
              return _buildDriverCard(chofer, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDriversCount() {
    final activeCount = _controller.choferes.where((c) => c.estado).length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          '$activeCount activos',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(Chofer chofer, int index) {
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
          onTap: () => _verDetalleChofer(chofer),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar del chofer
                _buildDriverAvatar(chofer),
                
                const SizedBox(width: 12),
                
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${chofer.nombre} ${chofer.apellido ?? ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(chofer.estado),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Información de contacto
                      _buildContactInfo(chofer),
                      
                      const SizedBox(height: 8),
                      
                      // Información adicional
                      _buildAdditionalInfo(chofer),
                    ],
                  ),
                ),
                
                // Botones de acción
                _buildActionButtons(chofer),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverAvatar(Chofer chofer) {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: chofer.estado ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: chofer.fotoUrl != null && chofer.fotoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: chofer.fotoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => _buildPlaceholderAvatar(chofer),
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        ),
                      ),
                    ),
                  )
                : _buildPlaceholderAvatar(chofer),
          ),
        ),
        if (chofer.estado)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderAvatar(Chofer chofer) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.person,
          size: 30,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: estado ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: estado ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Text(
        estado ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: estado ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildContactInfo(Chofer chofer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chofer.telefono != null && chofer.telefono!.isNotEmpty)
          Row(
            children: [
              Icon(Icons.phone, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                chofer.telefono!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        
        if (chofer.dni != null && chofer.dni!.isNotEmpty)
          Row(
            children: [
              Icon(Icons.badge, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'DNI: ${chofer.dni!}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAdditionalInfo(Chofer chofer) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (chofer.licenciaConducir != null && chofer.licenciaConducir!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car, size: 12, color: Colors.blue),
                const SizedBox(width: 2),
                Text(
                  'Licencia',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.orange),
              const SizedBox(width: 2),
              Text(
                _formatDate(chofer.fechaIngreso),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Chofer chofer) {
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
          _editarChofer(chofer);
        } else if (value == 'delete') {
          _eliminarChofer(chofer);
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 30) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _editarChofer(Chofer chofer) {
    // 🔹 CORREGIDO: Usar ScaffoldMessenger en lugar de Get.snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidad de editar chofer en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _eliminarChofer(Chofer chofer) {
    // 🔹 CORREGIDO: Usar showDialog directo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Chofer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off_rounded,
              size: 50,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              '¿Estás seguro de eliminar a ${chofer.nombre}?',
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
              _controller.deleteChofer(chofer.idChofer);
              Navigator.pop(context);
              // 🔹 CORREGIDO: Usar ScaffoldMessenger
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chofer eliminado correctamente'),
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

  void _verDetalleChofer(Chofer chofer) {
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
                color: Colors.deepPurple,
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
                    'Detalle del Chofer',
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar grande
                    Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: chofer.estado ? Colors.green : Colors.grey,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: chofer.fotoUrl != null && chofer.fotoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: chofer.fotoUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => 
                                    _buildDetailPlaceholder(),
                              )
                            : _buildDetailPlaceholder(),
                      ),
                    ),
                    
                    // Nombre
                    Text(
                      '${chofer.nombre} ${chofer.apellido ?? ''}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Estado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: chofer.estado ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: chofer.estado ? Colors.green : Colors.grey,
                        ),
                      ),
                      child: Text(
                        chofer.estado ? 'ACTIVO' : 'INACTIVO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: chofer.estado ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Información personal
                    _buildDetailSection(
                      title: 'Información Personal',
                      children: [
                        _buildDetailItem('DNI', chofer.dni ?? 'No especificado'),
                        _buildDetailItem('Teléfono', chofer.telefono ?? 'No especificado'),
                        _buildDetailItem('Licencia', chofer.licenciaConducir ?? 'No especificada'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Información laboral
                    _buildDetailSection(
                      title: 'Información Laboral',
                      children: [
                        _buildDetailItem('Fecha de Ingreso', 
                            '${chofer.fechaIngreso.day}/${chofer.fechaIngreso.month}/${chofer.fechaIngreso.year}'),
                        _buildDetailItem('Tiempo en la empresa', 
                            _calculateTimeInCompany(chofer.fechaIngreso)),
                      ],
                    ),
                    
                    if (chofer.qrPagoUrl != null && chofer.qrPagoUrl!.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            title: 'QR de Pago',
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: chofer.qrPagoUrl!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ],
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
        child: Icon(
          Icons.person,
          size: 50,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildDetailSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTimeInCompany(DateTime fechaIngreso) {
    final now = DateTime.now();
    final difference = now.difference(fechaIngreso);
    
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return '$years año${years != 1 ? 's' : ''} ${months > 0 ? 'y $months mes${months != 1 ? 'es' : ''}' : ''}';
    } else if (months > 0) {
      return '$months mes${months != 1 ? 'es' : ''}';
    } else {
      return '${difference.inDays} día${difference.inDays != 1 ? 's' : ''}';
    }
  }
}