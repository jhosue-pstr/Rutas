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

  const Chofer({
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
      idChofer: json['IdChofer'] ?? 0,
      nombre: json['Nombre'] ?? "",
      apellido: json['Apellido'],
      dni: json['DNI'],
      telefono: json['Telefono'],
      fotoUrl: json['FotoURL'],
      qrPagoUrl: json['QRPagoURL'],
      licenciaConducir: json['LicenciaConducir'],
      fechaIngreso: DateTime.parse(json['FechaIngreso']),
      estado: json['Estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'IdChofer': idChofer,
    'Nombre': nombre,
    'Apellido': apellido,
    'DNI': dni,
    'Telefono': telefono,
    'FotoURL': fotoUrl,
    'QRPagoURL': qrPagoUrl,
    'LicenciaConducir': licenciaConducir,
    'FechaIngreso': fechaIngreso.toIso8601String(),
    'Estado': estado,
  };
}
