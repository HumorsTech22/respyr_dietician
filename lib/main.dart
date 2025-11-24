import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:respyr_dietitian/core/audio/audio_cubit.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/generating_result_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository_impl/bluetooth_repository_impl.dart';
import 'package:respyr_dietitian/features/device_connectivity/data/usb_repository_impl.dart';

import 'package:respyr_dietitian/features/dietitian_dashboard/data/repository/dietitian_dashboard_repository.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_cubit.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/data/repository/dietitian_result_repository.dart';
import 'package:respyr_dietitian/features/log_food/data/repository/log_food_repository.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/log_food_cubit.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/test_timer_cubit/test_timer_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/data/repository/dietician_repository.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmr.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/routes/app_router.dart';

import 'features/bluetooth_device_connectivity/presentation/widgets/global_ble_popup_manager.dart';
import 'features/profile_info/presentation/cubit/create_profile_cubit.dart';

// 🔹 Global navigator key for showing dialogs from anywhere
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// 🔹 Local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// 🔹 Background FCM handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('📩 BG message: ${message.notification?.title}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔹 FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 Request FCM permission (iOS / web)
  await FirebaseMessaging.instance.requestPermission();

  // 🔹 Android 13+ notification permission
  await Permission.notification.request();

  // 🔹 Local notifications setup
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // safe default

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {
      try {
        if (details.payload != null) {
          final data = jsonDecode(details.payload!);
          final screen = data['screen'];
          final chatUserId = data['chatUserId'];

          if (screen == 'chat-screen') {
            appRouter.pushNamed('chat', extra: chatUserId);
          } else {
            appRouter.goNamed('home');
          }
        } else {
          appRouter.goNamed('home');
        }
      } catch (_) {
        appRouter.goNamed('home');
      }
    },
  );

  // 🔹 Foreground messages → show local notification (status bar)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      // --- Pick icons based on title ---
      String smallIcon;
      AndroidBitmap<Object>? largeIcon;

      if (notification.title == "New Message") {
        // TODO: ensure ic_notif_message exists in res/drawable if you use it
        smallIcon = '@mipmap/launcher_icon';
        largeIcon = const DrawableResourceAndroidBitmap('launcher_icon');
      } else {
        smallIcon = '@mipmap/launcher_icon';
        largeIcon = const DrawableResourceAndroidBitmap('launcher_icon');
      }

      final androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Notifications',
        channelDescription: 'Default notification channel',
        importance: Importance.max,
        priority: Priority.high,
        icon: smallIcon, // small status icon
        largeIcon: largeIcon, // large icon in expanded view
      );

      final platformDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: jsonEncode(message.data),
      );
    }
  });

  // 🔹 App opened from system tray notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final data = message.data;

    print(data['screen']);

    if (data['screen'] == 'chat-screen') {
      appRouter.pushNamed('chat', extra: data['chatUserId']);
    } else {
      appRouter.goNamed('home');
    }
  });

  // 🔹 Request Bluetooth/location permissions
  await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();

  // 🔹 Core dependencies
  final calculateBMI = CalculateBMI();
  final calculateBMR = CalculateBMR();
  final dieticianRepository = DietitianRepository();
  final usbService = UsbCommunicationService();
  final usbRepository = UsbRepositoryImpl(usbService);
  final dietitianDashboardRepository = DietitianDashboardRepository();

  // ✅ ONE shared instance of UuidBluetoothManager for whole app
  final uuidBleManager = UuidBluetoothManager();

  // ✅ Global listener for BLE data → popup on any screen
  GlobalBlePopupManager.init(
    manager: uuidBleManager,
    navigatorKey: rootNavigatorKey,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BluetoothRepository>(
          create: (_) => BluetoothRepositoryImpl(uuidBleManager),
        ),
        RepositoryProvider<GeneratingResultRepository>(
          create: (_) => GeneratingResultRepository(),
        ),
        // you can add usbRepository etc here if needed
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CreateProfileCubit()),
          BlocProvider(
            create: (_) => ProfileCubit(
              calculateBMI,
              calculateBMR,
              dieticianRepository,
            ),
          ),
          BlocProvider(create: (_) => AudioCubit()),
          BlocProvider(create: (_) => TestTimerCubit()),
          BlocProvider(
            create: (_) => DietitianDashboardCubit(dietitianDashboardRepository)
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
