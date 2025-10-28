import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api.dart';

class ApiService {
  Future<dynamic> getData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener datos');
    }
  }
}
