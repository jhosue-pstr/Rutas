// import 'package:flutter/material.dart';
// import '../controllers/auth_controller.dart';
// import '../../data/models/usuario.dart';
// import 'login_screen.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({Key? key}) : super(key: key);

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final AuthController _authController = AuthController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   final _nombreController = TextEditingController();
//   final _apellidoController = TextEditingController();
//   final _correoController = TextEditingController();
//   final _contrasenaController = TextEditingController();
//   final _confirmarContrasenaController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Card(
//               elevation: 8,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Logo o ícono
//                       Icon(
//                         Icons.person_add,
//                         size: 80,
//                         color: Colors.deepPurple[700],
//                       ),
//                       const SizedBox(height: 16),

//                       // Título
//                       Text(
//                         'Crear Cuenta',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.deepPurple[700],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Regístrate para comenzar',
//                         style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                       ),
//                       const SizedBox(height: 32),

//                       // Campo Nombre
//                       _buildTextField(
//                         controller: _nombreController,
//                         label: 'Nombre',
//                         icon: Icons.person,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Por favor ingresa tu nombre';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Campo Apellido
//                       _buildTextField(
//                         controller: _apellidoController,
//                         label: 'Apellido',
//                         icon: Icons.person_outline,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Por favor ingresa tu apellido';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Campo Correo
//                       _buildTextField(
//                         controller: _correoController,
//                         label: 'Correo Electrónico',
//                         icon: Icons.email,
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Por favor ingresa tu correo';
//                           }
//                           if (!value.contains('@')) {
//                             return 'Ingresa un correo válido';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Campo Contraseña
//                       _buildTextField(
//                         controller: _contrasenaController,
//                         label: 'Contraseña',
//                         icon: Icons.lock,
//                         obscureText: true,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Por favor ingresa tu contraseña';
//                           }
//                           if (value.length < 6) {
//                             return 'La contraseña debe tener al menos 6 caracteres';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Campo Confirmar Contraseña
//                       _buildTextField(
//                         controller: _confirmarContrasenaController,
//                         label: 'Confirmar Contraseña',
//                         icon: Icons.lock_outline,
//                         obscureText: true,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Por favor confirma tu contraseña';
//                           }
//                           if (value != _contrasenaController.text) {
//                             return 'Las contraseñas no coinciden';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 32),

//                       // Botón de Registro
//                       _isLoading
//                           ? const CircularProgressIndicator()
//                           : SizedBox(
//                               width: double.infinity,
//                               height: 50,
//                               child: ElevatedButton(
//                                 onPressed: _register,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.deepPurple[700],
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'Registrarse',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                       const SizedBox(height: 20),

//                       // Enlace para ir a Login
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '¿Ya tienes cuenta? ',
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                           GestureDetector(
//                             onTap: _goToLogin,
//                             child: Text(
//                               'Inicia Sesión',
//                               style: TextStyle(
//                                 color: Colors.deepPurple[700],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.deepPurple[700]),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.deepPurple[700]!),
//         ),
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//     );
//   }

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final usuario = Usuario(
//         idUsuario: 0,
//         nombre: _nombreController.text.trim(),
//         apellido: _apellidoController.text.trim(),
//         correo: _correoController.text.trim(),
//         contrasena: _contrasenaController.text.trim(),
//         fechaRegistro: DateTime.now(),
//         estado: true,
//       );

//       await _authController.registrarUsuario(usuario);
//       _showSuccessDialog('¡Registro exitoso! Ahora puedes iniciar sesión');

//       // Ir al login después del registro exitoso
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     } catch (e) {
//       _showErrorDialog(e.toString());
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _goToLogin() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//     );
//   }

//   void _showSuccessDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Éxito'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message.replaceAll('Exception: ', '')),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nombreController.dispose();
//     _apellidoController.dispose();
//     _correoController.dispose();
//     _contrasenaController.dispose();
//     _confirmarContrasenaController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../../data/models/usuario.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  // Definición de colores según tu paleta
  final Color _azulPrincipal = const Color(0xFF3F51B5);
  final Color _verdeBrillante = const Color(0xFF8BC34A);
  final Color _naranjaDinamico = const Color(0xFFFF9800);
  final Color _azulCielo = const Color(0xFF2196F3);
  final Color _grisNeutro = const Color(0xFFE0E0E0);
  final Color _grisTexto = const Color(0xFF424242);

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

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
                      // Logo desde assets
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _azulCielo.withOpacity(0.1),
                          border: Border.all(color: _azulCielo, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'lib/assets/saludo2.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: _azulCielo.withOpacity(0.1),
                                child: Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 80,
                                  color: _azulPrincipal,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Título
                      Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _azulPrincipal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Regístrate para comenzar',
                        style: TextStyle(fontSize: 16, color: _grisTexto),
                      ),
                      const SizedBox(height: 32),

                      // Campo Nombre
                      _buildTextField(
                        controller: _nombreController,
                        label: 'Nombre',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo Apellido
                      _buildTextField(
                        controller: _apellidoController,
                        label: 'Apellido',
                        icon: Icons.person_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu apellido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo Correo
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
                      const SizedBox(height: 16),

                      // Campo Contraseña
                      _buildPasswordField(
                        controller: _contrasenaController,
                        label: 'Contraseña',
                        isConfirm: false,
                      ),
                      const SizedBox(height: 16),

                      // Campo Confirmar Contraseña
                      _buildPasswordField(
                        controller: _confirmarContrasenaController,
                        label: 'Confirmar Contraseña',
                        isConfirm: true,
                      ),
                      const SizedBox(height: 32),

                      // Botón de Registro
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
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _azulPrincipal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: _azulPrincipal.withOpacity(0.3),
                                ),
                                child: const Text(
                                  'Registrarse',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 24),

                      // Enlace para ir a Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(color: _grisTexto, fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: _goToLogin,
                            child: Text(
                              'Inicia Sesión',
                              style: TextStyle(
                                color: _azulPrincipal,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isConfirm,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isConfirm ? _obscureConfirmText : _obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        if (isConfirm && value != _contrasenaController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
      style: TextStyle(color: _grisTexto, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _grisTexto.withOpacity(0.7)),
        prefixIcon: Icon(
          isConfirm ? Icons.lock_outline : Icons.lock_outlined,
          color: _azulPrincipal,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isConfirm
                ? _obscureConfirmText
                      ? Icons.visibility_off
                      : Icons.visibility
                : _obscureText
                ? Icons.visibility_off
                : Icons.visibility,
            color: _grisTexto.withOpacity(0.5),
          ),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                _obscureConfirmText = !_obscureConfirmText;
              } else {
                _obscureText = !_obscureText;
              }
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final usuario = Usuario(
        idUsuario: 0,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        contrasena: _contrasenaController.text.trim(),
        fechaRegistro: DateTime.now(),
        estado: true,
      );

      await _authController.registrarUsuario(usuario);
      _showSuccessDialog('¡Registro exitoso! Ahora puedes iniciar sesión');

      // Ir al login después del registro exitoso
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }
}
