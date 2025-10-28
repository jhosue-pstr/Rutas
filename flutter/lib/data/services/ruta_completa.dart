import 'package:rutasfrontend/data/services/segmento_ruta.dart';

class RutaCompleta {
  final List<SegmentoRuta> segmentos;
  final int tiempoTotal;
  final double distanciaTotal;
  final String tipo;
  final String instrucciones;
  final int prioridad;

  RutaCompleta({
    required this.segmentos,
    required this.tiempoTotal,
    required this.distanciaTotal,
    required this.tipo,
    required this.instrucciones,
    this.prioridad = 1,
  });

  bool get esDirecta => tipo == 'DIRECTA';
  bool get tieneTransbordo => tipo == 'CON_TRANSBORDO';
}
