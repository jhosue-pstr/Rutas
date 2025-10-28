class PuntoRuta {
  final int IdPunto;
  final int RutaId;
  final double latitud;
  final double longitud;
  final int orden;
  final String tipoPunto; // ✅ NUEVO CAMPO

  const PuntoRuta({
    required this.IdPunto,
    required this.RutaId,
    required this.latitud,
    required this.longitud,
    required this.orden,
    this.tipoPunto = 'normal', // ✅ Valor por defecto
  });

  factory PuntoRuta.fromJson(Map<String, dynamic> json) {
    return PuntoRuta(
      IdPunto: json['IdPunto'] ?? 0,
      RutaId: json['RutaId'] ?? 0,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      orden: json['orden'] ?? 0,
      tipoPunto: json['tipoPunto'] ?? 'normal', // ✅ Nuevo campo
    );
  }

  Map<String, dynamic> toJson() => {
    'IdPunto': IdPunto,
    'RutaId': RutaId,
    'latitud': latitud,
    'longitud': longitud,
    'orden': orden,
    'tipoPunto': tipoPunto, // ✅ Nuevo campo
  };

  // 🔹 MÉTODO PARA CREAR COPIA CON NUEVOS VALORES (útil para updates)
  PuntoRuta copyWith({
    int? IdPunto,
    int? RutaId,
    double? latitud,
    double? longitud,
    int? orden,
    String? tipoPunto,
  }) {
    return PuntoRuta(
      IdPunto: IdPunto ?? this.IdPunto,
      RutaId: RutaId ?? this.RutaId,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      orden: orden ?? this.orden,
      tipoPunto: tipoPunto ?? this.tipoPunto,
    );
  }

  // 🔹 MÉTODO PARA VALIDAR TIPOS DE PUNTO VÁLIDOS
  static const List<String> tiposValidos = ['normal', 'medio', 'inicio', 'fin'];

  bool get esPuntoMedio => tipoPunto == 'medio';
  bool get esPuntoInicio => tipoPunto == 'inicio';
  bool get esPuntoFin => tipoPunto == 'fin';
  bool get esPuntoNormal => tipoPunto == 'normal';

  @override
  String toString() {
    return 'PuntoRuta(IdPunto: $IdPunto, RutaId: $RutaId, latitud: $latitud, longitud: $longitud, orden: $orden, tipoPunto: $tipoPunto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PuntoRuta &&
        other.IdPunto == IdPunto &&
        other.RutaId == RutaId &&
        other.latitud == latitud &&
        other.longitud == longitud &&
        other.orden == orden &&
        other.tipoPunto == tipoPunto;
  }

  @override
  int get hashCode {
    return Object.hash(IdPunto, RutaId, latitud, longitud, orden, tipoPunto);
  }
}
