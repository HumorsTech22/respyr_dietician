import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/ble_logging/ble_logger_http.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/result_failed_dailog.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/generating_result_params.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../data/repository/bluetooth_repository.dart';
import '../../data/repository/generating_result_repository.dart';
import '../../domain/params/result_screen_params.dart';
import '../cubit/bluetooth_generating_result_cubit_new/bluetooth_generating_result_cubit.dart';
import '../cubit/bluetooth_generating_result_cubit_new/bluetooth_generating_result_state.dart';

class BluetoothGeneratingResultScreen extends StatefulWidget {
  final GeneratingResultParams generatingResultParams;
  const BluetoothGeneratingResultScreen({super.key, required this.generatingResultParams,});

  @override
  State<BluetoothGeneratingResultScreen> createState() =>
      _BluetoothGeneratingResultScreenState();
}

class _BluetoothGeneratingResultScreenState
    extends State<BluetoothGeneratingResultScreen> {
  late final BluetoothGeneratingResultCubit _cubit;

  bool _navigated = false;
  bool _showTurningOffBar = false;
  bool _disconnectDialogShown = false;

  Timer? _navigateTimer;

  late final TextStyle _titleStyle;
  late final TextStyle _barStyle;
  late final TextStyle _errorStyle;

  String? _lastShownError;

  bool _apiErrorDialogShown = false;

  @override
  void initState() {
    super.initState();

    _titleStyle = GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: 34,
      fontWeight: FontWeight.w400,
      letterSpacing: -2.04,
    );

    _barStyle = GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -0.72,
    );

    _errorStyle = GoogleFonts.poppins(
      color: Colors.red,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
    );

    _cubit = BluetoothGeneratingResultCubit(
      repo: context.read<BluetoothRepository>(),
      repository: context.read<GeneratingResultRepository>(),
      maxPressure: widget.generatingResultParams.maxPressure,
      bestPressure: widget.generatingResultParams.bestPressure,
      blowDuration: widget.generatingResultParams.blowDuration,
      blowValuesList: widget.generatingResultParams.blowValuesList,
      clientProfileModel: widget.generatingResultParams.clientProfileModel,
      dietPlanStrategyModel: widget.generatingResultParams.dietPlanStrategyModel,
      minRange: widget.generatingResultParams.minRange,
      maxRange: widget.generatingResultParams.maxRange, userHabitsModel: widget.generatingResultParams.userHabitsModel,
    );
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    _navigateTimer = null;
    _closeDisconnectDialogIfOpen();
    _cubit.close();
    super.dispose();
  }

  void _closeDisconnectDialogIfOpen() {
    if (!_disconnectDialogShown) return;
    try {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    } catch (_) {
      //
    } finally {
      _disconnectDialogShown = false;
    }
  }

  Future<void> _showDisconnectDialogOnce() async {
    if (!mounted) return;
    if (_disconnectDialogShown) return;

    _disconnectDialogShown = true;

    await showDeviceDisconnectedBox(
      context: context,
      onButtonPressed: () {
        if (!mounted) return;
        _cubit.dialogDismissed();
        context.go(
          AppRoutes.clientDashboard,
          extra: widget.generatingResultParams.clientProfileModel,
        );
      },
    );

    if (!mounted) return;
    _disconnectDialogShown = false;
  }


  Future<void> _showApiErrorDialogOnce(String message) async {
    if (!mounted) return;
    if (_apiErrorDialogShown) return;

    _apiErrorDialogShown = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ApiFailedDialog(
          message: message,
          onClose: () {
            context.go(
              AppRoutes.clientDashboard,
              extra: widget.generatingResultParams.clientProfileModel,
            );
          },
        );
      },
    );

    if (!mounted) return;
    _apiErrorDialogShown = false;
  }


  void _handleNavigationLogic(
      BuildContext context,
      BluetoothGeneratingResultState state,
      ) {
    if (!mounted) return;




    if (state.textError != null && state.textError!.trim().isNotEmpty) {
      _navigateTimer?.cancel();
      _navigateTimer = null;
      _showApiErrorDialogOnce(state.textError.toString());
      return;

    }

    if (state.isTimedOut) {
      _navigateTimer?.cancel();
      _navigateTimer = null;
      return;
    }

    final waitingForDeviceData =
        state.completedSteps < 2 && !state.navigateToResultScreen;

    if (!state.isBluetoothConnected && !_navigated && waitingForDeviceData) {
      _navigated = true;
      _showDisconnectDialogOnce();
      return;
    }

    if (state.isBluetoothConnected) {
      _closeDisconnectDialogIfOpen();
    }

    if (state.navigateToResultScreen && !_navigated) {
      _navigated = true;

      BleLoggerHttp.I.endSession(reason: "completed");

      _navigateTimer?.cancel();
      _navigateTimer = Timer(const Duration(seconds: 2), () async {
        if (!mounted) return;

        _cubit.sendAbort();

        if (mounted) {
          setState(() => _showTurningOffBar = true);
        }

        await Future.delayed(const Duration(milliseconds: 250));

        _cubit.resetNavigationFlag();

        final result = state.dietitianResult;
        if (result == null) {
          context.go(
            AppRoutes.clientDashboard,
            extra: widget.generatingResultParams.clientProfileModel,
          );
          return;
        }

        context.go(
          AppRoutes.dietitianResultScreen,
          extra: ResultScreenParamsNew(
            clientProfileModel: widget.generatingResultParams.clientProfileModel,
            respyrUnifiedResponse: result,
            featuresAllowData: widget.generatingResultParams.featuresAllowData,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<
          BluetoothGeneratingResultCubit,
          BluetoothGeneratingResultState>(
        listenWhen: (prev, next) =>
        prev.isTimedOut != next.isTimedOut ||
            prev.isDialogShown != next.isDialogShown ||
            prev.navigateToResultScreen != next.navigateToResultScreen ||
            prev.isBluetoothConnected != next.isBluetoothConnected ||
            prev.completedSteps != next.completedSteps ||
            prev.textError != next.textError,
        listener: _handleNavigationLogic,
        child: PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              leading: const SizedBox.shrink(),
            ),
            body: SafeArea(
              child: BlocBuilder<
                  BluetoothGeneratingResultCubit,
                  BluetoothGeneratingResultState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Generating result...",
                                textAlign: TextAlign.center,
                                style: _titleStyle,
                              ),
                            ),
                            const SizedBox(height: 20),
                            RepaintBoundary(
                              child: Image.asset(
                                'assets/images/gif_images/gif_generating_result.gif',
                                fit: BoxFit.contain,
                                gaplessPlayback: true,
                              ),
                            ),

                          ],
                        ),
                      ),
                      RepaintBoundary(
                        child: _TurningOffBar(
                          isVisible: _showTurningOffBar,
                          textStyle: _barStyle,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TurningOffBar extends StatelessWidget {
  final bool isVisible;
  final TextStyle textStyle;

  const _TurningOffBar({
    required this.isVisible,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: isVisible
            ? Container(
          key: const ValueKey('bar_on'),
          decoration: const BoxDecoration(color: Color(0xFFE1E6ED)),
          alignment: Alignment.center,
          child: Text(
            "Turning off device...",
            style: textStyle,
          ),
        )
            : const SizedBox(key: ValueKey('bar_off')),
      ),
    );
  }
}