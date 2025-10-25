import '../../data/models/rutas.dart';
import '../../data/services/ruta_service.dart';

class RutaController {
  final RutaService _rutaService = RutaService();

  /// 🔹 Obtener todas las rutas
  Future<List<Ruta>> obtenerRutas() async {
    try {
      return await _rutaService.getRutas();
    } catch (e) {
      throw Exception('Error al obtener las rutas: $e');
    }
  }

  /// 🔹 Obtener una ruta por su ID
  Future<Ruta> obtenerRutaPorId(int id) async {
    try {
      return await _rutaService.getRutaById(id);
    } catch (e) {
      throw Exception('Error al obtener la ruta: $e');
    }
  }

  /// 🔹 Crear una nueva ruta
  Future<Ruta> crearRuta(Ruta ruta) async {
    try {
      return await _rutaService.createRuta(ruta);
    } catch (e) {
      throw Exception('Error al crear la ruta: $e');
    }
  }

  /// 🔹 Actualizar una ruta existente
  Future<Ruta> actualizarRuta(int id, Ruta ruta) async {
    try {
      return await _rutaService.updateRuta(id, ruta);
    } catch (e) {
      throw Exception('Error al actualizar la ruta: $e');
    }
  }

  /// 🔹 Eliminar una ruta
  Future<void> eliminarRuta(int id) async {
    try {
      await _rutaService.deleteRuta(id);
    } catch (e) {
      throw Exception('Error al eliminar la ruta: $e');
    }
  }
}
