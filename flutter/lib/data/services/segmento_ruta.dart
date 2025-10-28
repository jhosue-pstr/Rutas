import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rutasfrontend/data/models/rutas.dart';
import 'package:rutasfrontend/data/services/bus_cercano_info.dart';

class SegmentoRuta {
  final Ruta? ruta; // Null para segmentos caminando
  final LatLng puntoInicio;
  final LatLng puntoFin;
  final int tiempoEstimado;
  final double distancia;
  final String tipo; // 'BUS' o 'CAMINANDO'
  final String instruccion;
  final BusCercanoInfo? busCercano;

  SegmentoRuta({
    this.ruta,
    required this.puntoInicio,
    required this.puntoFin,
    required this.tiempoEstimado,
    required this.distancia,
    required this.tipo,
    required this.instruccion,
    this.busCercano,
  });

  bool get esBus => tipo == 'BUS';
  bool get esCaminando => tipo == 'CAMINANDO';
}
