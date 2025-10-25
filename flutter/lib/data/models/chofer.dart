class Chofer {
  final int IdChofer;
  final String nombre;
  final String? apellido;
  final String? dni;
  final String? telefono;
  final String? foto_url; // Cambiado de fotoUrl
  final String? qr_pago_url; // Cambiado de qrPagoUrl
  final String? licencia_conducir; // Cambiado de licenciaConducir
  final DateTime fecha_ingreso; // Cambiado de fechaIngreso
  final bool estado;

  const Chofer({
    required this.IdChofer,
    required this.nombre,
    this.apellido,
    this.dni,
    this.telefono,
    this.foto_url,
    this.qr_pago_url,
    this.licencia_conducir,
    required this.fecha_ingreso,
    required this.estado,
  });

  factory Chofer.fromJson(Map<String, dynamic> json) {
    return Chofer(
      IdChofer: json['IdChofer'] ?? 0,
      nombre: json['nombre'] ?? "", // Cambiado de 'Nombre'
      apellido: json['apellido'], // Cambiado de 'Apellido'
      dni: json['dni'], // Cambiado de 'DNI'
      telefono: json['telefono'], // Cambiado de 'Telefono'
      foto_url: json['foto_url'], // Cambiado de 'FotoURL'
      qr_pago_url: json['qr_pago_url'], // Cambiado de 'QRPagoURL'
      licencia_conducir: json['licencia_conducir'], // Cambiado
      fecha_ingreso: DateTime.parse(json['fecha_ingreso']), // Cambiado
      estado: json['estado'] ?? true, // Cambiado de 'Estado'
    );
  }

  Map<String, dynamic> toJson() => {
    'IdChofer': IdChofer,
    'nombre': nombre,
    'apellido': apellido,
    'dni': dni,
    'telefono': telefono,
    'foto_url': foto_url,
    'qr_pago_url': qr_pago_url,
    'licencia_conducir': licencia_conducir,
    'fecha_ingreso': fecha_ingreso.toIso8601String(),
    'estado': estado,
  };
}
