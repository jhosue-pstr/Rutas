import 'package:rutasfrontend/data/models/punto_ruta.dart';

class Ruta {
  final int idRuta;
  final String nombre;
  final String? color;
  final String? descripcion;
  final DateTime fechaRegistro;
  final List<PuntoRuta> puntos;

  const Ruta({
    required this.idRuta,
    required this.nombre,
    this.color,
    this.descripcion,
    required this.fechaRegistro,
    this.puntos = const [],
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      idRuta: json['IdRuta'] ?? 0,
      nombre: json['Nombre'] ?? '',
      color: json['Color'],
      descripcion: json['Descripcion'],
      fechaRegistro: DateTime.parse(json['FechaRegistro']),
      puntos:
          (json['Puntos'] as List<dynamic>?)
              ?.map((p) => PuntoRuta.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'IdRuta': idRuta,
    'Nombre': nombre,
    'Color': color,
    'Descripcion': descripcion,
    'FechaRegistro': fechaRegistro.toIso8601String(),
    'Puntos': puntos.map((p) => p.toJson()).toList(),
  };
}
