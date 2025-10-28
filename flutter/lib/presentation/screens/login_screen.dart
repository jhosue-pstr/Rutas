import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rutasfrontend/presentation/screens/onboarding_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true;

  // Definición de colores según tu paleta
  final Color _azulPrincipal = const Color(0xFF3F51B5);
  final Color _verdeBrillante = const Color(0xFF8BC34A);
  final Color _naranjaDinamico = const Color(0xFFFF9800);
  final Color _azulCielo = const Color(0xFF2196F3);
  final Color _grisNeutro = const Color(0xFFE0E0E0);
  final Color _grisTexto = const Color(0xFF424242);

  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _grisNeutro,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 180, // Aumentado de 120 a 180
                        height: 180, // Aumentado de 120 a 180
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _azulCielo.withOpacity(0.1),
                          border: Border.all(color: _azulCielo, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'lib/assets/logo2.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.directions_bus_rounded,
                                size: 80,
                                color: _azulPrincipal,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _azulPrincipal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bienvenido de vuelta',
                        style: TextStyle(fontSize: 16, color: _grisTexto),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        controller: _correoController,
                        label: 'Correo Electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          if (!value.contains('@')) {
                            return 'Ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildPasswordField(),
                      const SizedBox(height: 32),

                      _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3F51B5),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _azulPrincipal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: _azulPrincipal.withOpacity(0.3),
                                ),
                                child: const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: _grisTexto.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'O',
                              style: TextStyle(
                                color: _grisTexto,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: _grisTexto.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: _goToRegister,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: _azulPrincipal, width: 2),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              fontSize: 18,
                              color: _azulPrincipal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botón de invitado
                      TextButton(
                        onPressed: _accederComoInvitado,
                        style: TextButton.styleFrom(
                          foregroundColor: _naranjaDinamico,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: _naranjaDinamico,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Acceder como invitado',
                              style: TextStyle(
                                fontSize: 16,
                                color: _naranjaDinamico,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Campo de texto reutilizable
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: _grisTexto, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _grisTexto.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: _azulPrincipal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _grisNeutro),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _grisNeutro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _azulPrincipal, width: 2),
        ),
        filled: true,
        fillColor: _grisNeutro.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }

  // Campo de contraseña con toggle de visibilidad
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _contrasenaController,
      obscureText: _obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        return null;
      },
      style: TextStyle(color: _grisTexto, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Contraseña',
        labelStyle: TextStyle(color: _grisTexto.withOpacity(0.7)),
        prefixIcon: Icon(Icons.lock_outline, color: _azulPrincipal),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: _grisTexto.withOpacity(0.5),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _grisNeutro),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _grisNeutro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _azulPrincipal, width: 2),
        ),
        filled: true,
        fillColor: _grisNeutro.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }

  // 🧠 Lógica de login con almacenamiento local
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authController.loginUsuario(
        _correoController.text.trim(),
        _contrasenaController.text.trim(),
      );

      final token = response['access_token'];
      final user = response['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('user', jsonEncode(user));

      _showSuccessDialog('¡Inicio de sesión exitoso!');
      _goToOnBoarding(context, token, user);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToOnBoarding(
    BuildContext context,
    String token,
    Map<String, dynamic> user,
  ) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(token: token, user: user),
      ),
    );
  }

  void _accederComoInvitado() async {
    // 👤 Datos temporales simulados para el invitado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', 'guest_token');
    await prefs.setString(
      'user',
      jsonEncode({
        'Nombre': 'Invitado',
        'Apellido': '',
        'Correo': 'invitado@ejemplo.com',
        'IdUsuario': 0,
        'rol': 'visitante',
      }),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(
          token: 'guest_token',
          user: {
            'Nombre': 'Invitado',
            'Apellido': '',
            'Correo': 'invitado@ejemplo.com',
            'IdUsuario': 0,
            'rol': 'visitante',
          },
        ),
      ),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Éxito',
          style: TextStyle(color: _verdeBrillante, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: TextStyle(color: _grisTexto)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: _azulPrincipal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Error',
          style: TextStyle(
            color: _naranjaDinamico,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message.replaceAll('Exception: ', ''),
          style: TextStyle(color: _grisTexto),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: _azulPrincipal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}
