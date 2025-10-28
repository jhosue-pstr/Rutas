import 'package:flutter/material.dart';
import 'package:rutasfrontend/presentation/screens/rutas_screen.dart';
import 'package:rutasfrontend/presentation/screens/DibujarRutasScreen.dart';
import 'package:rutasfrontend/presentation/screens/chofer_screen.dart';
import 'package:rutasfrontend/presentation/screens/noticias_screen.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final Map<String, dynamic>? user;

  const AppDrawer({Key? key, required this.currentRoute, this.user})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGuest = false;
    final userName = user?['nombre'] ?? 'Usuario';
    final userEmail = user?['correo'] ?? user?['email'] ?? 'usuario@email.com';

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF3F51B5), const Color(0xFF2196F3)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: const Color(0xFF3F51B5),
                      size: 35,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isGuest ? 'VISITANTE' : 'USUARIO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 LISTA DE OPCIONES CON NAVEGACIÓN CORRECTA
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 10),

                    _buildSectionTitle('Navegación Principal'),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.home_filled,
                      title: 'Inicio',
                      route: '/home',
                      isSelected: currentRoute == '/home',
                      color: const Color(0xFF3F51B5),
                      screen: const RutasScreen(), // 🔥 PANTALLA CORRECTA
                    ),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.map_outlined,
                      title: 'Ver Rutas',
                      route: '/rutas',
                      isSelected: currentRoute == '/rutas',
                      color: const Color(0xFF8BC34A),
                      screen: const RutasScreen(), // 🔥 PANTALLA CORRECTA
                    ),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.edit_road_rounded,
                      title: 'Dibujar Rutas',
                      route: '/dibujar-rutas',
                      isSelected: currentRoute == '/dibujar-rutas',
                      color: const Color(0xFFFF9800),
                      screen: const DibujarRutasScreen(), // 🔥 PANTALLA CORRECTA
                    ),

                    // 🔥 NUEVOS ITEMS DE FAVORITOS
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.favorite_border,
                      title: 'Añadir Lugar Favorito',
                      route: '/favoritos-lugar',
                      isSelected: currentRoute == '/favoritos-lugar',
                      color: const Color(0xFFE91E63),
                      screen: const RutasScreen(), // 🔥 TEMPORAL
                    ),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.directions_bus_outlined,
                      title: 'Añadir Bus Favorito',
                      route: '/favoritos-bus',
                      isSelected: currentRoute == '/favoritos-bus',
                      color: const Color(0xFF9C27B0),
                      screen: const RutasScreen(), // 🔥 TEMPORAL
                    ),

                    // 🔥 SECCIÓN DE GESTIÓN
                    const SizedBox(height: 20),
                    _buildSectionTitle('Gestión'),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.drive_eta_rounded,
                      title: 'Choferes',
                      route: '/choferes',
                      isSelected: currentRoute == '/choferes',
                      color: const Color(0xFF2196F3),
                      screen: const ChoferScreen(), // 🔥 PANTALLA CORRECTA
                    ),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.article_outlined,
                      title: 'Noticias',
                      route: '/noticias',
                      isSelected: currentRoute == '/noticias',
                      color: const Color(0xFF3F51B5),
                      screen: const NoticiasScreen(), // 🔥 PANTALLA CORRECTA
                    ),

                    // 🔥 SECCIÓN DE CONFIGURACIÓN
                    const SizedBox(height: 20),
                    _buildSectionTitle('Cuenta'),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.person_outline,
                      title: 'Mi Perfil',
                      route: '/perfil',
                      isSelected: currentRoute == '/perfil',
                      color: const Color(0xFF424242),
                      screen: const RutasScreen(), // 🔥 TEMPORAL
                    ),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.settings_outlined,
                      title: 'Configuración',
                      route: '/configuracion',
                      isSelected: currentRoute == '/configuracion',
                      color: const Color(0xFF424242),
                      screen: const RutasScreen(), // 🔥 TEMPORAL
                    ),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.help_outline,
                      title: 'Ayuda & Soporte',
                      route: '/ayuda',
                      isSelected: currentRoute == '/ayuda',
                      color: const Color(0xFF424242),
                      screen: const RutasScreen(), // 🔥 TEMPORAL
                    ),

                    // 🔥 NFC SCANNER
                    const SizedBox(height: 20),
                    _buildSectionTitle('Acciones Rápidas'),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.nfc,
                      title: 'Escanear NFC',
                      route: '/nfc',
                      isSelected: currentRoute == '/nfc',
                      color: const Color(0xFF8BC34A),
                      screen: const RutasScreen(), // 🔥 TEMPORAL
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 🔥 PIE DE PÁGINA
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.logout_rounded, color: Colors.white),
                      title: Text(
                        isGuest ? 'Salir de la App' : 'Cerrar Sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      onTap: () => _confirmarCerrarSesion(context, isGuest),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Rutas App v1.0',
                    style: TextStyle(
                      color: const Color(0xFF424242).withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 CONSTRUIR TÍTULO DE SECCIÓN
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF424242).withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // 🔥 CONSTRUIR ITEM DEL DRAWER - MEJORADO CON NAVEGACIÓN
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
    required Color color,
    required Widget screen, // 🔥 NUEVO PARÁMETRO: Pantalla destino
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: color.withOpacity(0.3), width: 1)
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isSelected ? Colors.white : color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF424242),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: isSelected
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(Icons.check, color: Colors.white, size: 12),
              )
            : Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFE0E0E0),
                size: 20,
              ),
        onTap: () {
          Navigator.pop(context); // Cerrar drawer primero
          
          // 🔥 NAVEGACIÓN CORRECTA - Usar pushReplacement para reemplazar la pantalla actual
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  // 🔥 CONFIRMAR CERRAR SESIÓN
  void _confirmarCerrarSesion(BuildContext context, bool isGuest) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout_rounded, color: Colors.red, size: 32),
              ),

              const SizedBox(height: 16),

              Text(
                isGuest ? '¿Salir de la App?' : 'Cerrar Sesión',
                style: TextStyle(
                  color: const Color(0xFF424242),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isGuest
                    ? 'Se cerrará la aplicación y volverás a la pantalla de inicio.'
                    : 'Tu sesión se cerrará y deberás iniciar sesión nuevamente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF424242).withOpacity(0.7),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF424242),
                        side: BorderSide(color: const Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        _mostrarMensajeCerrarSesion(context, isGuest);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(isGuest ? 'Salir' : 'Cerrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 MOSTRAR MENSAJE DE CERRAR SESIÓN
  void _mostrarMensajeCerrarSesion(BuildContext context, bool isGuest) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isGuest
                    ? '¡Hasta pronto! App cerrada.'
                    : 'Sesión cerrada exitosamente.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8BC34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}