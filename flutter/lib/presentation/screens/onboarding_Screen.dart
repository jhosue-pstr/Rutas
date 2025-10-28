import 'package:flutter/material.dart';
import 'package:rutasfrontend/presentation/screens/DibujarRutasScreen.dart';
import 'package:rutasfrontend/presentation/screens/N8nChatScreen.dart';
import 'package:rutasfrontend/presentation/screens/home_screen.dart';
import 'package:rutasfrontend/presentation/screens/ver_rutas_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final String? token;
  final Map<String, dynamic>? user;

  const OnboardingScreen({Key? key, this.token, this.user}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Definición de colores según tu paleta
  final Color _azulPrincipal = const Color(0xFF3F51B5);
  final Color _verdeBrillante = const Color(0xFF8BC34A);
  final Color _naranjaDinamico = const Color(0xFFFF9800);
  final Color _azulCielo = const Color(0xFF2196F3);
  final Color _grisNeutro = const Color(0xFFE0E0E0);
  final Color _grisTexto = const Color(0xFF424242);

  final List<Widget> _pages = [
    _OnboardingPage(
      imagePath: 'lib/assets/saludo.jpeg',
      title: '¡Bienvenido a RutasApp!',
      description:
          'La forma más inteligente de navegar por la ciudad. Encuentra rutas de buses en tiempo real y planifica tus viajes fácilmente.',
      color: Color(0xFF3F51B5),
    ),
    _OnboardingPage(
      imagePath: 'lib/assets/logo1.jpeg',
      title: 'Rutas en Tiempo Real',
      description:
          'Visualiza la ubicación exacta de los buses en el mapa y sigue su recorrido en vivo. Nunca más pierdas tu transporte.',
      color: Color(0xFF2196F3),
    ),
    _OnboardingPage(
      imagePath: 'lib/assets/logo2.png',
      title: 'Planifica tu Viaje',
      description:
          'Encuentra las mejores rutas, calcula tiempos de llegada y recibe notificaciones importantes sobre tu transporte.',
      color: Color(0xFFFF9800),
    ),
    _OnboardingPage(
      imagePath: 'lib/assets/logo3.jpeg',
      title: '¡Comienza tu Aventura!',
      description:
          'Todo está listo para que explores la ciudad de manera más eficiente. Tu transporte ideal te espera.',
      color: Color(0xFF8BC34A),
      isLast: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  void _skipToEnd() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: _pages,
            ),

            // Indicadores de página
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? _azulPrincipal
                          : _grisNeutro,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Botón Saltar
            if (_currentPage < _pages.length - 1)
              Positioned(
                top: 10,
                right: 20,
                child: TextButton(
                  onPressed: _skipToEnd,
                  child: Text(
                    'Saltar',
                    style: TextStyle(
                      color: _grisTexto,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            // Botones de navegación
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // Botón Atrás
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _azulPrincipal,
                          side: BorderSide(color: _azulPrincipal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Atrás',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _azulPrincipal,
                          ),
                        ),
                      ),
                    ),

                  if (_currentPage > 0) const SizedBox(width: 12),

                  // Botón Siguiente/Finalizar
                  Expanded(
                    flex: _currentPage > 0 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage] is _OnboardingPage
                            ? (_pages[_currentPage] as _OnboardingPage).color
                            : _azulPrincipal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Comenzar'
                            : 'Siguiente',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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
}

class _OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final Color color;
  final bool isLast;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: color.withOpacity(0.1),
                    child: Icon(_getIconForPage(), size: 100, color: color),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Título
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          // Descripción
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF424242),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),

          // Elemento decorativo adicional para la última página
          if (isLast)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_rounded, color: color, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '¡Listo para explorar!',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForPage() {
    switch (title) {
      case '¡Bienvenido a RutasApp!':
        return Icons.waving_hand_rounded;
      case 'Rutas en Tiempo Real':
        return Icons.location_on_rounded;
      case 'Planifica tu Viaje':
        return Icons.route_rounded;
      case '¡Comienza tu Aventura!':
        return Icons.rocket_launch_rounded;
      default:
        return Icons.directions_bus_rounded;
    }
  }
}
