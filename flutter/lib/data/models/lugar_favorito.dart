// lib/models/lugar_favorito.dart
class LugarFavorito {
  final int id;
  final String nombre;
  final double latitud;
  final double longitud;
  final String? descripcion;
  final String color;
  final int idUsuario; // 🔥 AGREGAR ESTE CAMPO

  const LugarFavorito({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    this.descripcion,
    this.color = "#2196F3",
    required this.idUsuario, // 🔥 AGREGAR ESTE CAMPO
  });

  factory LugarFavorito.fromJson(Map<String, dynamic> json) {
    return LugarFavorito(
      id: json['Id'] ?? 0,
      nombre: json['Nombre'] ?? "",
      latitud: json['Latitud'] ?? 0.0,
      longitud: json['Longitud'] ?? 0.0,
      descripcion: json['Descripcion'],
      color: json['Color'] ?? "#2196F3",
      idUsuario: json['IdUsuario'] ?? 0, // 🔥 AGREGAR ESTE CAMPO
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Nombre': nombre,
    'Latitud': latitud,
    'Longitud': longitud,
    'Descripcion': descripcion,
    'Color': color,
    'IdUsuario': idUsuario, // 🔥 AGREGAR ESTE CAMPO
  };
}

class LugarFavoritoCreate {
  final String nombre;
  final double latitud;
  final double longitud;
  final String? descripcion;
  final String color;
  final int idUsuario; // 🔥 AGREGAR ESTE CAMPO

  const LugarFavoritoCreate({
    required this.nombre,
    required this.latitud,
    required this.longitud,
    this.descripcion,
    this.color = "#2196F3",
    required this.idUsuario, // 🔥 AGREGAR ESTE CAMPO
  });

  Map<String, dynamic> toJson() => {
    'Nombre': nombre,
    'Latitud': latitud,
    'Longitud': longitud,
    'Descripcion': descripcion,
    'Color': color,
    'IdUsuario': idUsuario, // 🔥 AGREGAR ESTE CAMPO
  };
}

class LugarFavoritoUpdate {
  final String? nombre;
  final double? latitud;
  final double? longitud;
  final String? descripcion;
  final String? color;
  final int? idUsuario; // 🔥 AGREGAR ESTE CAMPO

  const LugarFavoritoUpdate({
    this.nombre,
    this.latitud,
    this.longitud,
    this.descripcion,
    this.color,
    this.idUsuario, // 🔥 AGREGAR ESTE CAMPO
  });

  Map<String, dynamic> toJson() => {
    if (nombre != null) 'Nombre': nombre,
    if (latitud != null) 'Latitud': latitud,
    if (longitud != null) 'Longitud': longitud,
    if (descripcion != null) 'Descripcion': descripcion,
    if (color != null) 'Color': color,
    if (idUsuario != null) 'IdUsuario': idUsuario,
  };
}
