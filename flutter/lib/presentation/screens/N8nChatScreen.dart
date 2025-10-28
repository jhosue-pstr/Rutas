import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            debugPrint(
              'WebView error: ${error.errorType} - ${error.description}',
            );
          },
        ),
      )
      ..loadFlutterAsset('lib/assets/chat.html');

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
