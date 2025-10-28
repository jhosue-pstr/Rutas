import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class N8nChatScreen extends StatefulWidget {
  const N8nChatScreen({super.key});

  @override
  State<N8nChatScreen> createState() => _N8nChatScreenState();
}

class _N8nChatScreenState extends State<N8nChatScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasInternet = true;

  final String _chatHTML = '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat n8n</title>
    <link href="https://cdn.jsdelivr.net/npm/@n8n/chat/dist/style.css" rel="stylesheet" />
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: transparent;
        }
        #n8n-chat-container {
            width: 100vw;
            height: 100vh;
            border: none;
        }
        .loading {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            color: #666;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <div id="n8n-chat-container"></div>
    
    <script type="module">
        import { createChat } from 'https://cdn.jsdelivr.net/npm/@n8n/chat/dist/chat.bundle.es.js';

        // Configuración del chat
        createChat({
            webhookUrl: 'https://claudie-unpresumptive-gaugeably.ngrok-free.dev/webhook/108bc582-d48d-4a19-b2d4-90d0e07689ea/chat',
            target: '#n8n-chat-container',
            mode: 'bubble',
            welcomeMessage: {
                text: '¡Hola! ¿En qué puedo ayudarte hoy?',
            },
            chatInput: {
                enabled: true,
                placeholder: 'Escribe tu mensaje...',
            },
            theme: {
                light: {
                    primary: '#4F46E5', // Color indigo
                    background: '#FFFFFF',
                    text: '#1F2937',
                },
                dark: {
                    primary: '#4F46E5',
                    background: '#1F2937',
                    text: '#F9FAFB',
                }
            }
        });

        // Notificar a Flutter cuando el chat esté listo
        setTimeout(() => {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('chatLoaded');
            }
        }, 2000);
    </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte Chat'),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshChat),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_hasInternet) {
      return _buildNoInternet();
    }

    return Stack(
      children: [
        WebViewWidget(
          controller: _controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(Colors.transparent)
            ..loadHtmlString(_chatHTML)
            ..addJavaScriptChannel(
              'ChatChannel',
              onMessageReceived: (message) {
                if (message.message == 'chatLoaded') {
                  setState(() => _isLoading = false);
                }
              },
            ),
        ),
        if (_isLoading) _buildLoadingIndicator(),
      ],
    );
  }

  Widget _buildNoInternet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Sin conexión a Internet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Necesitas conexión para usar el chat',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _checkConnectivity,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando chat...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshChat() {
    setState(() => _isLoading = true);
    _controller.reload();
  }
}
