// lib/models/bus_favorito.dart
class BusFavorito {
  final int idBusFavorito;
  final int idBus;
  final int idUsuario;

  const BusFavorito({
    required this.idBusFavorito,
    required this.idBus,
    required this.idUsuario,
  });

  factory BusFavorito.fromJson(Map<String, dynamic> json) {
    return BusFavorito(
      idBusFavorito: json['IdBusFavorito'] ?? 0,
      idBus: json['IdBus'] ?? 0,
      idUsuario: json['IdUsuario'] ?? 0,
    );
  }

  int get id => idBusFavorito;

  String get nombreBus => 'Bus $idBus';
  String get ruta => 'Ruta del bus $idBus';
  String get codigoBus => 'BUS$idBus';

  Map<String, dynamic> toJson() => {
    'IdBusFavorito': idBusFavorito,
    'IdBus': idBus,
    'IdUsuario': idUsuario,
  };
}

class BusFavoritoCreate {
  final int idBus;
  final int idUsuario;

  const BusFavoritoCreate({required this.idBus, required this.idUsuario});

  Map<String, dynamic> toJson() => {'IdBus': idBus, 'IdUsuario': idUsuario};
}
