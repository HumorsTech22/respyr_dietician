import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_event.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_state.dart';
import 'package:respyr_dietitian/common/dialogs/abort_sheet_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/floating_message.dart';
import 'package:respyr_dietitian/common/widgets/abort_device_manager.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/core/utils/date_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/device_connectivity_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/result_screen_params.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/bloc/latest_test_bloc.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/bloc/latest_test_event.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/params/dashboard_params.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/repository/latest_test_repository.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/services/latest_test_service.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/helpers/qua_dashboard_mock_strategy_helper.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/checking_features_sheet.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/qua_profile/presentation/screens/qua_profile.dart';
import 'package:respyr_dietitian/features/gifting/dashboard/services/complete_test_history.dart';
import 'package:respyr_dietitian/features/habit_tracking/services/check_client_habits_response.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class QuaDashboardController {
  final BuildContext context;
  final DashboardParams dashboardParams;
  final LatestTestBloc latestTestBloc;
  final TodayTestDataBloc todayTestDataBloc;
  final VoidCallback onUpdate;

  QuaDashboardController({
    required this.context,
    required this.dashboardParams,
    required this.latestTestBloc,
    required this.todayTestDataBloc,
    required this.onUpdate,
  });

  DateTime selectedDate = DateTime.now();
  final List<DateTime> dateList = [];

  bool refreshing = false;
  DateTime lastRefreshAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration minRefreshGap = Duration(milliseconds: 800);

  DateTime? pausedAt;
  bool wasPaused = false;
  static const Duration resumeRefreshThreshold = Duration(seconds: 2);

  DateTime? lastBackPressed;

  bool hasShownHabitsPopup = false;
  bool hasShownSelectedHabitsPopup = false;

  void init() {
    refreshData();

    Future.microtask(() async {
      await requestRuntimePermissions();
      await warmUpFcmToken();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        runDashboardPopupQueue();
      }
    });
  }

  void disposeController() {}

  void log(String msg) {
    debugPrint("🟦 QUA_DASH | $msg");
  }

  Future<void> runDashboardPopupQueue() async {
    if (!context.mounted) return;

    final bool habitPopupShown = await checkAndShowHabitsPopup();

    if (habitPopupShown) {
      return;
    }

    await checkAndShowSelectedHabitsPopup();
  }

  /// ✅ Main fix:
  /// Show _HabitsBottomSheet only when habit API data is NULL.
  /// If userHabitsModel is not null, popup will NOT show,
  /// even if some inner fields are empty / na / not_available.
  bool shouldShowHabitsPopup() {
    return dashboardParams.userHabitsModel == null;
  }

  Future<bool> checkAndShowHabitsPopup() async {
    if (hasShownHabitsPopup) return false;

    final bool shouldShow = shouldShowHabitsPopup();

    if (!shouldShow) return false;

    hasShownHabitsPopup = true;

    await showUpdatePreferencesBottomSheet();

    return true;
  }

  UserHabitsModel getSafeHabitsModel() {
    return dashboardParams.userHabitsModel ??
        UserHabitsModel(
          id: 0,
          profileId: dashboardParams.clientProfile.profileId,
          goal: "not_available",
          activity: "not_available",
          foodType: FoodTypeModel(
            dietType: "not_available",
            primaryCuisine: "not_available",
            secondaryCuisine: "not_available",
          ),
          dateTime: "",
          timeStamp: "",
        );
  }

  Future<bool> showUpdatePreferencesBottomSheet() async {
    if (!context.mounted) return false;

    final UserHabitsModel safeHabitsModel = getSafeHabitsModel();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetCtx) {
        return _HabitsBottomSheet(
          onLater: () {
            Navigator.of(sheetCtx).pop();
          },
          onUpdate: () {
            Navigator.of(sheetCtx).pop();

            if (!context.mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => QuaProfile(
                  clientProfileModel: dashboardParams.clientProfile,
                  userHabitsModel: safeHabitsModel,
                ),
              ),
            );
          },
        );
      },
    );

    return true;
  }

  /// ✅ Start test also blocks only when habit API data is NULL.
  /// It will not block because of "na" / "not_available" field values.
  Future<bool> _canStartTest() async {
    final bool noHabitApiData = dashboardParams.userHabitsModel == null;

    if (!noHabitApiData) return true;

    await showUpdatePreferencesBottomSheet();

    return false;
  }

  Future<void> checkAndShowSelectedHabitsPopup() async {
    if (hasShownSelectedHabitsPopup) return;

    try {
      final result = await CheckClientHabitsService.checkClientHabitsAdded(
        profileId: dashboardParams.clientProfile.profileId,
      );

      if (result.isHabitAdded) return;

      if (!context.mounted) return;

      hasShownSelectedHabitsPopup = true;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: true,
        builder: (sheetCtx) {
          return _SelectedHabitsBottomSheet(
            onLater: () {
              Navigator.of(sheetCtx).pop();
            },
            onUpdate: () {
              Navigator.of(sheetCtx).pop();

              if (!context.mounted) return;

              context.go(
                AppRoutes.selectHabitLevelScreen,
                extra: dashboardParams.clientProfile,
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint("Selected habits check failed: $e");
    }
  }

  Future<void> requestRuntimePermissions() async {
    try {
      await [
        Permission.notification,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
    } catch (_) {}
  }

  Future<void> warmUpFcmToken() async {
    try {
      await FirebaseMessaging.instance.getToken();
    } catch (_) {}
  }

  void refreshData({bool force = false}) {
    final now = DateTime.now();

    if (refreshing) return;
    if (!force && now.difference(lastRefreshAt) < minRefreshGap) return;

    refreshing = true;
    lastRefreshAt = now;

    final dateStr = DateHelper.formatDate(selectedDate);

    latestTestBloc.add(
      FetchLatestTest(
        dietitianId: dashboardParams.clientProfile.dietitianId.toString(),
        profileId: dashboardParams.clientProfile.profileId.toString(),
        date: dateStr,
      ),
    );

    todayTestDataBloc.add(
      LoadTestDataForDay(
        dietitianId: dashboardParams.clientProfile.dietitianId.toString(),
        profileId: dashboardParams.clientProfile.profileId.toString(),
        date: selectedDate,
      ),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      refreshing = false;
    });
  }

  Future<void> refreshDataAsync({bool force = false}) async {
    refreshData(force: force);
    await Future.delayed(const Duration(milliseconds: 600));
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    onUpdate();
    refreshData(force: true);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("Lifecycle state: $state");

    if (state == AppLifecycleState.paused) {
      wasPaused = true;
      pausedAt = DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (wasPaused) {
        final diff = pausedAt == null
            ? Duration.zero
            : DateTime.now().difference(pausedAt!);

        if (diff >= resumeRefreshThreshold) {
          refreshData();
        }
      }

      wasPaused = false;
      pausedAt = null;
    }
  }

  Future<void> handleStartTest(TestDataState state) async {
    final bool canStart = await _canStartTest();

    if (!canStart) return;

    await requestRuntimePermissions();
    if (!context.mounted) return;

    final isAborted = await AbortDeviceManager.getAbortStatus();
    if (!context.mounted) return;

    if (isAborted) {
      CheckAbortSheet.show(
        context: context,
        onTakeTextClick: () {
          navigateToBluetooth(state);
        },
      );
    } else {
      navigateToBluetooth(state);
    }
  }

  Future<void> navigateToBluetooth(TestDataState state) async {
    final String todayDate = DateHelper.formatDate(DateTime.now());

    final repo = LatestTestRepository(LatestTestService());

    final latestTest = await repo.fetchLatestTest(
      dietitianId: dashboardParams.clientProfile.dietitianId.toString(),
      profileId: dashboardParams.clientProfile.profileId.toString(),
      date: todayDate,
    );

    final bool isTestTaken = latestTest != null;

    await requestRuntimePermissions();
    if (!context.mounted) return;

    final connected = await FlutterBluePlus.connectedDevices;
    if (!context.mounted) return;

    await CheckingFeaturesSheet.show(
      context,
      dieticianId: dashboardParams.clientProfile.dietitianId,
      profileId: dashboardParams.clientProfile.profileId,
      onComplete: (result, needsPractice) async {
        if (!context.mounted) return;

        final featuresData = result.data;

        if (!result.success) {
          debugPrint("Features fetch failed: ${result.failReason}");
        }

        if (!featuresData.testAllow) {
          FloatingMessage.show(
            context,
            message: "Test feature is locked for your account",
            type: FloatingMessageType.info,
            icon: Icons.lock,
          );
          return;
        }

        final route = connected.isEmpty
            ? AppRoutes.bluetoothDeviceStartTest
            : AppRoutes.bluetoothDeviceConnectivity;

        if (featuresData.practiceTestAllow && needsPractice) {
          await context.push(
            AppRoutes.practiceFlowShell,
            extra: dashboardParams.clientProfile,
          );
        } else {
          final param = DeviceConnectivityParams(
            clientProfileModel: dashboardParams.clientProfile,
            dietPlanStrategyModel: generateMockStrategy(
              clientProfile: dashboardParams.clientProfile,
              dietitianDetailModel: dashboardParams.dietitianDetailModel,
            ),
            minRange: dashboardParams.currentMinRange,
            maxRange: dashboardParams.currentMaxRange,
            isTestTaken: isTestTaken,
            featuresAllowData: featuresData,
            userHabitsModel: getSafeHabitsModel(),
          );

          await context.push(route, extra: param);
        }

        if (!context.mounted) return;
        refreshData(force: true);
      },
    );
  }

  Future<void> navigateToDetailedResult(String testId) async {
    try {
      final result =
      await TestHistoryCompleteService.fetchTestHistoryCompleteNew(
        dietitianId: dashboardParams.clientProfile.dietitianId,
        profileId: dashboardParams.clientProfile.profileId,
        testId: int.parse(testId),
      );

      if (!context.mounted) return;

      await CheckingFeaturesSheet.show(
        context,
        dieticianId: dashboardParams.clientProfile.dietitianId,
        onComplete: (features, needsPractice) {
          if (!context.mounted) return;

          context.go(
            AppRoutes.dietitianResultScreen,
            extra: ResultScreenParamsNew(
              respyrUnifiedResponse: result,
              clientProfileModel: dashboardParams.clientProfile,
              featuresAllowData: features.data,
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      FloatingMessage.show(
        context,
        message: "Could not load result: $e",
        type: FloatingMessageType.error,
      );
    }
  }
}

class _HabitsBottomSheet extends StatelessWidget {
  final VoidCallback onLater;
  final VoidCallback onUpdate;

  const _HabitsBottomSheet({
    required this.onLater,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: rh(context: context, px: 0),
        right: rh(context: context, px: 0),
        top: rh(context: context, px: 18),
        bottom: mq.viewInsets.bottom + rh(context: context, px: 24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rh(context: context, px: 24)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onLater,
                icon: const Icon(Icons.close),
              ),
            ),
            SizedBox(height: rh(context: context, px: 40)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 13),
              ),
              child: Text(
                "Update your preferences",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 25),
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                  letterSpacing: -1,
                ),
              ),
            ),
            SizedBox(height: rh(context: context, px: 16)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 13),
              ),
              child: Text(
                "Goal, activity, or food preferences are missing. Please update them before starting the test.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w400,
                  height: 1.30,
                  letterSpacing: -0.30,
                ),
              ),
            ),
            SizedBox(height: rh(context: context, px: 80)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 13),
              ),
              child: SizedBox(
                height: rh(context: context, px: 61),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onUpdate,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF308BF9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        rh(context: context, px: 2500),
                      ),
                    ),
                  ),
                  child: Text(
                    "Update",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w700,
                      height: 1.10,
                      letterSpacing: 0.30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedHabitsBottomSheet extends StatelessWidget {
  final VoidCallback onLater;
  final VoidCallback onUpdate;

  const _SelectedHabitsBottomSheet({
    required this.onLater,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: rh(context: context, px: 24),
        right: rh(context: context, px: 24),
        top: rh(context: context, px: 18),
        bottom: mq.viewInsets.bottom + rh(context: context, px: 24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rh(context: context, px: 24)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: rh(context: context, px: 20)),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: onLater,
                icon: const Icon(Icons.close),
              ),
            ),
            SizedBox(height: rh(context: context, px: 30)),
            Text(
              "Start Your Habit\nJourney",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: rh(context: context, px: 10)),
            Text(
              "Pick the level that fits you best and improve consistency one day at a time.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w400,
                height: 1.30,
                letterSpacing: -0.30,
              ),
            ),
            SizedBox(height: rh(context: context, px: 80)),
            SizedBox(
              width: double.infinity,
              height: rh(context: context, px: 61),
              child: ElevatedButton(
                onPressed: onUpdate,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF308BF9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      rh(context: context, px: 2500),
                    ),
                  ),
                ),
                child: Text(
                  "Get Started",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: rh(context: context, px: 15),
                    fontWeight: FontWeight.w700,
                    height: 1.10,
                    letterSpacing: 0.30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}