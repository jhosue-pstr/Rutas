import 'package:rutasfrontend/data/models/rutas.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PuntoTransbordo {
  final LatLng ubicacion;
  final double distanciaCaminando;
  final int tiempoCaminando;
  final Ruta rutaOrigen;
  final Ruta rutaDestino;
  final String nombreParada;

  PuntoTransbordo({
    required this.ubicacion,
    required this.distanciaCaminando,
    required this.tiempoCaminando,
    required this.rutaOrigen,
    required this.rutaDestino,
    required this.nombreParada,
  });
}
