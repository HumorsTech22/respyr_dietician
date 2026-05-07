import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:respyr_dietitian/features/coach_sign_in/services/check_dietitian_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:respyr_dietitian/common/widgets/terms_policy_links.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/client_login/data/services/sign_in_with_google_service.dart';
import 'package:respyr_dietitian/features/coach_sign_in/presentation/widgets/sign_in_button.dart';

import '../../../../client_login_manager/client_login_manager.dart';
import '../../../../common/dialogs/floating_message.dart';
import '../../../../routes/app_routes.dart';
import '../../../profile_info/presentation/cubit/profile_cubit.dart';

class CoachSignIn extends StatefulWidget {
  const CoachSignIn({super.key});

  @override
  State<CoachSignIn> createState() => _CoachSignInState();
}

class _CoachSignInState extends State<CoachSignIn> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  bool get _isAnyTaskLoading => _isGoogleLoading || _isAppleLoading;

  static const _googleButtonColor = Color(0xFF252525);
  static const _emailBorderColor = Color(0xFFC7C6CE);
  static const _titleColor = Color(0xFF252525);

  bool _resetDoneOnce = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<ProfileCubit>().clearProfileData();
      await _resetAllSessionsOnce();
    });
  }

  Future<void> _resetAllSessionsOnce() async {
    if (_resetDoneOnce) return;
    _resetDoneOnce = true;
    await _resetAllSessions();
  }

  Future<void> _resetAllSessions() async {
    try {
      await ClientLoginManager().clearClientProfile();
    } catch (_) {}

    try {
      await signOutGoogle();
    } catch (_) {}

    try {
      final g = GoogleSignIn();
      await g.signOut();
      await g.disconnect();
    } catch (_) {}

    try {
      if (Platform.isIOS) {
        const channel = MethodChannel('auth_session_clear');
        await channel.invokeMethod('clearAppleAuthSession');
      }
    } catch (_) {}
  }

  Future<void> _handleEmailSignIn() async {
    if (_isAnyTaskLoading) return;
    await _resetAllSessions();
    if (!mounted) return;
    context.push(AppRoutes.signInWithEmail);
  }

  Future<void> _handleGoogleSignInPressed() async {
    if (_isAnyTaskLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      await _resetAllSessions();

      final user = await handleGoogleSignIn();
      if (!mounted) return;

      if (user == null) {
        FloatingMessage.show(
          context,
          message: "Sign in canceled",
          type: FloatingMessageType.error,
        );
        return;
      }

      final dietitian = await checkDietitianProfile(email: user.email);

      if (dietitian != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("coach_logged_in_email", dietitian.email);
        await prefs.setBool("is_coach_logged_in", true);

        if (!mounted) return;
        context.go(AppRoutes.whoIsUsing, extra: dietitian);
        return;
      }

      FloatingMessage.show(
        context,
        message: "Dietitian not found.",
        type: FloatingMessageType.error,
      );
    } catch (_) {
      if (mounted) {
        FloatingMessage.show(
          context,
          message: "Google sign-in failed. Please try again.",
          type: FloatingMessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleAppleSignInPressed() async {
    if (_isAnyTaskLoading) return;
    setState(() => _isAppleLoading = true);

    try {
      await _resetAllSessions();

      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        if (!mounted) return;
        FloatingMessage.show(
          context,
          message: "Apple Sign-in is not available on this device.",
          type: FloatingMessageType.error,
        );
        return;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (!mounted) return;

      final email = (credential.email ?? "").trim();

      if (email.isEmpty) {
        FloatingMessage.show(
          context,
          message: "Apple didn't provide email. Try again or use Email sign-in.",
          type: FloatingMessageType.error,
        );
        return;
      }

      final dietitian = await checkDietitianProfile(email: email);
      if (!mounted) return;

      if (dietitian != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("coach_logged_in_email", dietitian.email);
        await prefs.setBool("is_coach_logged_in", true);

        context.go(AppRoutes.whoIsUsing, extra: dietitian);
        return;
      }

      FloatingMessage.show(
        context,
        message: "Dietitian not found.",
        type: FloatingMessageType.error,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (!e.code.toLowerCase().contains("canceled")) {
        FloatingMessage.show(
          context,
          message: "Apple sign-in failed. Please try again.",
          type: FloatingMessageType.error,
        );
      }
    } catch (_) {
      if (mounted) {
        FloatingMessage.show(
          context,
          message: "An unexpected error occurred.",
          type: FloatingMessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 17),
            vertical: rh(context: context, px: 25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset("assets/images/icons/ic_logo_blue.svg"),
              SizedBox(height: rh(context: context, px: 18)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 4)),
                child: Text(
                  "Sign in",
                  style: GoogleFonts.poppins(
                    color: _titleColor,
                    fontSize: rh(context: context, px: 34),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
              SizedBox(height: rh(context: context, px: 30)),
              SignInButton(
                text: "Continue with Email",
                onPressed: _isAnyTaskLoading ? null : _handleEmailSignIn,
                backgroundColor: Colors.white,
                textColor: _titleColor,
                borderSide: const BorderSide(width: 1, color: _emailBorderColor),
              ),
              SizedBox(height: rh(context: context, px: 20)),
              SignInButton(
                text: "Continue with Google",
                isLoading: _isGoogleLoading,
                onPressed: _isAnyTaskLoading ? null : _handleGoogleSignInPressed,
                backgroundColor: _googleButtonColor,
                textColor: Colors.white,
                leading: Image.asset(
                  "assets/images/icons/ic_google.png",
                  width: rh(context: context, px: 24),
                ),
              ),
              SizedBox(height: rh(context: context, px: 25)),
              Visibility(
                visible: Platform.isIOS,
                child: SignInButton(
                  text: "Continue with Apple",
                  isLoading: _isAppleLoading,
                  onPressed: _isAnyTaskLoading ? null : _handleAppleSignInPressed,
                  backgroundColor: _googleButtonColor,
                  textColor: Colors.white,
                  leading: SvgPicture.asset(
                    "assets/images/icons/ic_apple1.svg",
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 26,
                  ),
                ),
              ),
              SizedBox(height: rh(context: context, px: 25)),
              TermsPolicyWidgets().termsPolicyFooter(context),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "For lifestyle tracking only.\nNot for medical use or diagnosis.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(height: rh(context: context, px: 25)),
            ],
          ),
        ),
      ),
    );
  }
}