import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  late final WebViewController controller;
  final TextEditingController urlController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            setState(() => isLoading = true);
            urlController.text = url;
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false);
            urlController.text = url;
          },
        ),
      );
  }

  void navegar() {
    String texto = urlController.text.trim();

    if (texto.isEmpty) return;

    if (!texto.startsWith('http://') && !texto.startsWith('https://')) {
      texto = 'https://$texto';
    }

    final Uri? uri = Uri.tryParse(texto);

    if (uri != null) {
      controller.loadRequest(uri);
    }
  }

  Future<void> atras() async {
    if (await controller.canGoBack()) await controller.goBack();
  }

  Future<void> adelante() async {
    if (await controller.canGoForward()) await controller.goForward();
  }

  Future<void> recargar() async {
    await controller.reload();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00695C);
    const Color accentColor = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: atras,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    tooltip: 'Atrás',
                  ),
                  IconButton(
                    onPressed: adelante,
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    tooltip: 'Adelante',
                  ),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: urlController,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) => navegar(),
                        decoration: InputDecoration(
                          hintText: 'Escribir dirección web',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                          prefixIcon: const Icon(
                            Icons.language,
                            color: primaryColor,
                            size: 21,
                          ),
                          suffixIcon: IconButton(
                            onPressed: navegar,
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: primaryColor,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: recargar,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Recargar',
                  ),
                ],
              ),
            ),
            if (isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            Expanded(
              child: WebViewWidget(
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}