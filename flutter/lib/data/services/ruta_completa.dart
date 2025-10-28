// data/services/ruta_completa.dart
import 'package:rutasfrontend/data/services/bus_cercano_info.dart';
import 'package:rutasfrontend/data/services/segmento_ruta.dart';

class RutaCompleta {
  final List<SegmentoRuta> segmentos;
  final double distanciaTotal;
  final int tiempoTotal;
  final String tipo;
  final String instrucciones;
  final int prioridad;
  final BusCercanoInfo? busCercano;
  final int tiempoEsperaBus;

  RutaCompleta({
    required this.segmentos,
    required this.distanciaTotal,
    required this.tiempoTotal,
    required this.tipo,
    required this.instrucciones,
    required this.prioridad,
    this.busCercano,
    this.tiempoEsperaBus = 0,
  });

  int get tiempoTotalConEspera => tiempoTotal + tiempoEsperaBus;
  bool get esDirecta => tipo == 'DIRECTA';
  bool get tieneBusDisponible => busCercano != null;
}
