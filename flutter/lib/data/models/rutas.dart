import 'package:rutasfrontend/data/models/punto_ruta.dart';

class Ruta {
  final int idRuta;
  final String nombre;
  final String? color;
  final String? descripcion;
  final DateTime fechaRegistro;
  final List<PuntoRuta> puntos;
  final List<dynamic>? buses;

  const Ruta({
    required this.idRuta,
    required this.nombre,
    this.color,
    this.descripcion,
    required this.fechaRegistro,
    this.puntos = const [],
    this.buses,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      idRuta: json['id_ruta'] ?? 0,
      nombre: json['nombre'] ?? '',
      color: json['color'],
      descripcion: json['descripcion'],
      fechaRegistro: DateTime.parse(json['fecha_registro']),
      puntos:
          (json['puntos'] as List<dynamic>?)
              ?.map((p) => PuntoRuta.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      buses: json['buses'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_ruta': idRuta,
    'nombre': nombre,
    'color': color,
    'descripcion': descripcion,
    'fecha_registro': fechaRegistro.toIso8601String(),
    'puntos': puntos.map((p) => p.toJson()).toList(),
    'buses': buses,
  };
}
