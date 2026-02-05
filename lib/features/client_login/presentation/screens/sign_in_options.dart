import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../client_login_manager/client_login_manager.dart';
import '../../../../common/dialogs/floating_message.dart';
import '../../../../common/widgets/terms_policy_links.dart';
import '../../../../core/size/get_height.dart'; // Using your rh helper
import '../../../../routes/app_routes.dart';
import '../../../profile_info/presentation/cubit/profile_cubit.dart';
import '../../data/services/check_profile_client.dart';
import '../../data/services/download_network_image_service.dart';
import '../../data/services/sign_in_with_google_service.dart';

class SignInOptions extends StatefulWidget {
  const SignInOptions({super.key});

  @override
  State<SignInOptions> createState() => _SignInOptionsState();
}

class _SignInOptionsState extends State<SignInOptions> {
  bool _isLoading = false;

  static const _googleButtonColor = Color(0xFF252525);
  static const _emailBorderColor = Color(0xFFC7C6CE);
  static const _titleColor = Color(0xFF252525);

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().clearProfileData();
  }

  Future<void> _handleEmailSignIn() async {
    context.push(
      AppRoutes.signInWithEmail,
    );
  }

  Future<void> _handleGoogleSignInPressed() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await signOutGoogle();
      final user = await handleGoogleSignIn();

      if (!mounted) return;

      if (user == null) {
        FloatingMessage.show(context, message: "Sign in canceled", type: FloatingMessageType.error);
        return;
      }

      final clientProfile = await checkClientProfile(userEmail: user.email);

      if (!mounted) return;
      if (clientProfile != null) {
        bool isSaved = await ClientLoginManager().saveClientProfile(clientProfile);
        if (isSaved && mounted) {
          context.go(
            AppRoutes.clientDashboard,
            extra: clientProfile,
          );
        } else {
          FloatingMessage.show(context, message: "Failed to save client profile.", type: FloatingMessageType.error);
        }
      } else {
        String localPath = await downloadAndCacheImage(user.photoUrl ?? "assets/images/icons/default2.png");
        if (mounted) {
          context.push(
            AppRoutes.dietitianScreen,
            extra: {
              "enteredEmail": user.email,
              "profileImage": localPath,
              "profileName": user.displayName,
            },
          );
        }
      }
    } catch (e) {
      FloatingMessage.show(context, message: "Google sign-in failed. Please try again.", type: FloatingMessageType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCustomButton({
    required BuildContext context, // Added context for rh
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
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rh(context: context, px: 50)),
            side: borderSide ?? BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            vertical: rh(context: context, px: 20),
            horizontal: rh(context: context, px: 20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            leading ?? SizedBox(width: rh(context: context, px: 24)),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w700,
                  height: 1.10,
                  letterSpacing: 0.30,
                ),
              ),
            ),
            SizedBox(width: rh(context: context, px: 24)),
          ],
        ),
      ),
    );
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
              SvgPicture.asset(
                "assets/images/icons/ic_logo_blue.svg"
              ),
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

              _buildCustomButton(
                context: context,
                text: "Continue with Email",
                onPressed: _isLoading ? null : _handleEmailSignIn,
                backgroundColor: Colors.white,
                textColor: _titleColor,
                borderSide: BorderSide(width: 1, color: _emailBorderColor),
              ),

              SizedBox(height: rh(context: context, px: 20)),

              _buildCustomButton(
                context: context,
                text: _isLoading ? "Signing in..." : "Continue with Google",
                onPressed: _isLoading ? null : _handleGoogleSignInPressed,
                backgroundColor: _googleButtonColor,
                textColor: Colors.white,
                leading: Image.asset(
                  "assets/images/icons/ic_google.png",
                  width: rh(context: context, px: 24),
                ),
              ),
              SizedBox(height: rh(context: context, px: 25)),
              TermsPolicyWidgets().termsPolicyFooter(context),

            ],
          ),
        ),
      ),
    );
  }
}