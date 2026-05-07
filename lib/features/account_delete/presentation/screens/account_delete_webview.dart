import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client_login_manager/client_login_manager.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import 'package:webview_flutter/webview_flutter.dart';


class DeleteAccountWebView extends StatefulWidget {
  final ClientProfileModel client;

  const DeleteAccountWebView({
    super.key,
    required this.client,
  });

  @override
  State<DeleteAccountWebView> createState() => _DeleteAccountWebViewState();
}

class _DeleteAccountWebViewState extends State<DeleteAccountWebView> {
  late final WebViewController controller;

  bool _isPageLoading = true;
  int _progress = 0;

  bool _navigationTriggered = false;
  bool _deleteHandled = false;
  bool _successUiTriggered = false;
  bool _showSuccessOverlay = false;

  void logStep(String message) {
    debugPrint('[DeleteAccountWebView] $message');
    developer.log(message, name: 'DeleteAccountWebView');
  }

  @override
  void initState() {
    super.initState();

    final uri = Uri.parse(
      "https://humorstech.com/metabolism/account/delete/",
    ).replace(queryParameters: {"email": widget.client.email});

    logStep("initState called");
    logStep("Delete URL: $uri");
    logStep("Client email: ${widget.client.email}");

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            logStep("onPageStarted: $url");

            if (!mounted) return;

            setState(() {
              _isPageLoading = true;
              _progress = 0;
            });

            _checkDeleteSuccessFromUrl(url);
          },
          onProgress: (p) {
            // Check URL even during progress as some redirects happen fast
            controller.currentUrl().then((url) {
              if (url != null) _checkDeleteSuccessFromUrl(url);
            });

            if (!mounted) return;
            setState(() => _progress = p);
          },
          onPageFinished: (url) async {
            logStep("onPageFinished: $url");

            // Re-check URL on finish
            _checkDeleteSuccessFromUrl(url);

            try {
              await controller.runJavaScript('''
                (function() {
                  var existing = document.querySelector('meta[name="viewport"]');
                  if (existing) existing.remove();
                  var meta = document.createElement('meta');
                  meta.name = 'viewport';
                  meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                  document.getElementsByTagName('head')[0].appendChild(meta);
                })();
              ''');
            } catch (e) {
              logStep("Viewport JS failed: $e");
            }

            if (!mounted) return;

            setState(() {
              _isPageLoading = false;
              _progress = 100;
            });
          },
          onNavigationRequest: (request) {
            logStep("onNavigationRequest: ${request.url}");
            _checkDeleteSuccessFromUrl(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _isPageLoading = false);
          },
        ),
      )
      ..addJavaScriptChannel(
        'AccountDeletionChannel',
        onMessageReceived: (JavaScriptMessage msg) async {
          final message = msg.message.trim().toUpperCase();
          logStep("JS Channel: $message");

          if (message == "ACCOUNT_DELETED" || message.contains("SUCCESS")) {
            await _handleAccountDeleted();
          }
        },
      )
      ..loadRequest(uri);
  }

  void _checkDeleteSuccessFromUrl(String url) {
    if (_deleteHandled) return;

    final lowerUrl = url.toLowerCase();

    // Expanded detection logic for production environments
    final looksLikeDeleteSuccess =
        lowerUrl.contains("account-deleted") ||
            lowerUrl.contains("delete-success") ||
            lowerUrl.contains("success=true") ||
            lowerUrl.contains("deleted=true") ||
            lowerUrl.contains("account_deleted") ||
            lowerUrl.contains("confirmation/delete");

    if (looksLikeDeleteSuccess) {
      logStep("Delete success detected from URL: $url");
      _handleAccountDeleted();
    }
  }

  Future<void> _handleAccountDeleted() async {
    if (_navigationTriggered || _deleteHandled) return;

    _deleteHandled = true;
    _successUiTriggered = true;

    if (!mounted) return;

    // Ensure keyboard is closed
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isPageLoading = false;
      _showSuccessOverlay = true;
    });
  }

  Future<void> _performFinalCleanup() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      await DefaultCacheManager().emptyCache();
      await WebViewCookieManager().clearCookies();
      await ClientLoginManager().clearClientProfile();
    } catch (e) {
      logStep("Cleanup error: $e");
    }
  }

  Future<void> _logoutAndGoToLogin() async {
    if (_navigationTriggered) return;
    _navigationTriggered = true;
    await _performFinalCleanup();
    if (!mounted) return;
    context.go(AppRoutes.signInOptions);
  }

  void _goToQuaProfile() {
    if (_navigationTriggered) return;
    _navigationTriggered = true;
    if (!mounted) return;
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => QuaProfile(clientProfileModel: widget.client),
    //   ),
    // );
  }

  Future<void> _onDoneSuccess() async {
    if (_navigationTriggered) return;
    if (mounted) setState(() => _showSuccessOverlay = false);
    await _performFinalCleanup();
    if (!mounted) return;
    _goToSignInDirectly();
  }

  void _goToSignInDirectly() {
    if (_navigationTriggered) return;
    _navigationTriggered = true;
    if (!mounted) return;
    context.go(AppRoutes.signInOptions);
  }

  Widget _buildSuccessOverlay(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.45,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3FAF58),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Account Deleted",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your Respyr account has been successfully deleted.\nWe’re sorry to see you go.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(width: 1, color: Color(0xFFA1A1A1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        ),
                        onPressed: _onDoneSuccess,
                        child: Text(
                          "Done",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: 0.30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showSuccessOverlay,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_showSuccessOverlay) return;
        _goToQuaProfile();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: _showSuccessOverlay ? null : _goToQuaProfile,
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: const Text("Delete Account", style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: _isPageLoading
              ? PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: LinearProgressIndicator(
              value: (_progress / 100).clamp(0.0, 1.0),
              minHeight: 2,
              backgroundColor: const Color(0xFFE5E7EB),
            ),
          )
              : null,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: _showSuccessOverlay,
                      child: WebViewWidget(controller: controller),
                    ),
                  ),
                ],
              ),
              if (_isPageLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
                          SizedBox(height: 12),
                          Text("Loading...", style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_showSuccessOverlay) _buildSuccessOverlay(context),
            ],
          ),
        ),
      ),
    );
  }
}