import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final String? token;
  final Map<String, dynamic>? user;

  OnboardingScreen({Key? key, this.token, this.user}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Página 1', style: TextStyle(fontSize: 24))),
    Center(child: Text('Página 2', style: TextStyle(fontSize: 24))),
    Center(child: Text('Página 3', style: TextStyle(fontSize: 24))),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Aquí podrías navegar a tu pantalla principal
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: _pages,
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.blueAccent
                        : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: Text(
                _currentPage == _pages.length - 1 ? 'Finalizar' : 'Siguiente',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
