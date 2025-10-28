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
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      IdBus: json['IdBus'] ?? 0,
      placa: json['placa'] ?? "", // Cambiado de 'Placa'
      capacidad: json['capacidad'], // Cambiado de 'Capacidad'
      modelo: json['modelo'], // Cambiado de 'Modelo'
      marca: json['marca'], // Cambiado de 'Marca'
      nombre: json['nombre'], // Nuevo campo
      numero: json['numero'], // Nuevo campo
      ChoferId: json['ChoferId'],
      RutaId: json['RutaId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'IdBus': IdBus,
    'placa': placa, // Cambiado
    'capacidad': capacidad, // Cambiado
    'modelo': modelo, // Cambiado
    'marca': marca, // Cambiado
    'nombre': nombre, // Nuevo campo
    'numero': numero, // Nuevo campo
    'ChoferId': ChoferId,
    'RutaId': RutaId,
  };
}
