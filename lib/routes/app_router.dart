import 'dart:typed_data';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/generating_result_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/exhale_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/generating_result_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/result_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit/bluetooth_generating_result_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_device_connectivity.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_generating_result_screen.dart';
import 'package:respyr_dietitian/features/dashboard/presentation/screens/dashboard.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/pages/overall_metabolism_score.dart';
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
import 'package:respyr_dietitian/features/walk_through/presentation/screen/walk_through.dart';
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
import '../features/dashboard/qua_dashboard/presentation/screens/qua_dashboard.dart';
import '../features/dashboard/qua_dashboard/presentation/screens/qua_dashboard_screen.dart';
import '../features/dietitian_result_screen/presentation/cubit/dietitian_result_cubit.dart';
import '../features/dietitian_result_screen/presentation/pages/dietitian_result_screen.dart';
import '../features/notification/data/bloc/notification_bloc.dart' show NotificationBloc;
import '../features/notification/data/repository/notification_repository.dart';
import '../features/notification/presentation/screens/notification_screen.dart';
import '../features/profile_info/presentation/cubit/profile_cubit.dart';
import '../features/profile_info/presentation/widgets/dietician_detail_screen.dart';
import '../features/retake_test/presentation/screens/retake_test_screen.dart';
import '../features/retake_test/presentation/screens/test_conditions_screen.dart';
import '../features/test_result/test_histoty/presentation/screen/test_history_screen.dart';

