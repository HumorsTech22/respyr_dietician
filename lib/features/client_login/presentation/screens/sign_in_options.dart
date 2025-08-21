import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/client_login/screens/sign_in_with_email.dart';

import '../../../client_login_manager/client_login_manager.dart';
import '../../../routes/app_routes.dart';
import '../../profile_info/presentation/cubit/profile_cubit.dart';
import '../services/check_profile_client.dart';
import '../services/sign_in_with_google_service.dart';

class SignInOptions extends StatefulWidget {
  const SignInOptions({super.key});

  @override
  State<SignInOptions> createState() => _SignInOptionsState();
}

class _SignInOptionsState extends State<SignInOptions> {
  bool _isLoading = false;

  static const _horizontalPadding = EdgeInsets.symmetric(horizontal: 13, vertical: 18);
  static const _googleButtonColor = Color(0xFF252525);
  static const _emailBorderColor = Color(0xFFC7C6CE);
  static const _titleColor = Color(0xFF252525);

  @override
  void initState() {
    super.initState();
    // Clear any previous profile data on entering this screen
    context.read<ProfileCubit>().clearProfileData();
  }

  Future<void> _handleEmailSignIn() async {
    // Navigate to email sign-in screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInWithEmail()),
    );
  }

  Future<void> _handleGoogleSignInPressed() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = await handleGoogleSignIn();
      if (!mounted) return;

      if (user == null) {
        _showSnackBar('Google sign-in was cancelled.');
        return;
      }

      final clientProfile = await checkClientProfile(user.email, "");
      if (!mounted) return;

      if (clientProfile != null) {
        bool isSaved = await ClientLoginManager().saveClientProfile(clientProfile);
        if (isSaved) {
          context.go(
            AppRoutes.clientDashboard,
            extra: clientProfile,
          );
        } else {
          _showSnackBar('Failed to save client profile.');
        }
      } else {
        context.push(
          AppRoutes.profileInfoScreen,
          extra: {
            "stepCompleted": 1,
            "enteredEmail": user.email,
          },
        );
      }
    } catch (e) {
      _showSnackBar('Google sign-in failed. Please try again.');
      debugPrint('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    BorderSide? borderSide,
    Widget? leading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: borderSide ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            leading ?? const SizedBox(width: 24),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.10,
                  letterSpacing: 0.30,
                ),
              ),
            ),
            const SizedBox(width: 24), // Keeps symmetry
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: _horizontalPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                "Sign in",
                style: GoogleFonts.poppins(
                  color: _titleColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2.04,
                ),
              ),
              const SizedBox(height: 30),

              // Email button
              _buildCustomButton(
                text: "Continue with Email",
                onPressed: _isLoading ? null : _handleEmailSignIn,
                backgroundColor: Colors.white,
                textColor: _titleColor,
                borderSide: const BorderSide(width: 1, color: _emailBorderColor),
              ),

              const SizedBox(height: 20),

              // Google button
              _buildCustomButton(
                text: _isLoading ? "Signing in..." : "Continue with Google",
                onPressed: _isLoading ? null : _handleGoogleSignInPressed,
                backgroundColor: _googleButtonColor,
                textColor: Colors.white,
                leading: Image.asset("assets/images/icons/ic_google.png", width: 24),
              ),

              if (_isLoading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
