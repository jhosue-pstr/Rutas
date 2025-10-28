// lib/controllers/bus_favorito_controller.dart
import '../../data/models/bus_favorito.dart';
import '../../data/services/bus_favorito_service.dart';

class BusFavoritoController {
  final BusFavoritoService _busFavoritoService;

  BusFavoritoController(String? token)
    : _busFavoritoService = BusFavoritoService(token);

  Future<List<BusFavorito>> obtenerBusesFavoritos() async {
    try {
      return await _busFavoritoService.getBusesFavoritos();
    } catch (e) {
      throw Exception('Error al obtener los buses favoritos: $e');
    }
  }

  Future<List<BusFavorito>> obtenerBusesFavoritosPorUsuario(
    int usuarioId,
  ) async {
    try {
      return await _busFavoritoService.getBusesFavoritosPorUsuario(usuarioId);
    } catch (e) {
      throw Exception('Error al obtener los buses favoritos del usuario: $e');
    }
  }

  Future<BusFavorito> obtenerBusFavoritoPorId(int id) async {
    try {
      return await _busFavoritoService.getBusFavoritoById(id);
    } catch (e) {
      throw Exception('Error al obtener el bus favorito: $e');
    }
  }

  Future<BusFavorito> agregarBusFavorito(BusFavoritoCreate busFavorito) async {
    try {
      return await _busFavoritoService.createBusFavorito(busFavorito);
    } catch (e) {
      throw Exception('Error al agregar el bus favorito: $e');
    }
  }

  Future<void> eliminarBusFavorito(int id) async {
    try {
      await _busFavoritoService.deleteBusFavorito(id);
    } catch (e) {
      throw Exception('Error al eliminar el bus favorito: $e');
    }
  }

  Future<void> eliminarBusFavoritoPorUsuarioYBus(
    int usuarioId,
    int busId,
  ) async {
    try {
      await _busFavoritoService.deleteBusFavoritoPorUsuarioYBus(
        usuarioId,
        busId,
      );
    } catch (e) {
      throw Exception('Error al eliminar el bus favorito: $e');
    }
  }
}
