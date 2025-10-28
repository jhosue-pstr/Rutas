import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chofer.dart';

class ChoferService {
  //static const String baseUrl = 'http://localhost:9000/api'; // Ajusta tu URL
  static const String baseUrl = 'https://stagnant-makeda-hypodermically.ngrok-free.dev';

  // 🔹 Obtener lista de choferes
  Future<List<Chofer>> getChoferes({int offset = 0, int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/choferes/?offset=$offset&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Chofer.fromJson(data)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 🔹 Obtener chofer por ID
  Future<Chofer> getChoferById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/choferes/$id'),
      );

      if (response.statusCode == 200) {
        return Chofer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error ${response.statusCode}: chofer no encontrado');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 🔹 CREAR CHOFER CON IMÁGENES (MULTIPART) - CORREGIDO
  Future<Chofer> createChofer({
    required String nombre,
    String? apellido,
    String? dni,
    String? telefono,
    File? foto,
    File? qrPago,
    File? licenciaImg,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/choferes/'),
      );

      // Agregar campos de texto
      request.fields['nombre'] = nombre;
      if (apellido != null && apellido.isNotEmpty) {
        request.fields['apellido'] = apellido;
      }
      if (dni != null && dni.isNotEmpty) {
        request.fields['dni'] = dni;
      }
      if (telefono != null && telefono.isNotEmpty) {
        request.fields['telefono'] = telefono;
      }

      // Agregar archivos si existen
      if (foto != null) {
        var fotoStream = http.ByteStream(foto.openRead());
        var fotoLength = await foto.length();
        var multipartFile = http.MultipartFile(
          'foto',
          fotoStream,
          fotoLength,
          filename: 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      if (qrPago != null) {
        var qrStream = http.ByteStream(qrPago.openRead());
        var qrLength = await qrPago.length();
        var multipartFile = http.MultipartFile(
          'qr_pago',
          qrStream,
          qrLength,
          filename: 'qr_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      if (licenciaImg != null) {
        var licenciaStream = http.ByteStream(licenciaImg.openRead());
        var licenciaLength = await licenciaImg.length();
        var multipartFile = http.MultipartFile(
          'licencia_img',
          licenciaStream,
          licenciaLength,
          filename: 'licencia_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      // Enviar request y procesar respuesta
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Chofer.fromJson(json.decode(responseString));
      } else {
        throw Exception('Error ${response.statusCode}: $responseString');
      }
    } catch (e) {
      throw Exception('Error creando chofer: $e');
    }
  }

  // 🔹 ACTUALIZAR CHOFER CON IMÁGENES - CORREGIDO
  Future<Chofer> updateChofer({
    required int id,
    String? nombre,
    String? apellido,
    String? dni,
    String? telefono,
    File? foto,
    File? qrPago,
    File? licenciaImg,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/api/choferes/$id'),
      );

      // Agregar campos de texto
      if (nombre != null) request.fields['nombre'] = nombre;
      if (apellido != null) request.fields['apellido'] = apellido;
      if (dni != null) request.fields['dni'] = dni;
      if (telefono != null) request.fields['telefono'] = telefono;

      // Agregar archivos si existen
      if (foto != null) {
        var fotoStream = http.ByteStream(foto.openRead());
        var fotoLength = await foto.length();
        var multipartFile = http.MultipartFile(
          'foto',
          fotoStream,
          fotoLength,
          filename: 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      if (qrPago != null) {
        var qrStream = http.ByteStream(qrPago.openRead());
        var qrLength = await qrPago.length();
        var multipartFile = http.MultipartFile(
          'qr_pago',
          qrStream,
          qrLength,
          filename: 'qr_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      if (licenciaImg != null) {
        var licenciaStream = http.ByteStream(licenciaImg.openRead());
        var licenciaLength = await licenciaImg.length();
        var multipartFile = http.MultipartFile(
          'licencia_img',
          licenciaStream,
          licenciaLength,
          filename: 'licencia_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      // Enviar request
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return Chofer.fromJson(json.decode(responseString));
      } else {
        throw Exception('Error ${response.statusCode}: $responseString');
      }
    } catch (e) {
      throw Exception('Error actualizando chofer: $e');
    }
  }

  // 🔹 ELIMINAR CHOFER
  Future<void> deleteChofer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/choferes/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error eliminando chofer: $e');
    }
  }

  // 🔹 Método auxiliar para crear chofer sin imágenes (solo datos básicos)
  Future<Chofer> createChoferSimple(Chofer chofer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/choferes/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': chofer.nombre,
          'apellido': chofer.apellido,
          'dni': chofer.dni,
          'telefono': chofer.telefono,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Chofer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creando chofer: $e');
    }
  }
}