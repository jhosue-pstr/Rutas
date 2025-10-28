// data/models/ubicacion_bus.dart
class UbicacionBus {
  final int busId;
  final String placa;
  final int rutaId;
  final double latitud;
  final double longitud;
  final DateTime ultimaActualizacion;

  UbicacionBus({
    required this.busId,
    required this.placa,
    required this.rutaId,
    required this.latitud,
    required this.longitud,
    required this.ultimaActualizacion,
  });

  factory UbicacionBus.fromJson(Map<String, dynamic> json) {
    return UbicacionBus(
      busId: json['bus_id'] ?? 0,
      placa: json['placa'] ?? '',
      rutaId: json['ruta_id'] ?? 0,
      latitud: json['latitud'] ?? 0.0,
      longitud: json['longitud'] ?? 0.0,
      ultimaActualizacion: DateTime.parse(
        json['ultima_actualizacion'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Para Google Maps
  Map<String, double> toLatLng() {
    return {'latitude': latitud, 'longitude': longitud};
  }
}
