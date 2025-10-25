import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api.dart';
import '../models/bus.dart';

class BusService {
  Future<List<Bus>> obtenerBuses(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/buses/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Bus.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los buses');
    }
  }

  Future<Bus> crearBus(Bus bus, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/buses/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(bus.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Bus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear el bus');
    }
  }

  Future<Bus> obtenerBusPorId(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/buses/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Bus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener el bus');
    }
  }

  Future<Bus> actualizarBus(int id, Bus bus, String token) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/buses/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(bus.toJson()),
    );

    if (response.statusCode == 200) {
      return Bus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el bus');
    }
  }

  Future<void> eliminarBus(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/buses/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar el bus');
    }
  }
}
