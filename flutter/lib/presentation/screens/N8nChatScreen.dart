// lib/presentation/screens/n8n_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Opcional (solo Android): depuración del WebView
import 'package:webview_flutter_android/webview_flutter_android.dart';

class N8nChatScreen extends StatefulWidget {
  const N8nChatScreen({super.key});

  @override
  State<N8nChatScreen> createState() => _N8nChatScreenState();
}

class _N8nChatScreenState extends State<N8nChatScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)   // JS habilitado
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            // Útil para ver errores de carga
            debugPrint('WebView error: ${error.errorType} - ${error.description}');
          },
        ),
      )
      // 👇 Carga el HTML desde tus assets (ruta exacta tal como está en pubspec)
      ..loadFlutterAsset('lib/assets/chat2.html');

    // (Opcional) Activa debugging de WebView en Android
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat de n8n')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
