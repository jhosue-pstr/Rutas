import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapa Flutter',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const MapaScreen(),
    );
  }
}

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Buses 🚍')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(-15.47353, -70.12007), // Ejemplo: Juliaca, Perú
          initialZoom: 13,
        ),
        children: [
          // ✅ 1. URL oficial y correcta del servidor OSM
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

            // ✅ 2. Identificador de tu app para cumplir con "User-Agent"
            //    - Usa el dominio o nombre de tu proyecto (no de ejemplo)
            userAgentPackageName: 'com.miempresa.miaplicacion',

            // ✅ 3. Buenas prácticas extra (recomendado por OSM)
            subdomains: const [], // sin subdominios
            maxZoom: 19,
            tileSize: 256,
          ),

          // ✅ 4. Atribución visible (obligatoria)
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                '© OpenStreetMap contributors',
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              TextSourceAttribution(
                'Reportar un error en el mapa',
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/fixthemap'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
