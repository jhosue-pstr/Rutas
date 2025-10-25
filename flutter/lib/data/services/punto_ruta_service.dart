import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api.dart';
import '../models/punto_ruta.dart';

class PuntoRutaService {
  final String endpoint = 'puntosruta';

  Future<List<PuntoRuta>> getPuntosRuta() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => PuntoRuta.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudieron obtener los puntos',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<PuntoRuta> getPuntoRutaById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));

      if (response.statusCode == 200) {
        return PuntoRuta.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error ${response.statusCode}: punto no encontrado');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<PuntoRuta> createPuntoRuta(PuntoRuta punto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/$endpoint/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(punto.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return PuntoRuta.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudo crear el punto',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<PuntoRuta> updatePuntoRuta(int id, Map<String, dynamic> datos) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      );

      if (response.statusCode == 200) {
        return PuntoRuta.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudo actualizar el punto',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deletePuntoRuta(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error ${response.statusCode}: no se pudo eliminar el punto',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
