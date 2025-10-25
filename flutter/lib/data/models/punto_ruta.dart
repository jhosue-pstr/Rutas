class PuntoRuta {
  final int IdPunto;
  final int RutaId;
  final double latitud;
  final double longitud;
  final int orden;

  const PuntoRuta({
    required this.IdPunto,
    required this.RutaId,
    required this.latitud,
    required this.longitud,
    required this.orden,
  });

  factory PuntoRuta.fromJson(Map<String, dynamic> json) {
    return PuntoRuta(
      IdPunto: json['IdPunto'] ?? 0,
      RutaId: json['RutaId'] ?? 0,
      latitud: (json['latitud'] as num).toDouble(), // Cambiado de 'Latitud'
      longitud: (json['longitud'] as num).toDouble(), // Cambiado de 'Longitud'
      orden: json['orden'] ?? 0, // Cambiado de 'Orden'
    );
  }

  Map<String, dynamic> toJson() => {
    'IdPunto': IdPunto,
    'RutaId': RutaId,
    'latitud': latitud, // Cambiado
    'longitud': longitud, // Cambiado
    'orden': orden, // Cambiado
  };
}
