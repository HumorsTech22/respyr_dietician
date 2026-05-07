import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/calibration_params.dart';
import '../../../../routes/app_routes.dart';
import '../theme/test_conditions_tokens.dart';
import '../widgets/test_conditions_bottom_cta.dart';
import '../widgets/test_conditions_header.dart';
import '../widgets/test_conditions_sheet.dart';

class TestConditionsScreen extends StatelessWidget {
  final CalibrationParams calibrationParams;
  const TestConditionsScreen({super.key, required this.calibrationParams,});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        cancelTest(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: TestConditionsTokens.appBarBlue,
          actions: [
            Semantics(
              button: true,
              label: 'Close',
              child: IconButton(
                onPressed: () => cancelTest(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: TestConditionsTokens.gradientColors,
                stops: TestConditionsTokens.gradientStops,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TestConditionsHeader(),
                Expanded(child: TestConditionsSheet()),
              ],
            ),
          ),
        ),
        bottomNavigationBar: TestConditionsBottomCta(
          confirmedToNavigate: () async {
            final connected =  FlutterBluePlus.connectedDevices;

            if (connected.isNotEmpty) {
              _navigateToBluetooth(context);
            } else {
              showDeviceDisconnectedBox(
                context: context,
                onButtonPressed: () {
                  navigateToDashboard(context);
                },
              );
            }
          },
        ),
      ),
    );
  }

  void cancelTest(BuildContext context) {
    showCancelTestDialog(context, () {
      navigateToDashboard(context);
    });
  }

  void navigateToDashboard(BuildContext context) {
    context.go(
      AppRoutes.clientDashboard,
      extra: calibrationParams.clientProfileModel,
    );
  }

  void _navigateToBluetooth(BuildContext context) {
     final params = CalibrationParams(
         clientProfileModel: calibrationParams.clientProfileModel,
         dietPlanStrategyModel: calibrationParams.dietPlanStrategyModel,
         minRange: calibrationParams.minRange,
         maxRange: calibrationParams.maxRange,
         featuresAllowData: calibrationParams.featuresAllowData,
         userHabitsModel: calibrationParams.userHabitsModel
     );
    context.push(
      AppRoutes.bluetoothCalibrationScreen,
      extra: params,
    );
  }
}
