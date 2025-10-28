import 'package:rutasfrontend/data/models/punto_ruta.dart';

class Ruta {
  final int IdRuta;
  final String nombre;
  final String? color;
  final String? descripcion;
  final DateTime FechaRegistro;
  final List<PuntoRuta> puntos;
  final List<dynamic>? buses;

  const Ruta({
    required this.IdRuta,
    required this.nombre,
    this.color,
    this.descripcion,
    required this.FechaRegistro,
    this.puntos = const [],
    this.buses,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      IdRuta: json['IdRuta'] ?? 0, // Cambiado de 'id_ruta'
      nombre: json['nombre'] ?? '', // Mantener camelCase para campos base
      color: json['color'],
      descripcion: json['descripcion'],
      FechaRegistro: DateTime.parse(
        json['FechaRegistro'],
      ), // Cambiado de 'fecha_registro'
      puntos:
          (json['puntos'] as List<dynamic>?)
              ?.map((p) => PuntoRuta.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      buses: json['buses'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'IdRuta': IdRuta, // Cambiado
    'nombre': nombre,
    'color': color,
    'descripcion': descripcion,
    'FechaRegistro': FechaRegistro.toIso8601String(), // Cambiado
    'puntos': puntos.map((p) => p.toJson()).toList(),
    'buses': buses,
  };
}
