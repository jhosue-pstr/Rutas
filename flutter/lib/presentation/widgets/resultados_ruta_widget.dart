// import 'package:flutter/material.dart';
// import 'package:rutasfrontend/data/services/resultado_ruta.dart';
// import 'package:rutasfrontend/data/services/ruta_completa.dart';
// import 'package:rutasfrontend/presentation/widgets/rutas_mapa_widget.dart';
// import 'detalle_ruta_widget.dart';

// class ResultadosRutaWidget extends StatelessWidget {
//   final ResultadoRuta resultado;
//   final VoidCallback? onVolver;
//   final Function(RutaCompleta)? onVerDetalle;
//   final Function(RutaCompleta)? onVerEnMapa;

//   const ResultadosRutaWidget({
//     super.key,
//     required this.resultado,
//     this.onVolver,
//     this.onVerDetalle,
//     this.onVerEnMapa,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Rutas Encontradas'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: onVolver ?? () => Navigator.pop(context),
//         ),
//       ),
//       body: _buildContenido(context), // ✅ Pasar context aquí
//     );
//   }

//   Widget _buildContenido(BuildContext context) {
//     if (!resultado.hayRutas) {
//       return _buildSinRutas(context); // ✅ Pasar context
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildHeader(),
//         Expanded(
//           child: ListView.builder(
//             itemCount: resultado.rutasRecomendadas.length,
//             itemBuilder: (context, index) {
//               final ruta = resultado.rutasRecomendadas[index];
//               return _buildTarjetaRuta(ruta, index, context);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // ✅ CORREGIDO: Recibir context como parámetro
//   Widget _buildSinRutas(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.warning_amber, size: 64, color: Colors.orange[300]),
//           const SizedBox(height: 16),
//           const Text(
//             'No se encontraron rutas',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 32),
//             child: Text(
//               'Intenta con ubicaciones diferentes o aumenta el radio de búsqueda',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed:
//                 onVolver ?? () => Navigator.pop(context), // ✅ Ahora sí funciona
//             icon: const Icon(Icons.arrow_back),
//             label: const Text('Volver'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // El resto del código se mantiene igual...
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 resultado.hayRutasDirectas
//                     ? Icons.check_circle
//                     : Icons.transfer_within_a_station,
//                 color: resultado.hayRutasDirectas
//                     ? Colors.green
//                     : Colors.orange,
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   resultado.mensaje,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: resultado.hayRutasDirectas
//                         ? Colors.green
//                         : Colors.orange,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${resultado.totalRutas} ruta${resultado.totalRutas > 1 ? 's' : ''} encontrada${resultado.totalRutas > 1 ? 's' : ''}',
//             style: const TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTarjetaRuta(RutaCompleta ruta, int index, BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Opción ${index + 1}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: ruta.esDirecta
//                         ? Colors.green[100]
//                         : Colors.orange[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     ruta.esDirecta ? 'DIRECTA' : 'CON TRANSBORDO',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: ruta.esDirecta
//                           ? Colors.green[800]
//                           : Colors.orange[800],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
//                 const SizedBox(width: 4),
//                 Text('${ruta.tiempoTotal} min'),
//                 const SizedBox(width: 16),
//                 Icon(Icons.alt_route, size: 16, color: Colors.grey[600]),
//                 const SizedBox(width: 4),
//                 Text('${ruta.distanciaTotal.toStringAsFixed(1)} km'),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               ruta.instrucciones,
//               style: TextStyle(
//                 color: Colors.grey[700],
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//             const SizedBox(height: 8),
//             _buildPreviewSegmentos(ruta),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _verDetalleRuta(ruta, context),
//                     icon: const Icon(Icons.list_alt, size: 18),
//                     label: const Text('Detalles'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.blue,
//                       side: const BorderSide(color: Colors.blue),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _verRutaEnMapa(ruta, context),
//                     icon: const Icon(Icons.map, size: 18),
//                     label: const Text('Ver Mapa'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPreviewSegmentos(RutaCompleta ruta) {
//     return Column(
//       children: ruta.segmentos.take(3).map((segmento) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 2),
//           child: Row(
//             children: [
//               Icon(
//                 segmento.esBus ? Icons.directions_bus : Icons.directions_walk,
//                 size: 16,
//                 color: segmento.esBus ? Colors.blue : Colors.green,
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   segmento.instruccion,
//                   style: const TextStyle(fontSize: 12),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   void _verDetalleRuta(RutaCompleta ruta, BuildContext context) {
//     if (onVerDetalle != null) {
//       onVerDetalle!(ruta);
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => DetalleRutaWidget(ruta: ruta)),
//       );
//     }
//   }

