import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class N8nChatScreen extends StatefulWidget {
  const N8nChatScreen({super.key});

  @override
  State<N8nChatScreen> createState() => _N8nChatScreenState();
}

class _N8nChatScreenState extends State<N8nChatScreen> {
  late WebViewController _controller;

  final String chatUrl =
      'https://fossillike-shad-nontoxic.ngrok-free.dev/webhook/108bc582-d48d-4a19-b2d4-90d0e07689ea/chat';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => debugPrint('✅ Chat cargado correctamente'),
          onWebResourceError: (err) =>
              debugPrint('❌ Error: ${err.description}'),
        ),
      )
      ..loadRequest(
        Uri.dataFromString(
          _html(),
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ),
      );
  }

  String _html() {
    return '''
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>n8n Chat</title>
      <link href="https://cdn.jsdelivr.net/npm/@n8n/chat/dist/style.css" rel="stylesheet" />
      <style>
        html, body { height: 100%; margin: 0; background-color: #f9f9f9; }
        #n8n-chat { height: 100vh; }
      </style>
    </head>
    <body>
      <div id="n8n-chat"></div>
      <script type="module">
        import { createChat } from 'https://cdn.jsdelivr.net/npm/@n8n/chat/dist/chat.bundle.es.js';

        const chat = createChat({
          webhookUrl: '$chatUrl',
          target: '#n8n-chat',
          mode: 'fullscreen',
          theme: {
            primaryColor: '#7b4fff'
          },
        });

        // Log para verificar envío de mensajes
        chat.on('messageSent', (msg) => console.log('💬 Enviado:', msg));
        chat.on('messageReceived', (msg) => console.log('📩 Recibido:', msg));
      </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat n8n'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
