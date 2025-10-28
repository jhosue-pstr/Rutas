import '../../data/models/usuario.dart';
import '../../data/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> loginUsuario(
    String correo,
    String contrasena,
  ) async {
    return await _authService.login(correo, contrasena);
  }

  Future<Usuario> registrarUsuario(Usuario usuario) async {
    return await _authService.register(usuario);
  }

  Future<bool> verificarSesion() async {
    return await _authService.isTokenValid();
  }

  Future<void> cerrarSesion() async {
    await _authService.logout();
  }
}
