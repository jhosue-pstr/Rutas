import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/noticia.dart';

class NoticiaService {
  //static const String baseUrl = 'http://localhost:9000/api'; // Ajusta tu URL
  static const String baseUrl = 'https://stagnant-makeda-hypodermically.ngrok-free.dev';

  Future<List<Noticia>> getNoticias({int offset = 0, int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/noticias/?offset=$offset&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Noticia.fromJson(data)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Noticia>> getNoticiasRecientes({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recientes/?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Noticia.fromJson(data)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Noticia> getNoticiaById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/noticias/$id'),
      );

      if (response.statusCode == 200) {
        return Noticia.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error ${response.statusCode}: noticia no encontrada');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 🔹 CREAR NOTICIA CON IMAGEN - CORREGIDO
  Future<Noticia> createNoticia({
    required String nombre,
    required String descripcion,
    required File imagen,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/noticias/'),
      );

      // Agregar campos de texto
      request.fields['nombre'] = nombre;
      request.fields['descripcion'] = descripcion;

      // Agregar archivo de imagen
      var imagenStream = http.ByteStream(imagen.openRead());
      var imagenLength = await imagen.length();
      var multipartFile = http.MultipartFile(
        'imagen',
        imagenStream,
        imagenLength,
        filename: 'noticia_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);

      // Enviar request y procesar respuesta
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Noticia.fromJson(json.decode(responseString));
      } else {
        throw Exception('Error ${response.statusCode}: $responseString');
      }
    } catch (e) {
      throw Exception('Error creando noticia: $e');
    }
  }

  // 🔹 ACTUALIZAR NOTICIA - CORREGIDO
  Future<Noticia> updateNoticia({
    required int id,
    String? nombre,
    String? descripcion,
    File? imagen,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/api/noticias/$id'),
      );

      // Agregar campos de texto
      if (nombre != null) request.fields['nombre'] = nombre;
      if (descripcion != null) request.fields['descripcion'] = descripcion;

      // Agregar archivo si se proporciona
      if (imagen != null) {
        var imagenStream = http.ByteStream(imagen.openRead());
        var imagenLength = await imagen.length();
        var multipartFile = http.MultipartFile(
          'imagen',
          imagenStream,
          imagenLength,
          filename: 'noticia_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      // Enviar request
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return Noticia.fromJson(json.decode(responseString));
      } else {
        throw Exception('Error ${response.statusCode}: $responseString');
      }
    } catch (e) {
      throw Exception('Error actualizando noticia: $e');
    }
  }

  Future<void> deleteNoticia(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/noticias/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error eliminando noticia: $e');
    }
  }
}