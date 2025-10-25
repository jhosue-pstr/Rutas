import '../../data/models/punto_ruta.dart';
import '../../data/services/punto_ruta_service.dart';

class PuntoRutaController {
  final PuntoRutaService _puntoRutaService = PuntoRutaService();

  Future<List<PuntoRuta>> obtenerPuntosRuta() async {
    try {
      return await _puntoRutaService.getPuntosRuta();
    } catch (e) {
      throw Exception('Error al obtener los puntos de ruta: $e');
    }
  }

  Future<PuntoRuta> obtenerPuntoRutaPorId(int id) async {
    try {
      return await _puntoRutaService.getPuntoRutaById(id);
    } catch (e) {
      throw Exception('Error al obtener el punto de ruta: $e');
    }
  }

  Future<PuntoRuta> crearPuntoRuta(PuntoRuta punto) async {
    try {
      return await _puntoRutaService.createPuntoRuta(punto);
    } catch (e) {
      throw Exception('Error al crear el punto de ruta: $e');
    }
  }

  Future<PuntoRuta> actualizarPuntoRuta(
    int id,
    Map<String, dynamic> datos,
  ) async {
    try {
      return await _puntoRutaService.updatePuntoRuta(id, datos);
    } catch (e) {
      throw Exception('Error al actualizar el punto de ruta: $e');
    }
  }

  Future<void> eliminarPuntoRuta(int id) async {
    try {
      await _puntoRutaService.deletePuntoRuta(id);
    } catch (e) {
      throw Exception('Error al eliminar el punto de ruta: $e');
    }
  }
}
