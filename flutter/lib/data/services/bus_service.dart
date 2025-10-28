import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api.dart';
import '../models/bus.dart';

class BusService {
  Future<List<Bus>> obtenerBuses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/buses/'), // Agregado /api/
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Bus.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los buses: ${response.statusCode}');
    }
  }

  Future<Bus> crearBus(Bus bus) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/buses/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bus.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Bus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear el bus: ${response.body}');
    }
  }

  Future<Bus> obtenerBusPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/buses/$id'));

    if (response.statusCode == 200) {
      return Bus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener el bus: ${response.statusCode}');
    }
  }

  Future<Bus> actualizarBus(int id, Bus bus) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/buses/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bus.toJson()),
    );

    if (response.statusCode == 200) {
      return Bus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el bus: ${response.body}');
    }
  }

  Future<void> eliminarBus(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/buses/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar el bus: ${response.statusCode}');
    }
  }
}
