class Bus {
  final int idBus;
  final String placa;
  final int? capacidad;
  final String? modelo;
  final String? marca;
  final int? choferId;
  final int? rutaId;

  const Bus({
    required this.idBus,
    required this.placa,
    this.capacidad,
    this.modelo,
    this.marca,
    this.choferId,
    this.rutaId,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      idBus: json['IdBus'] ?? 0,
      placa: json['Placa'] ?? "",
      capacidad: json['Capacidad'],
      modelo: json['Modelo'],
      marca: json['Marca'],
      choferId: json['ChoferId'],
      rutaId: json['RutaId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'IdBus': idBus,
    'Placa': placa,
    'Capacidad': capacidad,
    'Modelo': modelo,
    'Marca': marca,
    'ChoferId': choferId,
    'RutaId': rutaId,
  };
}
