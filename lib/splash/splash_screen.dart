import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client-dashboard/data/model/client_profile_model.dart';
import '../client_login_manager/client_login_manager.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 SplashScreen initState called");
    _startSplashTimer();
  }

  void _startSplashTimer() {
    debugPrint("⏳ Starting splash timer (3 seconds)");
    _timer?.cancel();

    _timer = Timer(const Duration(seconds: 3), () {
      debugPrint("⏰ Splash timer finished → calling navigation");
      _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    debugPrint("➡️ _handleNavigation started");

    if (!mounted) {
      debugPrint("⚠️ Widget not mounted, stopping navigation");
      return;
    }

    try {
      debugPrint("📦 Loading SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();

      final bool hasSeenWalkthrough =
          prefs.getBool('has_seen_walkthrough') ?? false;

      debugPrint("📊 has_seen_walkthrough value: $hasSeenWalkthrough");

      if (!mounted) {
        debugPrint("⚠️ Widget not mounted after prefs load");
        return;
      }

      if (!hasSeenWalkthrough) {
        debugPrint("➡️ Navigating to Walkthrough Screen");
        context.go(AppRoutes.walThroughScreen);
        return;
      }

      debugPrint("👤 Loading saved client profile...");
      final ClientProfileModel? loadedProfile =
      await ClientLoginManager().loadClientProfile();

      debugPrint("📄 Loaded Profile: $loadedProfile");

      if (!mounted) {
        debugPrint("⚠️ Widget not mounted after profile load");
        return;
      }

      if (loadedProfile != null) {
        debugPrint("➡️ Profile found → Navigating to Dashboard");
        context.go(AppRoutes.clientDashboard, extra: loadedProfile);
      } else {
        debugPrint("➡️ No profile found → Navigating to SignIn Options");
        context.go(AppRoutes.signInOptions);
      }
    } catch (e, stacktrace) {
      debugPrint("❌ Error in splash navigation");
      debugPrint("Error: $e");
      debugPrint("Stacktrace: $stacktrace");

      if (mounted) {
        debugPrint("➡️ Navigating to SignIn Options due to error");
        context.go(AppRoutes.signInOptions);
      }
    }
  }

  @override
  void dispose() {
    debugPrint("🧹 SplashScreen dispose called");
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🎨 SplashScreen build called");

    return Scaffold(
      key: const ValueKey("splash_screen"),
      backgroundColor: const Color(0xFF308BF9),
      body: Center(
        key: const ValueKey("splash_center"),
        child: SvgPicture.asset(
          "assets/images/icons/ic_logo_splash.svg",
          semanticsLabel: "Respyr Splash Logo",
        ),
      ),
    );
  }
}