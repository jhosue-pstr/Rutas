// lib/services/bus_favorito_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api.dart';
import '../models/bus_favorito.dart';

class BusFavoritoService {
  final String endpoint = 'buses_favoritos';
  final String? token;

  BusFavoritoService(this.token);

  Future<List<BusFavorito>> getBusesFavoritos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/$endpoint/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => BusFavorito.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudieron obtener los buses favoritos',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<List<BusFavorito>> getBusesFavoritosPorUsuario(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/usuarios/$usuarioId/$endpoint/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => BusFavorito.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudieron obtener los buses favoritos del usuario',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<BusFavorito> getBusFavoritoById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/$endpoint/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return BusFavorito.fromJson(json.decode(response.body));
      } else {
        throw Exception('Bus favorito no encontrado');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<BusFavorito> createBusFavorito(BusFavoritoCreate busFavorito) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/$endpoint/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(busFavorito.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BusFavorito.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudo crear el bus favorito',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<void> deleteBusFavorito(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/$endpoint/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error ${response.statusCode}: no se pudo eliminar el bus favorito',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<void> deleteBusFavoritoPorUsuarioYBus(int usuarioId, int busId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/usuarios/$usuarioId/$endpoint/$busId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error ${response.statusCode}: no se pudo eliminar el bus favorito',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
