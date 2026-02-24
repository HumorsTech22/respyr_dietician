import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../../core/size/get_height.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import '../../../../bluetooth_device_connectivity/data/services/breathing_config_service.dart';
import '../../bloc/practice_flow_bloc.dart';
import '../../domain/enums/practice_test.dart';
import '../widgets/practice_menu.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/data/practice_test_inhale_params.dart';

class PracticeTestScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const PracticeTestScreen({super.key, required this.clientProfileModel});

  static const List<PracticeTestSteps> _steps = [
    PracticeTestSteps.connect,
    PracticeTestSteps.inhaleTest,
    PracticeTestSteps.exhaleTest,
    PracticeTestSteps.fullTest,
  ];

  void _goConnect(BuildContext context) {
    context.push(
      '${AppRoutes.practiceFlowShell}/${AppRoutes.startDeviceScreen}',
      extra: clientProfileModel,
    );
  }

  void _goInhale(BuildContext context, BreathingSettings settings) {
    context.push(
      '${AppRoutes.practiceFlowShell}/${AppRoutes.practiceTestInhaleScreen}',
      extra: PracticeTestInhaleParams(
        breathingSettings: settings,
        clientProfileModel: clientProfileModel,
      ),
    );
  }

  Widget _divider(BuildContext context) => Column(
    children: [
      SizedBox(height: rh(context: context, px: 20)),
      Container(
        height: rh(context: context, px: 1),
        color: const Color(0xFFD9D9D9),
      ),
      SizedBox(height: rh(context: context, px: 20)),
    ],
  );

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close,
              size: rh(context: context, px: 22),
              color: const Color(0xFF252525),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 20),
            vertical: rh(context: context, px: 20),
          ),
          child: FutureBuilder<BreathingSettings>(
            future: BreathingConfigService.fetchBreathingSettings(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.hasError || !snap.hasData) {
                return Center(
                  child: Text(
                    "Unable to load settings",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              final settings = snap.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Practice using your\nRespyr device",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 25),
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 28)),
                  Expanded(
                    child: BlocConsumer<PracticeFlowBloc, PracticeFlowState>(
                      listenWhen: (p, c) =>
                      p.isConnected != c.isConnected ||
                          p.bleError != c.bleError,
                      listener: (context, state) {
                        if (!state.isConnected) {
                          _showSnack(context, "Device disconnected");
                        }
                        final err = state.bleError;
                        if (err != null && err.trim().isNotEmpty) {
                          _showSnack(context, err);
                        }
                      },
                      builder: (context, state) {
                        return Column(
                          children: [
                            ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _steps.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (_, __) => _divider(context),
                              itemBuilder: (context, index) {
                                final step = _steps[index];
                                final enabled = state.isEnabled(step);
                                final completed = state.isCompleted(step);

                                return PracticeMenu(
                                  enabled: enabled,
                                  isStepCompleted: completed,
                                  practiceTestStep: step,
                                  onItemClicked: () {
                                    if (!enabled) return;

                                    if (step == PracticeTestSteps.connect) {
                                      _goConnect(context);
                                      return;
                                    }

                                    if (step == PracticeTestSteps.inhaleTest) {
                                      if (!state.isConnected) {
                                        _showSnack(context, "Connect the device first");
                                        return;
                                      }
                                      _goInhale(context, settings);
                                      return;
                                    }

                                    // Keep placeholders for future screens
                                    if (step == PracticeTestSteps.exhaleTest ||
                                        step == PracticeTestSteps.fullTest) {
                                      _showSnack(context, "Coming soon");
                                    }
                                  },
                                );
                              },
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: rh(context: context, px: 61),
                              child: ElevatedButton(
                                onPressed: () {
                                  _showSnack(context, "Complete the steps above");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF308BF9),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Text(
                                  "Begin Your Journey",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.10,
                                    letterSpacing: 0.30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}