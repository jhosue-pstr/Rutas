import 'dart:async';
import 'dart:convert';
import 'package:rutasfrontend/data/models/ubicacion_bus.dart';
import 'package:rutasfrontend/data/services/simulacion_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SimulacionController {
  final SimulacionService _simulacionService = SimulacionService();
  WebSocketChannel? _channel;
  StreamController<Map<String, UbicacionBus>> _ubicacionesController =
      StreamController<Map<String, UbicacionBus>>.broadcast();

  Timer? _pingTimer;
  bool _conectado = false;

  Stream<Map<String, UbicacionBus>> get ubicacionesStream =>
      _ubicacionesController.stream;

  Future<void> conectarWebSocket() async {
    try {
      if (_conectado) return;

      _channel = _simulacionService.conectarWebSocket();
      _conectado = true;

      _channel!.stream.listen(
        _manejarMensajeWebSocket,
        onError: _manejarErrorWebSocket,
        onDone: _manejarConexionCerrada,
      );

      _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
        if (_conectado) {
          _simulacionService.enviarPing(_channel!);
        }
      });

      print('✅ WebSocket conectado para ubicaciones en tiempo real');
    } catch (e) {
      print('❌ Error conectando WebSocket: $e');
      _conectado = false;
      throw Exception('No se pudo conectar al servidor de ubicaciones');
    }
  }

  void desconectarWebSocket() {
    _pingTimer?.cancel();
    _channel?.sink.close();
    _conectado = false;
    print('🔌 WebSocket desconectado');
  }

  void _manejarMensajeWebSocket(dynamic mensaje) {
    try {
      final data = json.decode(mensaje);

      if (data['type'] == 'ubicaciones_buses') {
        final ubicacionesData = Map<String, dynamic>.from(data['data']);
        final ubicaciones = <String, UbicacionBus>{};

        ubicacionesData.forEach((key, value) {
          try {
            ubicaciones[key] = UbicacionBus.fromJson(
              Map<String, dynamic>.from(value),
            );
          } catch (e) {
            print('Error parseando ubicación del bus $key: $e');
          }
        });

        _ubicacionesController.add(ubicaciones);
      }
    } catch (e) {
      print('Error procesando mensaje WebSocket: $e');
    }
  }

  void _manejarErrorWebSocket(error) {
    print('❌ Error en WebSocket: $error');
    _conectado = false;
    Timer(Duration(seconds: 5), () {
      if (!_conectado) {
        conectarWebSocket();
      }
    });
  }

  void _manejarConexionCerrada() {
    print('🔌 Conexión WebSocket cerrada');
    _conectado = false;
    // Intentar reconectar
    Timer(Duration(seconds: 5), () {
      if (!_conectado) {
        conectarWebSocket();
      }
    });
  }

  Future<Map<String, UbicacionBus>> obtenerUbicacionesActuales() async {
    try {
      final data = await _simulacionService.obtenerUbicacionesActuales();
      final ubicaciones = <String, UbicacionBus>{};

      data.forEach((key, value) {
        ubicaciones[key] = UbicacionBus.fromJson(
          Map<String, dynamic>.from(value),
        );
      });

      return ubicaciones;
    } catch (e) {
      throw Exception('Error obteniendo ubicaciones actuales: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerEstadoSimulacion() async {
    try {
      return await _simulacionService.obtenerEstadoSimulacion();
    } catch (e) {
      throw Exception('Error obteniendo estado de simulación: $e');
    }
  }

  Future<void> detenerSimulacion() async {
    try {
      await _simulacionService.detenerSimulacion();
    } catch (e) {
      throw Exception('Error deteniendo simulación: $e');
    }
  }

  void dispose() {
    desconectarWebSocket();
    _ubicacionesController.close();
    _pingTimer?.cancel();
  }

  bool get estaConectado => _conectado;
}
