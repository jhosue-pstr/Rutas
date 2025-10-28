import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusquedaWidget extends StatefulWidget {
  final TextEditingController origenCtrl;
  final TextEditingController destinoCtrl;
  final Function() onSeleccionarOrigen;
  final Function() onSeleccionarDestino;
  final Function(LatLng?, bool)? onDireccionEncontrada;

  final Function(bool) onLoadingChange;

  const BusquedaWidget({
    Key? key,
    required this.origenCtrl,
    required this.destinoCtrl,
    required this.onSeleccionarOrigen,
    required this.onSeleccionarDestino,
    required this.onLoadingChange,
    this.onDireccionEncontrada, // ✅ NUEVO
  }) : super(key: key);

  @override
  State<BusquedaWidget> createState() => _BusquedaWidgetState();
}

class _BusquedaWidgetState extends State<BusquedaWidget> {
  final String apiKey = "AIzaSyBu-nZsShTYeztqo_so258P725jgZB-B5M";

  List<String> _sugerenciasOrigen = [];
  List<String> _sugerenciasDestino = [];

  bool _mostrarSugerenciasOrigen = false;
  bool _mostrarSugerenciasDestino = false;

  Future<List<String>> _buscarLugares(String input) async {
    if (input.isEmpty) return [];

    try {
      final url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
          "input=${Uri.encodeComponent(input)}"
          "&location=-15.47353,-70.12007"
          "&radius=10000"
          "&components=country:pe"
          "&key=$apiKey";

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == "OK") {
          return List<String>.from(
            data['predictions'].map((p) => p['description']),
          );
        }
      }
    } catch (e) {
      print('Error buscando lugares: $e');
    }
    return [];
  }

  Future<LatLng?> _geocode(String direccion) async {
    try {
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(direccion)}&key=$apiKey";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == "OK" && data['results'].isNotEmpty) {
          final loc = data['results'][0]['geometry']['location'];
          return LatLng(loc['lat'], loc['lng']);
        }
      }
    } catch (e) {
      print('Error geocoding: $e');
    }
    return null;
  }

  void _limpiarOrigen() {
    setState(() {
      widget.origenCtrl.clear();
      _sugerenciasOrigen = [];
      _mostrarSugerenciasOrigen = false;
    });
  }

  void _limpiarDestino() {
    setState(() {
      widget.destinoCtrl.clear();
      _sugerenciasDestino = [];
      _mostrarSugerenciasDestino = false;
    });
  }

  Widget _buildCampoBusqueda({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool esOrigen,
    required VoidCallback onClear,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Color(0xFF424242).withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: IconButton(
                icon: Icon(icon, color: Color(0xFF3F51B5)),
                onPressed: esOrigen
                    ? widget.onSeleccionarOrigen
                    : widget.onSeleccionarDestino,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: Color(0xFF424242)),
                      onPressed: onClear,
                    )
                  : null,
            ),
            onChanged: (value) async {
              if (value.isNotEmpty) {
                final sugerencias = await _buscarLugares(value);
                setState(() {
                  if (esOrigen) {
                    _sugerenciasOrigen = sugerencias;
                    _mostrarSugerenciasOrigen = true;
                  } else {
                    _sugerenciasDestino = sugerencias;
                    _mostrarSugerenciasDestino = true;
                  }
                });
              } else {
                setState(() {
                  if (esOrigen) {
                    _mostrarSugerenciasOrigen = false;
                  } else {
                    _mostrarSugerenciasDestino = false;
                  }
                });
              }
            },
          ),
          if ((esOrigen &&
                  _mostrarSugerenciasOrigen &&
                  _sugerenciasOrigen.isNotEmpty) ||
              (!esOrigen &&
                  _mostrarSugerenciasDestino &&
                  _sugerenciasDestino.isNotEmpty))
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: (esOrigen ? _sugerenciasOrigen : _sugerenciasDestino)
                    .map(
                      (sugerencia) => ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.location_on,
                          color: Color(0xFF2196F3),
                          size: 20,
                        ),
                        title: Text(sugerencia, style: TextStyle(fontSize: 14)),
                        onTap: () async {
                          widget.onLoadingChange(true);
                          controller.text = sugerencia;
                          LatLng? pos = await _geocode(
                            sugerencia,
                          ); // ✅ OBTENER COORDENADAS
                          widget.onDireccionEncontrada?.call(
                            pos,
                            esOrigen,
                          ); // ✅ PASAR AL HOME
                          setState(() {
                            if (esOrigen) {
                              _mostrarSugerenciasOrigen = false;
                            } else {
                              _mostrarSugerenciasDestino = false;
                            }
                          });
                          widget.onLoadingChange(false);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCampoBusqueda(
            controller: widget.origenCtrl,
            hintText: 'Origen',
            icon: Icons.location_on,
            esOrigen: true,
            onClear: _limpiarOrigen,
          ),
          _buildCampoBusqueda(
            controller: widget.destinoCtrl,
            hintText: 'Destino',
            icon: Icons.flag,
            esOrigen: false,
            onClear: _limpiarDestino,
          ),
        ],
      ),
    );
  }
}
