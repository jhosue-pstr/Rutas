// data/services/simulacion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/constants/api.dart';

class SimulacionService {
  Future<Map<String, dynamic>> obtenerUbicacionesActuales() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/simulacion/ubicaciones'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener ubicaciones: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> obtenerEstadoSimulacion() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/simulacion/estado'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener estado: ${response.statusCode}');
    }
  }

  Future<void> detenerSimulacion() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/simulacion/detener'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al detener simulación: ${response.statusCode}');
    }
  }

  // ========== WEBSOCKET ==========

  WebSocketChannel conectarWebSocket() {
    try {
      // Solución robusta que maneja cualquier caso
      String wsUrl = _convertirBaseUrlAWebSocket(baseUrl);

      print('🔗 Conectando WebSocket a: $wsUrl');

      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      return channel;
    } catch (e) {
      print('❌ Error en conectarWebSocket: $e');
      throw Exception('Error conectando WebSocket: $e');
    }
  }

  String _convertirBaseUrlAWebSocket(String url) {
    // Si ya es una URL completa de WebSocket, dejarla igual
    if (url.startsWith('ws://') || url.startsWith('wss://')) {
      return '$url/api/simulacion/ws/ubicaciones-buses';
    }

    // Convertir HTTP/HTTPS a WS/WSS
    if (url.startsWith('https://')) {
      String dominio = url.replaceFirst('https://', '');
      return 'wss://$dominio/api/simulacion/ws/ubicaciones-buses';
    } else if (url.startsWith('http://')) {
      String dominio = url.replaceFirst('http://', '');
      return 'ws://$dominio/api/simulacion/ws/ubicaciones-buses';
    }

    // Si no tiene protocolo, asumir desarrollo local con WS
    return 'ws://$url/api/simulacion/ws/ubicaciones-buses';
  }

  // Enviar ping para mantener conexión activa
  void enviarPing(WebSocketChannel channel) {
    try {
      channel.sink.add('ping');
    } catch (e) {
      print('Error enviando ping: $e');
    }
  }

  void desconectarWebSocket(WebSocketChannel channel) {
    try {
      channel.sink.close();
    } catch (e) {
      print('Error desconectando WebSocket: $e');
    }
  }
}
