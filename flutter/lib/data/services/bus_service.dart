import 'package:http/http.dart' as http;
import 'package:rutasfrontend/data/services/simulacion_service.dart';
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

  final SimulacionService _simulacionService = SimulacionService();

  Future<List<Bus>> obtenerBusesActivos() async {
    try {
      print('🔄 Obteniendo buses activos desde simulación...');

      final ubicaciones = await _simulacionService.obtenerUbicacionesActuales();
      final buses = <Bus>[];

      // Convertir el mapa de ubicaciones a lista de buses
      ubicaciones.forEach((busId, datosUbicacion) {
        try {
          final bus = _crearBusDesdeUbicacion(busId, datosUbicacion);
          if (bus.tieneUbicacionValida) {
            buses.add(bus);
          }
        } catch (e) {
          print('❌ Error creando bus $busId: $e');
        }
      });

      print('✅ ${buses.length} buses activos obtenidos desde simulación');
      return buses;
    } catch (e) {
      print('❌ Error obteniendo buses activos: $e');
      return [];
    }
  }

  // ✅ OBTENER BUSES POR RUTA ESPECÍFICA
  Future<List<Bus>> obtenerBusesPorRuta(int rutaId) async {
    try {
      final todosBuses = await obtenerBusesActivos();
      final busesRuta = todosBuses
          .where((bus) => bus.RutaId == rutaId)
          .toList();

      print('✅ ${busesRuta.length} buses encontrados para ruta $rutaId');
      return busesRuta;
    } catch (e) {
      print('❌ Error obteniendo buses por ruta: $e');
      return [];
    }
  }

  // ✅ CONVERTIR DATOS DE SIMULACIÓN A MODELO BUS
  Bus _crearBusDesdeUbicacion(String busId, dynamic datosUbicacion) {
    final Map<String, dynamic> datos = Map<String, dynamic>.from(
      datosUbicacion,
    );

    return Bus(
      IdBus: int.tryParse(busId) ?? 0,
      placa: datos['placa'] ?? 'BUS$busId',
      capacidad: 40, // Valor por defecto
      modelo: 'Modelo Simulado',
      marca: 'Marca Simulada',
      nombre: 'Bus $busId',
      numero: busId,
      RutaId: datos['rutaId'] != null
          ? int.tryParse(datos['rutaId'].toString())
          : null,
      latitud: datos['latitud'] != null
          ? double.tryParse(datos['latitud'].toString())
          : null,
      longitud: datos['longitud'] != null
          ? double.tryParse(datos['longitud'].toString())
          : null,
      activo: datos['activo'] ?? true,
      velocidad: datos['velocidad'] != null
          ? double.tryParse(datos['velocidad'].toString())
          : 25.0,
      ultimaActualizacion: DateTime.now(),
    );
  }

  // ✅ OBTENER BUSES ACTIVOS EN TIEMPO REAL (WebSocket)
  Stream<List<Bus>> obtenerBusesActivosEnTiempoReal() async* {
    try {
      final channel = _simulacionService.conectarWebSocket();

      await for (final mensaje in channel.stream) {
        try {
          final data = json.decode(mensaje);

          if (data['type'] == 'ubicaciones_buses') {
            final ubicacionesData = Map<String, dynamic>.from(data['data']);
            final buses = <Bus>[];

            ubicacionesData.forEach((busId, datosUbicacion) {
              try {
                final bus = _crearBusDesdeUbicacion(busId, datosUbicacion);
                if (bus.tieneUbicacionValida) {
                  buses.add(bus);
                }
              } catch (e) {
                print('❌ Error procesando bus $busId en tiempo real: $e');
              }
            });

            yield buses;
          }
        } catch (e) {
          print('❌ Error procesando mensaje WebSocket: $e');
        }
      }
    } catch (e) {
      print('❌ Error conectando WebSocket: $e');
      yield []; // Retornar lista vacía en caso de error
    }
  }
}
