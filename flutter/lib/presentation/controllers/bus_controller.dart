import '../../data/models/bus.dart';
import '../../data/services/bus_service.dart';

class BusController {
  final BusService _busService = BusService();

  Future<List<Bus>> obtenerBuses(String token) async {
    try {
      return await _busService.obtenerBuses(token);
    } catch (e) {
      throw Exception('Error al obtener los buses: $e');
    }
  }

  Future<Bus> obtenerBusPorId(int id, String token) async {
    try {
      return await _busService.obtenerBusPorId(id, token);
    } catch (e) {
      throw Exception('Error al obtener el bus: $e');
    }
  }

  Future<Bus> crearBus(Bus bus, String token) async {
    try {
      return await _busService.crearBus(bus, token);
    } catch (e) {
      throw Exception('Error al crear el bus: $e');
    }
  }

  Future<Bus> actualizarBus(int id, Bus bus, String token) async {
    try {
      return await _busService.actualizarBus(id, bus, token);
    } catch (e) {
      throw Exception('Error al actualizar el bus: $e');
    }
  }

  Future<void> eliminarBus(int id, String token) async {
    try {
      await _busService.eliminarBus(id, token);
    } catch (e) {
      throw Exception('Error al eliminar el bus: $e');
    }
  }
}
