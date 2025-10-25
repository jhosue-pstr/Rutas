import '../../data/models/bus.dart';
import '../../data/services/bus_service.dart';

class BusController {
  final BusService _busService = BusService();

  Future<List<Bus>> obtenerBuses() async {
    try {
      return await _busService.obtenerBuses();
    } catch (e) {
      throw Exception('Error al obtener los buses: $e');
    }
  }

  Future<Bus> obtenerBusPorId(int id) async {
    try {
      return await _busService.obtenerBusPorId(id);
    } catch (e) {
      throw Exception('Error al obtener el bus: $e');
    }
  }

  Future<Bus> crearBus(Bus bus) async {
    try {
      return await _busService.crearBus(bus);
    } catch (e) {
      throw Exception('Error al crear el bus: $e');
    }
  }

  Future<Bus> actualizarBus(int id, Bus bus) async {
    try {
      return await _busService.actualizarBus(id, bus);
    } catch (e) {
      throw Exception('Error al actualizar el bus: $e');
    }
  }

  Future<void> eliminarBus(int id) async {
    try {
      await _busService.eliminarBus(id);
    } catch (e) {
      throw Exception('Error al eliminar el bus: $e');
    }
  }
}
