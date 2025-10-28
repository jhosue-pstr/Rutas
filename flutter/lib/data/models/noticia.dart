class Noticia {
  final int idNoticia;
  final String nombre;
  final String descripcion;
  final String imagen;
  final DateTime fechaPublicacion;

  Noticia({
    required this.idNoticia,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.fechaPublicacion,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      idNoticia: json['IdNoticia'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagen: json['imagen'],
      fechaPublicacion: DateTime.parse(json['fechaPublicacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': imagen,
    };
  }
}