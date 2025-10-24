// import 'package:flutter/material.dart';
// import 'presentation/screens/login_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LoginScreen(),
//       theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar dotenv y verificar que el archivo exista
  try {
    await dotenv.load(fileName: ".env");
    if (dotenv.env['GOOGLE_MAPS_API_KEY'] == null) {
      throw Exception("No se encontró GOOGLE_MAPS_API_KEY en el archivo .env");
    }
  } catch (e) {
    print("Error cargando .env: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
    );
  }
}
