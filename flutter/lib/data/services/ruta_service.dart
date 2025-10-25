import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api.dart';
import '../models/rutas.dart';

class RutaService {
  final String endpoint = 'rutas';

  /// 🔹 Obtener todas las rutas
  Future<List<Ruta>> getRutas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Ruta.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudieron obtener las rutas',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// 🔹 Obtener una ruta por ID
  Future<Ruta> getRutaById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));

      if (response.statusCode == 200) {
        return Ruta.fromJson(json.decode(response.body));
      } else {
        throw Exception('Ruta no encontrada');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// 🔹 Crear una nueva ruta
  Future<Ruta> createRuta(Ruta ruta) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/$endpoint/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ruta.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Ruta.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudo crear la ruta',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// 🔹 Actualizar una ruta existente
  Future<Ruta> updateRuta(int id, Ruta ruta) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ruta.toJson()),
      );

      if (response.statusCode == 200) {
        return Ruta.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudo actualizar la ruta',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// 🔹 Eliminar una ruta
  Future<void> deleteRuta(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error ${response.statusCode}: no se pudo eliminar la ruta',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
