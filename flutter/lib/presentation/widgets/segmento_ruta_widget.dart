// // lib/presentation/widgets/segmento_ruta_widget.dart
// import 'package:flutter/material.dart';
// import 'package:rutasfrontend/data/services/segmento_ruta.dart';

// class SegmentoRutaWidget extends StatelessWidget {
//   final SegmentoRuta segmento;
//   final int numero;
//   final bool esUltimo;

//   const SegmentoRutaWidget({
//     super.key,
//     required this.segmento,
//     required this.numero,
//     this.esUltimo = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Línea vertical y número
//           _buildLineaVertical(),

//           // Contenido del segmento
//           Expanded(child: _buildContenidoSegmento()),
//         ],
//       ),
//     );
//   }

//   Widget _buildLineaVertical() {
//     return Column(
//       children: [
//         // Icono del segmento
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: _getColorSegmento(),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(_getIconSegmento(), color: Colors.white, size: 18),
//         ),

//         // Línea vertical (excepto para el último)
//         if (!esUltimo) Container(width: 2, height: 40, color: Colors.grey[300]),
//       ],
//     );
//   }

//   Widget _buildContenidoSegmento() {
//     return Container(
//       // ✅ CORRECCIÓN: Quitar 'const' porque bottom es dinámico
//       margin: EdgeInsets.only(left: 12, bottom: esUltimo ? 0 : 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Instrucción principal
//           Text(
//             '$numero. ${segmento.instruccion}',
//             style: const TextStyle(fontWeight: FontWeight.w500),
//           ),

//           const SizedBox(height: 4),

//           // Detalles (tiempo y distancia)
//           Row(
//             children: [
//               Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
//               const SizedBox(width: 4),
//               Text(
//                 '${segmento.tiempoEstimado} min',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//               ),
//               const SizedBox(width: 12),
//               Icon(Icons.alt_route, size: 12, color: Colors.grey[600]),
//               const SizedBox(width: 4),
//               Text(
//                 '${segmento.distancia.toStringAsFixed(1)} km',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//               ),
//             ],
//           ),

//           // Información adicional del bus
//           if (segmento.esBus && segmento.ruta != null) _buildInfoBus(),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoBus() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: BoxDecoration(
//             color: Colors.blue[100],
//             borderRadius: BorderRadius.circular(4),
//           ),
//           child: Text(
//             'Línea ${segmento.ruta!.nombre}',
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue[800],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getColorSegmento() {
//     if (segmento.esBus) return Colors.blue;
//     if (segmento.esCaminando) return Colors.green;
//     return Colors.grey;
//   }

//   IconData _getIconSegmento() {
//     if (segmento.esBus) return Icons.directions_bus;
//     if (segmento.esCaminando) return Icons.directions_walk;
//     return Icons.help;
//   }
// }

// lib/presentation/widgets/segmento_ruta_widget.dart
import 'package:flutter/material.dart';
import 'package:rutasfrontend/data/services/segmento_ruta.dart';

class SegmentoRutaWidget extends StatelessWidget {
  final SegmentoRuta segmento;
  final int numero;
  final bool esUltimo;

  const SegmentoRutaWidget({
    super.key,
    required this.segmento,
    required this.numero,
    this.esUltimo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea vertical con puntos
          _buildLineaVerticalPunteada(),

          // Contenido del segmento
          Expanded(child: _buildContenidoSegmento()),
        ],
      ),
    );
  }

  Widget _buildLineaVerticalPunteada() {
    return Column(
      children: [
        // Icono del segmento
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _getColorSegmento(),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(_getIconSegmento(), color: Colors.white, size: 18),
        ),

        // Línea vertical PUNTEADA (excepto para el último)
        if (!esUltimo) _buildLineaPunteada(),
      ],
    );
  }

  Widget _buildLineaPunteada() {
    return Container(
      width: 2,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getColorSegmento().withOpacity(0.6),
            _getColorSegmento().withOpacity(0.2),
          ],
          stops: const [0.0, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomPaint(
        painter: _LineaPunteadaPainter(color: _getColorSegmento()),
      ),
    );
  }

  Widget _buildContenidoSegmento() {
    return Container(
      // ✅ CORREGIDO: Quitar 'const' porque bottom es dinámico
      margin: EdgeInsets.only(left: 12, bottom: esUltimo ? 0 : 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instrucción principal
          Text(
            '$numero. ${segmento.instruccion}',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),

          const SizedBox(height: 6),

          // Detalles (tiempo y distancia)
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${segmento.tiempoEstimado} min',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.alt_route, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${segmento.distancia.toStringAsFixed(1)} km',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Información adicional del bus
          if (segmento.esBus && segmento.ruta != null) _buildInfoBus(),

          // Indicador de tipo de segmento
          const SizedBox(height: 4),
          _buildTipoSegmento(),
        ],
      ),
    );
  }

  Widget _buildInfoBus() {
    final colorRuta = _hexToColor(segmento.ruta!.color ?? '#3F51B5');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorRuta.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colorRuta.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_bus, size: 12, color: colorRuta),
              const SizedBox(width: 4),
              Text(
                'Línea ${segmento.ruta!.nombre}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorRuta,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipoSegmento() {
    final color = _getColorSegmento();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          segmento.esBus ? 'Viaje en bus' : 'Caminando',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ✅ CORREGIDO: Color diferenciado
  Color _getColorSegmento() {
    if (segmento.esBus) {
      return _hexToColor(segmento.ruta?.color ?? '#3F51B5'); // Color de la BD
    }
    if (segmento.esCaminando) return Colors.green; // Verde para caminar
    return Colors.grey;
  }

  IconData _getIconSegmento() {
    if (segmento.esBus) return Icons.directions_bus;
    if (segmento.esCaminando) return Icons.directions_walk;
    return Icons.help;
  }

  // ✅ NUEVO: Método para convertir hex a color
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

// ✅ NUEVO: Painter para línea punteada
class _LineaPunteadaPainter extends CustomPainter {
  final Color color;

  _LineaPunteadaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dashWidth = 3.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