/// ✅ Global navigator key used by GoRouter AND by GlobalBlePopupManager
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,  // 👈 this is the key change
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
        return QuaDashboardScreen(clientProfileModel: extra);
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
      path: AppRoutes.walThroughScreen,
      builder: (context, state) => const WalkthroughScreen(),
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

        // 1. Check it's a Map
        if (extra == null || extra is! Map) {
          return _errorScreen('Missing or invalid params.');
        }

        // 2. Extract values from the map
        final client = extra['client'];
        final strategy = extra['strategy'];

        final double minRange = extra['min_range'];
        final double maxRange = extra['max_range'];

        // 3. Type checks
        if (client is! ClientProfileModel) {
          return _errorScreen('Missing or invalid client profile data.');
        }

        // strategy can be nullable if you want
        if (strategy != null && strategy is! DietPlanStrategyModel) {
          return _errorScreen('Missing or invalid diet plan strategy data. ');
        }



        return BluetoothDeviceConnectivity(
          clientProfileModel: client,
          dietPlanStrategyModel: strategy,
          minRange: minRange,
          maxRange: maxRange,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.bluetoothBreatheTube,
      pageBuilder: (context, state) {
        final extra = state.extra;

        double _toDouble(dynamic v, {double fallback = 0.0}) {
          if (v == null) return fallback;
          if (v is double) return v;
          if (v is int) return v.toDouble();
          if (v is String) return double.tryParse(v) ?? fallback;
          return fallback;
        }

        if (extra == null || extra is! Map) {
          return NoTransitionPage(
            child: _errorScreen('Missing or invalid params.'),
          );
        }

        final client = extra['client'];
        final strategy = extra['strategy'];

        final double minRange = _toDouble(extra['min_range']);
        final double maxRange = _toDouble(extra['max_range']);

        if (client is! ClientProfileModel) {
          return NoTransitionPage(
            child: _errorScreen('Missing or invalid client profile data.'),
          );
        }

        if (strategy != null && strategy is! DietPlanStrategyModel) {
          return NoTransitionPage(
            child: _errorScreen('Missing or invalid diet plan strategy data.'),
          );
        }

        return NoTransitionPage(
          child: BluetoothBreatheTube(
            clientProfileModel: client,
            dietPlanStrategyModel: strategy,
            minRange: minRange,
            maxRange: maxRange,
          ),
        );
      },
    ),


    GoRoute(
      path: AppRoutes.bluetoothCalibrationScreen,
      pageBuilder: (context, state) {
        final extra = state.extra;

        double _toDouble(dynamic v, {double fallback = 0.0}) {
          if (v == null) return fallback;
          if (v is double) return v;
          if (v is int) return v.toDouble();
          if (v is String) return double.tryParse(v) ?? fallback;
          return fallback;
        }

        if (extra == null || extra is! Map) {
          return NoTransitionPage(
            child: _errorScreen('Missing or invalid params.'),
          );
        }

        final client = extra['client'];
        final strategy = extra['strategy'];

        final double minRange = _toDouble(extra['min_range']);
        final double maxRange = _toDouble(extra['max_range']);

        if (client is! ClientProfileModel) {
          return NoTransitionPage(
            child: _errorScreen('Missing or invalid client profile data.'),
          );
        }

        if (strategy != null && strategy is! DietPlanStrategyModel) {
          return NoTransitionPage(
            child: _errorScreen('Missing or invalid diet plan strategy data.'),
          );
        }

        return NoTransitionPage(
          child: BluetoothCalibrationScreen(
            clientProfileModel: client,
            dietPlanStrategyModel: strategy,
            minRange: minRange,
            maxRange: maxRange,
          ),
        );
      },
    ),


    GoRoute(
      path: AppRoutes.bluetoothInhaleScreen,
      pageBuilder: (context, state) {
        final extra = state.extra;

        if (extra == null || extra is! Map) {
          return const NoTransitionPage(
            child: Scaffold(
              body: Center(child: Text('Missing or invalid params.')),
            ),
          );
        }

        final client = extra['client'];
        final strategy = extra['strategy'];
        final double minRange = extra['min_range'];
        final double maxRange = extra['max_range'];

        if (client is! ClientProfileModel) {
          return const NoTransitionPage(
            child: Scaffold(
              body: Center(child: Text('Missing or invalid client profile data.')),
            ),
          );
        }

        if (strategy != null && strategy is! DietPlanStrategyModel) {
          return const NoTransitionPage(
            child: Scaffold(
              body: Center(child: Text('Missing or invalid diet plan strategy data.')),
            ),
          );
        }

        return NoTransitionPage(
          child: BluetoothInhaleScreen(
            clientProfileModel: client,
            dietPlanStrategyModel: strategy,
            minRange: minRange,
            maxRange: maxRange,
          ),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.bluetoothExhaleScreen,
      pageBuilder: (context, state) {
        final extra = state.extra;

        ExhaleScreenParams? params;

        double _toDouble(dynamic v, {double fallback = 0.0}) {
          if (v == null) return fallback;
          if (v is double) return v;
          if (v is int) return v.toDouble();
          if (v is String) return double.tryParse(v) ?? fallback;
          return fallback;
        }

        if (extra is ExhaleScreenParams) {
          params = extra;
        } else if (extra is Map) {
          try {
            final client = extra['clientProfileModel'];
            final dietPlan = extra['dietPlanStrategyModel'];

            if (client is! ClientProfileModel) {
              return NoTransitionPage(
                child: _errorScreen('Missing or invalid client profile data.'),
              );
            }

            if (dietPlan is! DietPlanStrategyModel) {
              return NoTransitionPage(
                child: _errorScreen('Missing or invalid diet plan strategy data.'),
              );
            }

            final baseValue = (extra['baseValue'] ?? '').toString();
            final minRange = _toDouble(extra['min_range']);
            final maxRange = _toDouble(extra['max_range']);

            params = ExhaleScreenParams(
              clientProfileModel: client,
              baseValue: baseValue,
              dietPlanStrategyModel: dietPlan,
              minRange: minRange,
              maxRange: maxRange,
            );
          } catch (e) {
            return NoTransitionPage(
              child: _errorScreen('Invalid navigation map: $e'),
            );
          }
        } else {
          return NoTransitionPage(
            child: _errorScreen('Missing or invalid navigation parameters.'),
          );
        }

        return NoTransitionPage(
          child: BluetoothExhaleScreen(
            clientProfileModel: params.clientProfileModel,
            baseValue: params.baseValue,
            dietPlanStrategyModel: params.dietPlanStrategyModel,
            minRange: params.minRange,
            maxRange: params.maxRange,
          ),
        );
      },
    ),


    GoRoute(
      path: AppRoutes.bluetoothGeneratingResultScreen,
      builder: (context, state) {
        final params = state.extra as GeneratingResultParams;

        return BlocProvider(
          create: (context) => BluetoothGeneratingResultCubit(
            repo: context.read<BluetoothRepository>(),
            repository: context.read<GeneratingResultRepository>(),
            maxPressure: params.maxPressure,
            bestPressure: params.bestPressure,
            blowDuration: params.blowDuration,
            blowValuesList: params.blowValuesList,
            clientProfileModel: params.clientProfileModel,
            dietPlanStrategyModel: params.dietPlanStrategyModel, minRange: params.minRange, maxRange: params.maxRange,
          ),
          child: BluetoothGeneratingResultScreen(
            maxPressure: params.maxPressure,
            bestPressure: params.bestPressure,
            blowDuration: params.blowDuration,
            blowValuesList: params.blowValuesList,
            clientProfileModel: params.clientProfileModel,
            dietPlanStrategyModel: params.dietPlanStrategyModel, minRange: params.minRange, maxRange: params.maxRange,
          ),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.dietitianResultScreen,
      builder: (context, state) {
        final params = state.extra as ResultScreenParams;

        print(params.clientProfileModel.dietitianId);


        final id = params.clientProfileModel.dietitianId?.trim().toLowerCase();

        if (id == 'respyrd01') {
          return BlocProvider(
            create: (context) => DietitianResultCubit(),
            child: DietitianResultScreen(
              result: params.result,
              clientProfileModel: params.clientProfileModel,
            ),
          );
        }


        return BlocProvider(
          create: (context) => DietitianResultCubit(),
          child: OverallMetabolismScore(
            result: params.result,
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
      builder: (context, state) {
        final client = state.extra as ClientProfileModel;
        return ResultScreen(clientProfileModel: client);
      },
    ),

    GoRoute(
      path: AppRoutes.notificationScreen,
      builder: (context, state) {
        final client = state.extra as ClientProfileModel;

        return BlocProvider<NotificationBloc>(
          create: (_) => NotificationBloc(
            repository: NotificationRepository(
            ),
          ),
          child: NotificationScreen(
            clientProfileModel: client,
          ),
        );
      },
    ),


    GoRoute(
      path:  AppRoutes.completeTestHistory,
      builder: (context, state) {
        final clientProfileModel = state.extra as Map;
        return TestHistoryScreen(
          clientProfileModel: clientProfileModel['client'],
          dietPlanStrategyModel: clientProfileModel['plan'],
        );
      },
    ),


    GoRoute(
      path: AppRoutes.retakeTestScreen,
      builder: (context, state) {
        ClientProfileModel client = state.extra as ClientProfileModel;
        return RetakeTestScreen(clientProfileModel: client,);
      },
    ),
    GoRoute(
      path: AppRoutes.testConditionScreen,
      builder: (context, state) {
        return TestConditionsScreen();
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
