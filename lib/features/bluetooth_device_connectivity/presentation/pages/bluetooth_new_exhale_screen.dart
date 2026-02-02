import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../common/dialogs/cancel_Test_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/params/generating_result_params.dart';
import '../../domain/processor/bluetooth_blow_processor.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_cubit.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_state.dart';
import '../widgets/new_exhale_screen_2.dart';

class BluetoothNewExhaleScreen extends StatelessWidget {
  final String baseValue; // coming from inhale phase (likely numeric)
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  const BluetoothNewExhaleScreen({
    super.key,
    required this.baseValue,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  @override
  Widget build(BuildContext context) {
    // Base value in cubit expects "/913.36/" format -> we wrap it here.
    final wrappedBase = "/${baseValue.trim()}/";

    return BlocProvider(
      create: (_) => BluetoothExhaleCubit(
        repo: context.read<BluetoothRepository>(),
        processor: BluetoothBlowProcessor(),
        baseValue: wrappedBase,
      ),
      child: _BluetoothNewExhaleScreenView(
        clientProfileModel: clientProfileModel,
        dietPlanStrategyModel: dietPlanStrategyModel,
        minRange: minRange,
        maxRange: maxRange,
      ),
    );
  }
}

class _BluetoothNewExhaleScreenView extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  const _BluetoothNewExhaleScreenView({
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  @override
  State<_BluetoothNewExhaleScreenView> createState() =>
      _BluetoothNewExhaleScreenViewState();
}

class _BluetoothNewExhaleScreenViewState extends State<_BluetoothNewExhaleScreenView> {
  bool _disconnectDialogShown = false;

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed:(){
            _onCancel(context);
          },
        ),
      ],
    );
  }


  void _onCancel(BuildContext context) {
    showCancelTestDialog(context, () async {
      await context.read<BluetoothExhaleCubit>().cancelTest();
    });
  }

  Future<void> _showDisconnectDialog(BuildContext context) async {
    if (_disconnectDialogShown) return;
    _disconnectDialogShown = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Device Disconnected",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Please reconnect your device to continue.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
            },
            child: Text("Cancel", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    _disconnectDialogShown = false;
  }

  void _closeDisconnectDialogIfOpen(BuildContext context) {
    if (!_disconnectDialogShown) return;
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
    _disconnectDialogShown = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothExhaleCubit, BluetoothExhaleState>(
      listenWhen: (prev, curr) =>
      prev.isConnected != curr.isConnected ||
          prev.exhaleSuccess != curr.exhaleSuccess ||
          prev.exhaleFailed != curr.exhaleFailed ||
          prev.analysisReady != curr.analysisReady ||
          prev.navigateToDashboard != curr.navigateToDashboard ,
      listener: (context, state) {
        if (!state.isConnected) {
          _showDisconnectDialog(context);
          return;
        } else {
          _closeDisconnectDialogIfOpen(context);
        }

        if (state.analysisReady) {
          double averageValue = state.blowValues.reduce((a, b) => a + b) / state.blowValues.length;
          final dummyParams = GeneratingResultParams(
            maxPressure: state.blowValues.reduce(max),
            bestPressure: averageValue,
            blowDuration: (state.inRangeDurationMs / 1000).toInt(),
            blowValuesList: state.blowValues,
            clientProfileModel:widget.clientProfileModel,
            dietPlanStrategyModel: widget.dietPlanStrategyModel,
            minRange: widget.minRange,
            maxRange: widget.maxRange,
          );
           context.push(
            AppRoutes.bluetoothGeneratingResultScreen,
            extra:  dummyParams,
          );
        }


        if(state.navigateToDashboard){
          context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
        }

        if (state.exhaleFailed) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Test Failed",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              content: Text(
                state.error ?? "Exhale failed. Please try again.",
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK", style: GoogleFonts.poppins()),
                ),
              ],
            ),
          );
        }
      },
      child: BlocBuilder<BluetoothExhaleCubit, BluetoothExhaleState>(
        buildWhen: (p, c) =>
        p.progress != c.progress ||
            p.inRange != c.inRange ||
            p.exhaleStarted != c.exhaleStarted ||
            p.holdSecondsLeft != c.holdSecondsLeft ||
            p.isConnected != c.isConnected,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _appBar(context),
            body: SafeArea(
              child: NewExhaleScreen2(
                state: state,
              ),
            ),
          );
        },
      ),
    );
  }
}
