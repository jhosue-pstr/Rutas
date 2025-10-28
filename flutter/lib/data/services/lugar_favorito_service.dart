// lib/services/lugar_favorito_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api.dart';
import '../models/lugar_favorito.dart';

class LugarFavoritoService {
  final String endpoint = 'lugares_favoritos';
  final String? token;

  LugarFavoritoService(this.token);

  Future<List<LugarFavorito>> getLugaresFavoritos() async {
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
        return data.map((e) => LugarFavorito.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudieron obtener los lugares favoritos',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<List<LugarFavorito>> getLugaresFavoritosPorUsuario(
    int usuarioId,
  ) async {
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
        return data.map((e) => LugarFavorito.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudieron obtener los lugares favoritos del usuario',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<LugarFavorito> getLugarFavoritoById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/$endpoint/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return LugarFavorito.fromJson(json.decode(response.body));
      } else {
        throw Exception('Lugar favorito no encontrado');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<LugarFavorito> createLugarFavorito(
    LugarFavoritoCreate lugarFavorito,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/$endpoint/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(lugarFavorito.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return LugarFavorito.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudo crear el lugar favorito',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<LugarFavorito> updateLugarFavorito(
    int id,
    LugarFavoritoUpdate lugarFavorito,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/$endpoint/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(lugarFavorito.toJson()),
      );

      if (response.statusCode == 200) {
        return LugarFavorito.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error ${response.statusCode}: no se pudo actualizar el lugar favorito',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<void> deleteLugarFavorito(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/$endpoint/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error ${response.statusCode}: no se pudo eliminar el lugar favorito',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
