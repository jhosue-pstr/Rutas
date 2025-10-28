import 'package:rutasfrontend/data/services/ruta_completa.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResultadoRuta {
  final List<RutaCompleta> rutasRecomendadas;
  final bool hayRutasDirectas;
  final String mensaje;
  final LatLng origen;
  final LatLng destino;

  ResultadoRuta({
    required this.rutasRecomendadas,
    required this.hayRutasDirectas,
    required this.mensaje,
    required this.origen,
    required this.destino,
  });

  bool get hayRutas => rutasRecomendadas.isNotEmpty;
  int get totalRutas => rutasRecomendadas.length;
}