//   void _verRutaEnMapa(RutaCompleta ruta, BuildContext context) {
//     if (onVerEnMapa != null) {
//       onVerEnMapa!(ruta);
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MapaRutaWidget(rutaEspecifica: ruta),
//         ),
//       );
//     }
//   }
// }

// presentation/widgets/resultados_ruta_widget.dart
import 'package:flutter/material.dart';
import 'package:rutasfrontend/data/services/resultado_ruta.dart';
import 'package:rutasfrontend/data/services/ruta_completa.dart';
import 'package:rutasfrontend/presentation/widgets/rutas_mapa_widget.dart';
import 'detalle_ruta_widget.dart'; // ✅ Ahora apunta al correcto

class ResultadosRutaWidget extends StatelessWidget {
  final ResultadoRuta resultado;
  final VoidCallback? onVolver;
  final Function(RutaCompleta)? onVerDetalle;
  final Function(RutaCompleta)? onVerEnMapa;

  const ResultadosRutaWidget({
    super.key,
    required this.resultado,
    this.onVolver,
    this.onVerDetalle,
    this.onVerEnMapa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas Encontradas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onVolver ?? () => Navigator.pop(context),
        ),
      ),
      body: _buildContenido(context),
    );
  }

  Widget _buildContenido(BuildContext context) {
    if (!resultado.hayRutas) {
      return _buildSinRutas(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: resultado.rutasRecomendadas.length,
            itemBuilder: (context, index) {
              final ruta = resultado.rutasRecomendadas[index];
              return _buildTarjetaRuta(ruta, index, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSinRutas(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber, size: 64, color: Colors.orange[300]),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron rutas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Intenta con ubicaciones diferentes o aumenta el radio de búsqueda',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onVolver ?? () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          Row(
            children: [
              Icon(
                resultado.hayRutasDirectas
                    ? Icons.check_circle
                    : Icons.transfer_within_a_station,
                color: resultado.hayRutasDirectas
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  resultado.mensaje,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: resultado.hayRutasDirectas
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${resultado.totalRutas} ruta${resultado.totalRutas > 1 ? 's' : ''} encontrada${resultado.totalRutas > 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaRuta(RutaCompleta ruta, int index, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opción ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ruta.esDirecta
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ruta.esDirecta ? 'DIRECTA' : 'CON TRANSBORDO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ruta.esDirecta
                          ? Colors.green[800]
                          : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ✅ INFORMACIÓN DEL BUS CERCANO
            if (ruta.tieneBusDisponible && ruta.busCercano != null)
              _buildInfoBusCercano(ruta.busCercano!),

            // ✅ INDICADOR SI NO HAY BUS DISPONIBLE
            if (!ruta.tieneBusDisponible) _buildSinBusDisponible(),

            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                // ✅ Mostrar tiempo total con espera
                Text('${ruta.tiempoTotalConEspera} min (incluye espera)'),
                const SizedBox(width: 16),
                Icon(Icons.alt_route, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${ruta.distanciaTotal.toStringAsFixed(1)} km'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ruta.instrucciones,
              style: TextStyle(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            _buildPreviewSegmentos(ruta),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _verDetalleRuta(ruta, context),
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('Detalles'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verRutaEnMapa(ruta, context),
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Ver Mapa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ WIDGET PARA INFORMACIÓN DEL BUS CERCANO
  Widget _buildInfoBusCercano(dynamic busCercanoInfo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_bus, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus ${busCercanoInfo.bus.placa}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  'A ${busCercanoInfo.distanciaKm.toStringAsFixed(1)} km • Llega en ${busCercanoInfo.tiempoEstimadoMinutos} min',
                  style: TextStyle(fontSize: 11, color: Colors.green[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ WIDGET PARA CUANDO NO HAY BUS DISPONIBLE
  Widget _buildSinBusDisponible() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No hay buses disponibles en este momento',
              style: TextStyle(color: Colors.orange[800], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSegmentos(RutaCompleta ruta) {
    return Column(
      children: ruta.segmentos.take(3).map((segmento) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                segmento.esBus ? Icons.directions_bus : Icons.directions_walk,
                size: 16,
                color: segmento.esBus ? Colors.blue : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  segmento.instruccion,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _verDetalleRuta(RutaCompleta ruta, BuildContext context) {
    if (onVerDetalle != null) {
      onVerDetalle!(ruta);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetalleRutaWidget(ruta: ruta)),
      );
    }
  }

  void _verRutaEnMapa(RutaCompleta ruta, BuildContext context) {
    if (onVerEnMapa != null) {
      onVerEnMapa!(ruta);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapaRutaWidget(rutaEspecifica: ruta),
        ),
      );
    }
  }
}
