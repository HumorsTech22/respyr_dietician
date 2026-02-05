import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_state.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import '../../../../common/dialogs/exhale_timeout_dialog.dart';
import '../../../../core/size/get_height.dart';

class BluetoothCalibrationScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  const BluetoothCalibrationScreen({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  @override
  State<BluetoothCalibrationScreen> createState() => _BluetoothCalibrationScreenState();
}

class _BluetoothCalibrationScreenState extends State<BluetoothCalibrationScreen> {
  bool _dialogOpen = false;

  void _postFrame(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      fn();
    });
  }

  void _navigateToDashboard(BluetoothCalibrationCubit cubit) {
    cubit.dialogDismissed();
    context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
  }


  Future<bool> _showCancelDialog(BluetoothCalibrationCubit cubit, bool allSignalSent) async {
    // Set the flag to true when the dialog is opened
    _dialogOpen = true;

    final completer = Completer<bool>();  // Completer to handle dialog result

    _postFrame(() {
      showCancelTestDialog(context, () async {
        if (allSignalSent) cubit.sendAbort();  // Abort the test if needed
        completer.complete(true);  // Complete the completer
      });

      Future.microtask(() async {
        try {
          final res = await completer.future;
          if (!mounted) return;

          // Handle the result of the dialog
          if (res) {
            _navigateToDashboard(cubit);  // Navigate to dashboard on confirmation
          }
        } finally {
          // Reset the dialog state after the dialog is dismissed
          _dialogOpen = false;
        }
      });
    });

    return completer.future;  // Return the future of the dialog result
  }



  void _showTimeoutDialog(BluetoothCalibrationCubit cubit, BluetoothCalibrationState state) {
    if (_dialogOpen) return;
    _dialogOpen = true;
    _postFrame(() {
      showExhaleSessionTimeOutDialog(
        context: context,
        onButtonPressed: () {
          if (state.allSignalSent) cubit.sendAbort();
          _navigateToDashboard(cubit);
        },
        message: "Session timed out",
        description: "No response was received from the device. Please restart the test.",
      ).then((_) {
        _dialogOpen = false;  // Reset dialog state after dismissal
      });
    });
  }

  void _showErrorDialog(String msg) {
    if (_dialogOpen) return;
    _dialogOpen = true;

    _postFrame(() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(msg),
        ),
      ).then((_) {
        _dialogOpen = false;  // Reset dialog state after dismissal
      });
    });
  }

  void _showDisconnectedDialog(BluetoothCalibrationCubit cubit) {
    if (_dialogOpen) return;
    _dialogOpen = true;
    _postFrame(() {
      showDeviceDisconnectedBox(
        context: context,
        onButtonPressed: () async {
          if (!mounted) return;
          context.pop();
          if (!mounted) return;
          context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
        },
      ).then((_) {
        if (!mounted) return;
        _dialogOpen = false;  // Reset dialog state after dismissal
      });
    });
  }




  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => BluetoothCalibrationCubit(
        ctx.read<BluetoothRepository>(),
        AudioHelper(),
      ),
      child: BlocListener<BluetoothCalibrationCubit, BluetoothCalibrationState>(
        listenWhen: (prev, curr) =>
        prev.navigateToInhaleScreen != curr.navigateToInhaleScreen ||
            prev.textError != curr.textError ||
            prev.isDialogShown != curr.isDialogShown ||
            prev.isTimeOver != curr.isTimeOver ||
            prev.isBluetoothConnected != curr.isBluetoothConnected,
        listener: (context, state) {
          final cubit = context.read<BluetoothCalibrationCubit>();

          if (state.navigateToInhaleScreen) {
            _postFrame(() {
              cubit.stopScreenOperation();
              context.go(
                AppRoutes.bluetoothInhaleScreen,
                extra: {
                  "client": widget.clientProfileModel,
                  "strategy": widget.dietPlanStrategyModel,
                  "min_range": widget.minRange,
                  "max_range": widget.maxRange,
                },
              );
            });
            return;
          }

          if (state.isTimeOver && !state.navigateToInhaleScreen) {
            cubit.stopScreenOperation();
            _showTimeoutDialog(cubit, state);
            return;
          }

          if (state.textError != null) {
            _showErrorDialog(state.textError!);
            return;
          }

          if (state.isDialogShown) {
            _showDisconnectedDialog(cubit);
            return;
          }

          if(!state.isBluetoothConnected){
            _showDisconnectedDialog(cubit);
          }
        },
        child: BlocBuilder<BluetoothCalibrationCubit, BluetoothCalibrationState>(
          builder: (context, state) {
            final cubit = context.read<BluetoothCalibrationCubit>();

            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) async {
                if (didPop) return;

                if (state.isTimeOver && !state.navigateToInhaleScreen) {
                  if (state.allSignalSent) cubit.sendAbort();
                  _navigateToDashboard(cubit);
                  return;
                }

                await _showCancelDialog(cubit, state.allSignalSent);
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      onPressed: () => _showCancelDialog(cubit, state.allSignalSent),
                      icon: SvgPicture.asset("assets/images/common/closeicon.svg"),
                    )
                  ],
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(width: double.infinity, height: rh(context: context, px: 20)),
                      Text(
                        "Please wait...${state.remainingSeconds}",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 25),
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -1,
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: const AspectRatio(
                          aspectRatio: 1,
                          child: CircularProgressIndicator(
                            color: Color(0xFF308BF9),
                            backgroundColor: Color(0xFFE1E6ED),
                          ),
                        ),
                      ),
                      Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
