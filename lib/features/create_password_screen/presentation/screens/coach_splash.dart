import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:respyr_dietitian/features/coach_sign_in/services/check_dietitian_service.dart';
import '../../../../routes/app_routes.dart';

class CoachSplash extends StatefulWidget {
  const CoachSplash({super.key});

  @override
  State<CoachSplash> createState() => _CoachSplashState();
}

class _CoachSplashState extends State<CoachSplash> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) _handleNavigation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final hasSeenWalkthrough = prefs.getBool('has_seen_walkthrough') ?? false;
      if (!mounted) return;

      if (!hasSeenWalkthrough) {
        context.go(AppRoutes.walThroughScreen);
        return;
      }

      final email = prefs.getString("coach_logged_in_email");
      final isLoggedIn = prefs.getBool("is_coach_logged_in") ?? false;

      if (!isLoggedIn || email == null || email.trim().isEmpty) {
        context.go(AppRoutes.signInOptions);
        return;
      }

      final dietitian = await checkDietitianProfile(email: email.trim());
      if (!mounted) return;

      if (dietitian != null) {
        context.go(AppRoutes.whoIsUsing, extra: dietitian);
      } else {
        await prefs.remove("coach_logged_in_email");
        await prefs.setBool("is_coach_logged_in", false);
        if (!mounted) return;
        context.go(AppRoutes.signInOptions);
      }
    } catch (e) {
      if (!mounted) return;
      context.go(AppRoutes.signInOptions);
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