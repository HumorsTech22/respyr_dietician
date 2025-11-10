import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../client-dashboard/data/model/client_profile_model.dart';
import '../client_login_manager/client_login_manager.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    Timer(const Duration(seconds: 3), _handleNavigation);
  }

  Future<void> _handleNavigation() async {
    // Ensure widget still mounted before navigating
    if (!mounted) return;

    try {
      final ClientProfileModel? loadedProfile = await ClientLoginManager().loadClientProfile();

      if (!mounted) return; // Double check before navigation

      if (loadedProfile != null) {
        // Navigate to dashboard with loaded profile
        context.go(AppRoutes.clientDashboard, extra: loadedProfile);
      } else {
        // Navigate to sign in options if no profile saved
        context.go(AppRoutes.signInOptions);
      }
    } catch (e, stacktrace) {
      // Optionally log error, then navigate to sign in
      debugPrint('Error loading profile: $e\n$stacktrace');
      if (mounted) {
        context.go(AppRoutes.signInOptions);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF308BF9),
      body: Center(
        child: SvgPicture.asset("assets/images/icons/ic_logo_splash.svg"),
      ),
    );
  }
}
