import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api.dart';
import '../models/chofer.dart';

class ChoferService {
  final String endpoint = 'choferes';

  Future<List<Chofer>> getChoferes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/$endpoint/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Chofer.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudieron obtener los choferes',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Chofer> getChoferById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/$endpoint/$id'));

      if (response.statusCode == 200) {
        return Chofer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error ${response.statusCode}: chofer no encontrado');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Chofer> createChofer(Chofer chofer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/$endpoint/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(chofer.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Chofer.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudo crear el chofer',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Chofer> updateChofer(int id, Map<String, dynamic> datos) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/$endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      );

      if (response.statusCode == 200) {
        return Chofer.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudo actualizar el chofer',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteChofer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/$endpoint/$id'),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error ${response.statusCode}: no se pudo eliminar el chofer',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
