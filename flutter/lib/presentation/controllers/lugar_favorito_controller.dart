// lib/controllers/lugar_favorito_controller.dart
import '../../data/models/lugar_favorito.dart';
import '../../data/services/lugar_favorito_service.dart';

class LugarFavoritoController {
  final LugarFavoritoService _lugarFavoritoService;

  LugarFavoritoController(String? token)
    : _lugarFavoritoService = LugarFavoritoService(token);

  Future<List<LugarFavorito>> obtenerLugaresFavoritos() async {
    try {
      return await _lugarFavoritoService.getLugaresFavoritos();
    } catch (e) {
      throw Exception('Error al obtener los lugares favoritos: $e');
    }
  }

  Future<List<LugarFavorito>> obtenerLugaresFavoritosPorUsuario(
    int usuarioId,
  ) async {
    try {
      return await _lugarFavoritoService.getLugaresFavoritosPorUsuario(
        usuarioId,
      );
    } catch (e) {
      throw Exception('Error al obtener los lugares favoritos del usuario: $e');
    }
  }

  Future<LugarFavorito> obtenerLugarFavoritoPorId(int id) async {
    try {
      return await _lugarFavoritoService.getLugarFavoritoById(id);
    } catch (e) {
      throw Exception('Error al obtener el lugar favorito: $e');
    }
  }

  Future<LugarFavorito> agregarLugarFavorito(
    LugarFavoritoCreate lugarFavorito,
  ) async {
    try {
      return await _lugarFavoritoService.createLugarFavorito(lugarFavorito);
    } catch (e) {
      throw Exception('Error al agregar el lugar favorito: $e');
    }
  }

  Future<LugarFavorito> actualizarLugarFavorito(
    int id,
    LugarFavoritoUpdate lugarFavorito,
  ) async {
    try {
      return await _lugarFavoritoService.updateLugarFavorito(id, lugarFavorito);
    } catch (e) {
      throw Exception('Error al actualizar el lugar favorito: $e');
    }
  }

  Future<void> eliminarLugarFavorito(int id) async {
    try {
      await _lugarFavoritoService.deleteLugarFavorito(id);
    } catch (e) {
      throw Exception('Error al eliminar el lugar favorito: $e');
    }
  }
}
