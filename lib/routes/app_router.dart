import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/exhale_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/generating_result_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/result_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_device_connectivity.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_generating_result_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/age_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/dietician_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/gender_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/height_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/profile_info_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/profile_welcome_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/weight_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/full_screen_image_view.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/image_cropper_screen.dart';
import 'package:respyr_dietitian/features/result_screen/presentation/pages/result_screen.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import 'package:respyr_dietitian/splash/splash_screen.dart';
import '../client-dashboard/data/model/client_profile_model.dart';
import '../client-dashboard/presentation/screens/client_dashboard.dart';
import '../features/bluetooth_device_connectivity/presentation/pages/bluetooth_breathe_tube.dart';
import '../features/bluetooth_device_connectivity/presentation/pages/bluetooth_calibration_screen.dart';
import '../features/bluetooth_device_connectivity/presentation/pages/bluetooth_exhale_screen.dart';
import '../features/bluetooth_device_connectivity/presentation/pages/bluetooth_inhale_screen.dart';
import '../features/client_login/presentation/screens/client_login_with_phone_no.dart';
import '../features/client_login/presentation/screens/sign_in_options.dart';
import '../features/client_login/presentation/screens/sign_in_with_email.dart';
import '../features/dietitian_result_screen/data/repository/dietitian_result_repository.dart';
import '../features/dietitian_result_screen/presentation/cubit/dietitian_result_cubit.dart';
import '../features/dietitian_result_screen/presentation/pages/dietitian_result_screen.dart';
import '../features/profile_info/presentation/widgets/dietician_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashScreen,
  debugLogDiagnostics: true,

  routes: [
    GoRoute(
      path: AppRoutes.clientDashboard,
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! ClientProfileModel) {
          return _errorScreen('Missing or invalid client profile data.');
        }
        return ClientDashboard(clientProfileModel: extra);
      },
    ),

    // Profile info screen with optional map extra
    GoRoute(
      path: AppRoutes.profileInfoScreen,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        final int stepCompleted = data["stepCompleted"] ?? 1;
        final String enteredEmail = data["enteredEmail"] ?? "NA";
        final String profileImage = data["profileImage"] ?? "NA";
        final String profileName = data["profileName"] ?? "NA";

        return ProfileInfoScreen(
          stepCompleted: stepCompleted,
          enteredEmail: enteredEmail,
          imageUrlPath: profileImage,
          profileName: profileName,
        );
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
      path: AppRoutes.dietitianScreen,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        final String enteredEmail = data["enteredEmail"] ?? "NA";
        final String profileImage = data["profileImage"] ?? "NA";
        final String profileName = data["profileName"] ?? "NA";
        return DietitianScreen(
          enteredEmail: enteredEmail,
          imageUrlPath: profileImage,
          profileName: profileName,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.dietitianDetailScreen,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        final String enteredEmail = data["enteredEmail"] ?? "NA";
        final String profileImage = data["profileImage"] ?? "NA";
        final String profileName = data["profileName"] ?? "NA";
        return DietitianDetailScreen(
          enteredEmail: enteredEmail,
          imageUrlPath: profileImage,
          profileName: profileName,
        );
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
      path: AppRoutes.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.clientLoginWithPhoneNo,
      builder: (context, state) => const ClientLoginWithPhoneNo(),
    ),

    GoRoute(
      path: AppRoutes.selectCountryCode,
      builder: (context, state) => const SelectCountryCode(),
    ),

    GoRoute(
      path: AppRoutes.signInOptions,
      builder: (context, state) => const SignInOptions(),
    ),

    GoRoute(
      path: AppRoutes.signInWithEmail,
      builder: (context, state) => const SignInWithEmail(),
    ),
    GoRoute(
      path: AppRoutes.bluetoothDeviceConnectivity,
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! ClientProfileModel) {
          return _errorScreen('Missing or invalid client profile data.');
        }
        return BluetoothDeviceConnectivity(clientProfileModel: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.bluetoothBreatheTube,
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! ClientProfileModel) {
          return _errorScreen('Missing or invalid client profile data.');
        }
        return BluetoothBreatheTube(clientProfileModel: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.bluetoothCalibrationScreen,
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! ClientProfileModel) {
          return _errorScreen('Missing or invalid client profile data.');
        }
        return BluetoothCalibrationScreen(clientProfileModel: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.bluetoothInhaleScreen,
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! ClientProfileModel) {
          return _errorScreen('Missing or invalid client profile data.');
        }
        return BluetoothInhaleScreen(clientProfileModel: extra);
      },
    ),

    GoRoute(
      path: AppRoutes.bluetoothExhaleScreen,
      builder: (context, state) {
        final params = state.extra as ExhaleScreenParams?;

        if (params == null) {
          return _errorScreen('Missing navigation parameters.');
        }

        return BluetoothExhaleScreen(
          clientProfileModel: params.clientProfileModel,
          baseValue: params.baseValue,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.bluetoothGeneratingResultScreen,
      builder: (context, state) {
        final params = state.extra as GeneratingResultParams;
        return BluetoothGeneratingResultScreen(
          maxPressure: params.maxPressure,
          bestPressure: params.bestPressure,
          blowDuration: params.blowDuration,
          blowValuesList: params.blowValuesList,
          clientProfileModel: params.clientProfileModel,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.dietitianResultScreen,
      builder: (context, state) {
        final params = state.extra as ResultScreenParams;
        return BlocProvider(
          create:
              (context) => DietitianResultCubit(
                context.read<DietitianResultRepository>(),
              ),
          child: DietitianResultScreen(
            args: params.args,
            clientProfileModel: params.clientProfileModel,
          ),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.fullScreenImageView,
      pageBuilder: (context, state) {
        final imagePath = state.extra as String?;
        return CustomTransitionPage(
          opaque: false,
          barrierColor: Colors.black.withAlpha(40),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: FullScreenImageView(imagePath: imagePath),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.resultScreen,
      builder: (context, state) => ResultScreen(),
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
