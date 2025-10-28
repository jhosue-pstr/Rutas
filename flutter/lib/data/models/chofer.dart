class Chofer {
  final int idChofer;
  final String nombre;
  final String? apellido;
  final String? dni;
  final String? telefono;
  final String? fotoUrl;
  final String? qrPagoUrl;
  final String? licenciaConducir;
  final DateTime fechaIngreso;
  final bool estado;

  Chofer({
    required this.idChofer,
    required this.nombre,
    this.apellido,
    this.dni,
    this.telefono,
    this.fotoUrl,
    this.qrPagoUrl,
    this.licenciaConducir,
    required this.fechaIngreso,
    required this.estado,
  });

  factory Chofer.fromJson(Map<String, dynamic> json) {
    return Chofer(
      idChofer: json['IdChofer'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      dni: json['dni'],
      telefono: json['telefono'],
      fotoUrl: json['foto_url'],
      qrPagoUrl: json['qr_pago_url'],
      licenciaConducir: json['licencia_conducir'],
      fechaIngreso: DateTime.parse(json['fecha_ingreso']),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'dni': dni,
      'telefono': telefono,
      'foto_url': fotoUrl,
      'qr_pago_url': qrPagoUrl,
      'licencia_conducir': licenciaConducir,
    };
  }
}