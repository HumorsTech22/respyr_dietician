import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:respyr_dietitian/core/audio/audio_cubit.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository_impl.dart';
import 'package:respyr_dietitian/features/device_connectivity/data/repository/device_check_repo.dart';
import 'package:respyr_dietitian/features/device_connectivity/data/usb_repository_impl.dart';
import 'package:respyr_dietitian/features/device_connectivity/domain/usecase/device_check_usecase.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/issue_with_connection/issue_with_connection_cubit.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/usb_connection/usb_connection_cubit.dart';
import 'package:respyr_dietitian/features/diet_log/data/diet_log_repository.dart';
import 'package:respyr_dietitian/features/diet_log/presentation/cubit/diet_log_cubit.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/data/repository/dietitian_dashboard_repository.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_cubit.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/data/repository/dietitian_result_repository.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_cubit.dart';
import 'package:respyr_dietitian/features/help_center/presentation/cubit/help_center_cubit.dart';
import 'package:respyr_dietitian/features/log_food/data/repository/log_food_repository.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/log_food_cubit.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/test_timer_cubit/test_timer_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/data/repository/dietician_repository.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmr.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/test_result_screen/presentation/cubit/test_result_cubit.dart';

import 'package:respyr_dietitian/routes/app_router.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Ask notification permission (Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();

  // Init core dependencies
  final calculateBMI = CalculateBMI();
  final calculateBMR = CalculateBMR();
  final dieticianRepository = DietitianRepository();
  final usbService = UsbCommunicationService();
  final usbRepository = UsbRepositoryImpl(usbService);
  final deviceCheckRepo = DeviceCheckRepo();
  final deviceCheckUsecase = DeviceCheckUsecase(deviceCheckRepo);
  final dietitianDashboardRepository = DietitianDashboardRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BluetoothRepository>(
          create: (_) => BluetoothRepositoryImpl(UuidBluetoothManager()),
        ),
        RepositoryProvider<DietitianResultRepository>(
          create: (_) => DietitianResultRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (_) => ProfileCubit(
                  calculateBMI,
                  calculateBMR,
                  dieticianRepository,
                ),
          ),
          BlocProvider(create: (_) => TestResultCubit()),
          // BlocProvider(
          //   create: (_) => DietitianResultCubit(DietitianResultRepository()),
          // ),
          BlocProvider(
            create: (_) => UsbCubit(usbRepository, deviceCheckUsecase),
          ),
          BlocProvider(create: (_) => AudioCubit()),
          BlocProvider(create: (_) => LogFoodCubit(LogFoodRepository())),
          BlocProvider(create: (_) => HelpCenterCubit()),
          BlocProvider(create: (_) => TestTimerCubit()),
          BlocProvider(
            create: (_) => OtgCubit(OpenSettingsUseCase(OtgRepository())),
          ),
          BlocProvider(
            create:
                (_) =>
                    DietLogCubit(DietLogRepository())
                      ..loadDietLog(DateTime.now()),
          ),
          BlocProvider(
            create:
                (_) =>
                    DietitianDashboardCubit(dietitianDashboardRepository)
                      ..loadDietitianDashboard(DateTime.now()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
