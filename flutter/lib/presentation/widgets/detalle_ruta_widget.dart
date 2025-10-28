// lib/presentation/widgets/detalle_ruta_widget.dart
import 'package:flutter/material.dart';
import 'package:rutasfrontend/data/services/ruta_completa.dart';
import 'package:rutasfrontend/presentation/widgets/segmento_ruta_widget.dart';

class DetalleRutaWidget extends StatelessWidget {
  final RutaCompleta ruta;

  const DetalleRutaWidget({super.key, required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Ruta')),
      body: Column(
        children: [
          // Header resumen
          _buildHeaderResumen(),

          // Lista de segmentos
          Expanded(
            child: ListView.builder(
              itemCount: ruta.segmentos.length,
              itemBuilder: (context, index) {
                return SegmentoRutaWidget(
                  segmento: ruta.segmentos[index],
                  numero: index + 1,
                  esUltimo: index == ruta.segmentos.length - 1,
                );
              },
            ),
          ),

          // Botón de acción
          _buildBotonAccion(),
        ],
      ),
    );
  }

  Widget _buildHeaderResumen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ruta.instrucciones,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoItem(Icons.access_time, '${ruta.tiempoTotal} min'),
              _buildInfoItem(
                Icons.alt_route,
                '${ruta.distanciaTotal.toStringAsFixed(1)} km',
              ),
              _buildInfoItem(
                ruta.esDirecta
                    ? Icons.directions_bus
                    : Icons.transfer_within_a_station,
                ruta.esDirecta ? 'Directa' : 'Con transbordo',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildBotonAccion() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () {
          // Abrir mapa con la ruta
        },
        icon: const Icon(Icons.map),
        label: const Text('Ver en Mapa'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
