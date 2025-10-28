// class Bus {
//   final int IdBus;
//   final String placa;
//   final int? capacidad;
//   final String? modelo;
//   final String? marca;
//   final String? nombre;
//   final String? numero;

//   final int? ChoferId;
//   final int? RutaId;

//   const Bus({
//     required this.IdBus,
//     required this.placa,
//     this.capacidad,
//     this.modelo,
//     this.marca,
//     this.nombre,
//     this.numero,
//     this.ChoferId,
//     this.RutaId,
//   });

//   factory Bus.fromJson(Map<String, dynamic> json) {
//     return Bus(
//       IdBus: json['IdBus'] ?? 0,
//       placa: json['placa'] ?? "",
//       capacidad: json['capacidad'],
//       marca: json['marca'],
//       nombre: json['nombre'],
//       numero: json['numero'],
//       ChoferId: json['ChoferId'],
//       RutaId: json['RutaId'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'IdBus': IdBus,
//     'placa': placa,
//     'capacidad': capacidad,
//     'modelo': modelo,
//     'marca': marca,
//     'nombre': nombre,
//     'numero': numero,
//     'ChoferId': ChoferId,
//     'RutaId': RutaId,
//   };
// }

class Bus {
  final int IdBus;
  final String placa;
  final int? capacidad;
  final String? modelo;
  final String? marca;
  final String? nombre;
  final String? numero;
  final int? ChoferId;
  final int? RutaId;

  // ✅ NUEVO: Campos para ubicación en tiempo real
  final double? latitud;
  final double? longitud;
  final bool? activo;
  final DateTime? ultimaActualizacion;
  final double? velocidad;

  const Bus({
    required this.IdBus,
    required this.placa,
    this.capacidad,
    this.modelo,
    this.marca,
    this.nombre,
    this.numero,
    this.ChoferId,
    this.RutaId,
    // ✅ NUEVO
    this.latitud,
    this.longitud,
    this.activo,
    this.ultimaActualizacion,
    this.velocidad = 0.0,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      IdBus: json['IdBus'] ?? 0,
      placa: json['placa'] ?? "",
      capacidad: json['capacidad'],
      marca: json['marca'],
      nombre: json['nombre'],
      numero: json['numero'],
      ChoferId: json['ChoferId'],
      RutaId: json['RutaId'],
      // ✅ NUEVO: Campos de ubicación
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
      activo: json['activo'] ?? false,
      ultimaActualizacion: json['ultimaActualizacion'] != null
          ? DateTime.parse(json['ultimaActualizacion'])
          : null,
      velocidad: json['velocidad'] != null
          ? double.tryParse(json['velocidad'].toString())
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'IdBus': IdBus,
    'placa': placa,
    'capacidad': capacidad,
    'modelo': modelo,
    'marca': marca,
    'nombre': nombre,
    'numero': numero,
    'ChoferId': ChoferId,
    'RutaId': RutaId,
    'latitud': latitud,
    'longitud': longitud,
    'activo': activo,
    'ultimaActualizacion': ultimaActualizacion?.toIso8601String(),
    'velocidad': velocidad,
  };

  bool get tieneUbicacionValida =>
      latitud != null && longitud != null && activo == true;

  Bus copyWithUbicacion({
    double? latitud,
    double? longitud,
    bool? activo,
    double? velocidad,
  }) {
    return Bus(
      IdBus: IdBus,
      placa: placa,
      capacidad: capacidad,
      modelo: modelo,
      marca: marca,
      nombre: nombre,
      numero: numero,
      ChoferId: ChoferId,
      RutaId: RutaId,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      activo: activo ?? this.activo,
      ultimaActualizacion: DateTime.now(),
      velocidad: velocidad ?? this.velocidad,
    );
  }
}
