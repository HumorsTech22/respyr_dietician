import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietician/features/profile_info/presentation/pages/age_screen.dart';
import 'package:respyr_dietician/features/profile_info/presentation/pages/dietician_screen.dart';
import 'package:respyr_dietician/features/profile_info/presentation/pages/gender_screen.dart';
import 'package:respyr_dietician/features/profile_info/presentation/pages/height_screen.dart';
import 'package:respyr_dietician/features/profile_info/presentation/pages/profile_info_screen.dart';
import 'package:respyr_dietician/features/profile_info/presentation/pages/profile_welcome_screen.dart';
import 'package:respyr_dietician/features/profile_info/presentation/pages/weight_screen.dart';
import 'package:respyr_dietician/features/profile_info/presentation/widgets/full_screen_image_view.dart';
import 'package:respyr_dietician/features/profile_info/presentation/widgets/image_cropper_screen.dart';
import 'package:respyr_dietician/features/result_screen/presentation/pages/result_screen.dart';
import 'package:respyr_dietician/routes/app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.profileInfoScreen,
  debugLogDiagnostics: true, // optional: logs routing in console
  routes: [
    GoRoute(
      path: AppRoutes.profileInfoScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 1;
        return ProfileInfoScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.genderScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 2;
        return GenderScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.ageScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 3;
        return AgeScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.heightScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 4;
        return HeightScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.weightScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 5;
        return WeightScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.dieticianScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 6;
        return DieticianScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.profileWelcomeScreen,
      builder: (context, state) => const ProfileWelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.imageCropperScreen,
      builder: (context, state) {
        final imageData = state.extra;
        if (imageData is! Uint8List) {
          return _errorScreen('No image data provided');
        }
        return ImageCropperScreen(imageData: imageData);
      },
    ),
    GoRoute(
      path: AppRoutes.fullScreenImageView,
      pageBuilder: (context, state) {
        final imageData = state.extra as Uint8List;
        return CustomTransitionPage(
          opaque: false, // 👈 Shows previous screen in background
          barrierColor: Colors.black.withAlpha(40), // Slight dimming
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: FullScreenImageView(imageData: imageData),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.resultScreen,
      builder: (context, state) {
        return ResultScreen();
      },
    ),
  ],
);

Widget _errorScreen(String message) {
  return Scaffold(
    body: Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.redAccent,
        ),
      ),
    ),
  );
}
