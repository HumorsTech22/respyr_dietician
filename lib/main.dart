import 'dart:convert';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:respyr_dietitian/core/audio/audio_cubit.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/generating_result_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository_impl/bluetooth_repository_impl.dart';
import 'package:respyr_dietitian/features/device_connectivity/data/usb_repository_impl.dart';

import 'package:respyr_dietitian/features/dietitian_dashboard/data/repository/dietitian_dashboard_repository.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_cubit.dart';

import 'package:respyr_dietitian/features/log_food/presentation/cubit/test_timer_cubit/test_timer_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/data/repository/dietician_repository.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmr.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/routes/app_router.dart' hide rootNavigatorKey;

import 'core/global_keys.dart';
import 'features/bluetooth_device_connectivity/presentation/cubit/global_error_cubit/global_error_cubit.dart';
import 'features/bluetooth_device_connectivity/presentation/widgets/global_ble_popup_manager.dart';
import 'features/profile_info/presentation/cubit/create_profile_cubit.dart';

import 'package:respyr_dietitian/features/dashboard/bloc/dashboard_bloc.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class InternetCubit extends Cubit<bool> {
  InternetCubit() : super(true) {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  Future<void> _init() async {
    final initial = await _connectivity.checkConnectivity();
    emit(!_isOffline(initial));

    _sub = _connectivity.onConnectivityChanged.listen((results) {
      emit(!_isOffline(results));
    });
  }

  bool _isOffline(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();
  await Permission.notification.request();

  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');

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

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      final androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Notifications',
        channelDescription: 'Default notification channel',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        largeIcon: const DrawableResourceAndroidBitmap('launcher_icon'),
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

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final data = message.data;

    if (data['screen'] == 'chat-screen') {
      appRouter.pushNamed('chat', extra: data['chatUserId']);
    } else {
      appRouter.goNamed('home');
    }
  });

  await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();

  final calculateBMI = CalculateBMI();
  final calculateBMR = CalculateBMR();
  final dieticianRepository = DietitianRepository();
  final usbService = UsbCommunicationService();
  final usbRepository = UsbRepositoryImpl(usbService);
  final dietitianDashboardRepository = DietitianDashboardRepository();

  final uuidBleManager = UuidBluetoothManager();

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
          BlocProvider(create: (_) => DashboardBloc()),
          BlocProvider(create: (_) => InternetCubit()),
          BlocProvider.value(value: globalErrorCubit),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      scaffoldMessengerKey: rootMessengerKey,
      builder: (context, child) {
        return MultiBlocListener(
          listeners: [
            BlocListener<InternetCubit, bool>(
              listenWhen: (prev, curr) => prev != curr,
              listener: (context, hasInternet) {
                final messenger = rootMessengerKey.currentState;
                if (messenger == null) return;

                messenger.clearSnackBars();

                if (!hasInternet) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("No internet connection"),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(days: 1),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Back online"),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            BlocListener<GlobalErrorCubit, GlobalErrorState>(
              listenWhen: (prev, curr) => prev.message != curr.message,
              listener: (context, state) async {
                final msg = state.message;
                if (msg == null) return;

                final navState = rootNavigatorKey.currentState;
                if (navState == null) return;

                final navContext = navState.overlay!.context;

                if (_isDialogShowing) return;
                _isDialogShowing = true;

                await showDialog(
                  context: navContext,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    title: const Text("Device Error"),
                    content: Text(msg),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(navContext, rootNavigator: true).pop();
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );

                _isDialogShowing = false;
                globalErrorCubit.clear();
              },
            ),
          ],
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          ),
        );
      },
    );
  }
}
