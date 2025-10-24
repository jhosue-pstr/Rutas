class Usuario {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String correo;
  final String contrasena;
  final DateTime fechaRegistro;
  final bool estado;

  const Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.contrasena,
    required this.fechaRegistro,
    required this.estado,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['IdUsuario'] ?? 0,
      nombre: json['Nombre'] ?? "",
      apellido: json['Apellido'] ?? "",
      correo: json['Correo'] ?? "",
      contrasena: json['Contrasena'] ?? "",
      fechaRegistro: DateTime.parse(json['FechaRegistro']),
      estado: json['Estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'IdUsuario': idUsuario,
    'Nombre': nombre,
    'Apellido': apellido,
    'Correo': correo,
    'Contrasena': contrasena,
    'FechaRegistro': fechaRegistro.toIso8601String(),
    'Estado': estado,
  };
}
