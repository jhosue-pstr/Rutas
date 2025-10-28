// lib/presentation/screens/lugar_favorito_screen.dart
import 'package:flutter/material.dart';

class LugarFavoritoScreen extends StatefulWidget {
  final String? token;
  final Map<String, dynamic>? user;

  const LugarFavoritoScreen({Key? key, this.token, this.user})
    : super(key: key);

  @override
  State<LugarFavoritoScreen> createState() => _LugarFavoritoScreenState();
}

class _LugarFavoritoScreenState extends State<LugarFavoritoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Lugar Favorito'),
        backgroundColor: Color(0xFFE91E63), // Mismo color que en el drawer
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 80, color: Color(0xFFE91E63)),
            SizedBox(height: 20),
            Text(
              'Pantalla de Lugares Favoritos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Token: ${widget.token ?? "No disponible"}'),
            Text('Usuario: ${widget.user?['nombre'] ?? "Invitado"}'),
          ],
        ),
      ),
    );
  }
}
