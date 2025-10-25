import '../../data/models/chofer.dart';
import '../../data/services/chofer_service.dart';

class ChoferController {
  final ChoferService _choferService = ChoferService();

  /// 🔹 Obtener todos los choferes
  Future<List<Chofer>> obtenerChoferes() async {
    try {
      return await _choferService.getChoferes();
    } catch (e) {
      throw Exception('Error al obtener los choferes: $e');
    }
  }

  /// 🔹 Obtener un chofer por ID
  Future<Chofer> obtenerChoferPorId(int id) async {
    try {
      return await _choferService.getChoferById(id);
    } catch (e) {
      throw Exception('Error al obtener el chofer: $e');
    }
  }

  /// 🔹 Crear un nuevo chofer
  Future<Chofer> crearChofer(Chofer chofer) async {
    try {
      return await _choferService.createChofer(chofer);
    } catch (e) {
      throw Exception('Error al crear el chofer: $e');
    }
  }

  /// 🔹 Actualizar un chofer existente
  Future<Chofer> actualizarChofer(int id, Map<String, dynamic> datos) async {
    try {
      return await _choferService.updateChofer(id, datos);
    } catch (e) {
      throw Exception('Error al actualizar el chofer: $e');
    }
  }

  /// 🔹 Eliminar un chofer
  Future<void> eliminarChofer(int id) async {
    try {
      await _choferService.deleteChofer(id);
    } catch (e) {
      throw Exception('Error al eliminar el chofer: $e');
    }
  }
}
