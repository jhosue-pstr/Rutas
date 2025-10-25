class PuntoRuta {
  final int idPunto;
  final int rutaId;
  final double latitud;
  final double longitud;
  final int orden;

  const PuntoRuta({
    required this.idPunto,
    required this.rutaId,
    required this.latitud,
    required this.longitud,
    required this.orden,
  });

  factory PuntoRuta.fromJson(Map<String, dynamic> json) {
    return PuntoRuta(
      idPunto: json['IdPunto'] ?? 0,
      rutaId: json['RutaId'] ?? 0,
      latitud: (json['Latitud'] as num).toDouble(),
      longitud: (json['Longitud'] as num).toDouble(),
      orden: json['Orden'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'IdPunto': idPunto,
    'RutaId': rutaId,
    'Latitud': latitud,
    'Longitud': longitud,
    'Orden': orden,
  };
}
