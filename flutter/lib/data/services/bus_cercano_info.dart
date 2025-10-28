// data/services/bus_cercano_info.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/bus.dart';

class BusCercanoInfo {
  final Bus bus;
  final double distanciaKm;
  final int tiempoEstimadoMinutos;
  final LatLng ubicacionBus;

  BusCercanoInfo({
    required this.bus,
    required this.distanciaKm,
    required this.tiempoEstimadoMinutos,
    required this.ubicacionBus,
  });

  @override
  String toString() {
    return 'Bus ${bus.placa} está a ${distanciaKm.toStringAsFixed(1)} km, llegará en $tiempoEstimadoMinutos minutos';
  }

  String get descripcionCorta {
    return 'Bus ${bus.placa} - ${tiempoEstimadoMinutos} min';
  }
}
