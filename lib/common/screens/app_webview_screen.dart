import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const AppWebViewScreen({
    super.key,
    required this.url,
    this.title = "Web",
  });

  @override
  State<AppWebViewScreen> createState() => _AppWebViewScreenState();
}

class _AppWebViewScreenState extends State<AppWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    // iOS/Android both supported
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _errorText = null;
            });
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _errorText = error.description;
            });
          },
        ),
      );

    final fixedUrl = _normalizeUrl(widget.url);
    _controller.loadRequest(Uri.parse(fixedUrl));
  }

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }
    return "https://$trimmed";
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false; // don't pop screen
    }
    return true; // pop screen
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final canPop = await _handleBack();
        if (canPop && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_errorText == null)
              WebViewWidget(controller: _controller)
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        "Failed to load page",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorText!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _controller.reload(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),

            if (_isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.white,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
