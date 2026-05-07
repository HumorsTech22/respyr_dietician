import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/exhale_screen_params.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../common/ble_logging/ble_logger_http.dart';
import '../../../../common/dialogs/cancel_Test_dialog.dart';
import '../../../../common/dialogs/disconnection_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../../data/datasource/bluetooth_manager.dart';
import '../../domain/params/generating_result_params.dart';
import '../../domain/processor/bluetooth_blow_processor.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_cubit.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_state.dart';
import '../widgets/exhale_failed.dart';
import '../widgets/exhale_screen_app_bar.dart';
import '../widgets/new_exhale_screen_2.dart';

class BluetoothNewExhaleScreen extends StatelessWidget {
  final ExhaleScreenParams exhaleScreenParams;
  const BluetoothNewExhaleScreen({super.key, required this.exhaleScreenParams});

  @override
  Widget build(BuildContext context) {
    final wrappedBase = "/${exhaleScreenParams.baseValue.trim()}/";

    return BlocProvider(
      create: (_) => BluetoothExhaleCubit(
        repo: context.read<BluetoothRepository>(),
        processor: BluetoothBlowProcessor(),
        baseValue: wrappedBase,
        breathingSettings: exhaleScreenParams.breathingSettings,
      ),
      child: _BluetoothNewExhaleScreenView(exhaleScreenParams: exhaleScreenParams,),
    );
  }
}

class _BluetoothNewExhaleScreenView extends StatefulWidget {

  final ExhaleScreenParams exhaleScreenParams;

  const _BluetoothNewExhaleScreenView({required this.exhaleScreenParams});

  @override
  State<_BluetoothNewExhaleScreenView> createState() =>
      _BluetoothNewExhaleScreenViewState();
}

class _BluetoothNewExhaleScreenViewState
    extends State<_BluetoothNewExhaleScreenView> {
  bool _disconnectDialogShown = false;
  bool _navigated = false;
  bool _cancelInProgress = false;
  bool _generatedPushed = false;

  @override
  void dispose() {
    _closeDisconnectDialogIfOpen();
    super.dispose();
  }

  Future<void> _onCancel(BuildContext context, BluetoothExhaleState state) async {
    if (_cancelInProgress) return;
    _cancelInProgress = true;

    _closeDisconnectDialogIfOpen();

    if (state.exhaleFailed) {
      await context.read<BluetoothExhaleCubit>().cancelTest();
      _cancelInProgress = false;
      return;
    }

    await showCancelTestDialog(context, () async {
      _closeDisconnectDialogIfOpen();
      await context.read<BluetoothExhaleCubit>().cancelTest();
    });

    _cancelInProgress = false;
  }

  Future<void> _showDisconnectDialog(BuildContext context) async {
    if (!mounted) return;
    if (_disconnectDialogShown) return;

    _disconnectDialogShown = true;

    await showDeviceDisconnectedBox(
      context: context,
      onButtonPressed: () {
        BleLoggerHttp.I.endSession(reason: "completed");
        _closeDisconnectDialogIfOpen();
        context.go(AppRoutes.clientDashboard, extra: widget.exhaleScreenParams.clientProfileModel);
      },
    );

    if (mounted) _disconnectDialogShown = false;
  }

  void _closeDisconnectDialogIfOpen() {
    if (!_disconnectDialogShown) return;
    try {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    } catch (_) {
      // ignore
    } finally {
      _disconnectDialogShown = false;
    }
  }

  void _goDashboardOnce() {
    if (!mounted) return;
    if (_navigated) return;
    _navigated = true;

    _closeDisconnectDialogIfOpen();
    context.go(AppRoutes.clientDashboard, extra: widget.exhaleScreenParams.clientProfileModel);
  }

  void _pushGeneratingOnce(BluetoothExhaleState state) {
    if (!mounted) return;
    if (_generatedPushed) return;
    if (state.blowValues.isEmpty) return;

    _generatedPushed = true;
    _closeDisconnectDialogIfOpen();

    final averageValue =
        state.blowValues.reduce((a, b) => a + b) / state.blowValues.length;

    final params = GeneratingResultParams(
      maxPressure: state.blowValues.reduce(max),
      bestPressure: averageValue,
      blowDuration: (state.inRangeDurationMs / 1000).toInt(),
      blowValuesList: state.blowValues,
      clientProfileModel: widget.exhaleScreenParams.clientProfileModel,
      dietPlanStrategyModel: widget.exhaleScreenParams.dietPlanStrategyModel,
      minRange: widget.exhaleScreenParams.minRange,
      maxRange: widget.exhaleScreenParams.maxRange, featuresAllowData: widget.exhaleScreenParams.featuresAllowData,
      userHabitsModel: widget.exhaleScreenParams.userHabitsModel,
    );

    context.go(AppRoutes.bluetoothGeneratingResultScreen, extra: params);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothExhaleCubit, BluetoothExhaleState>(
      listenWhen: (prev, curr) =>
      prev.isConnected != curr.isConnected ||
          prev.exhaleSuccess != curr.exhaleSuccess ||
          prev.exhaleFailed != curr.exhaleFailed ||
          prev.analysisReady != curr.analysisReady ||
          prev.navigateToDashboard != curr.navigateToDashboard ||
          prev.cancelTest != curr.cancelTest,
      listener: (context, state) async {
        if (!mounted) return;
        if (_navigated) return;

        if (state.cancelTest) {
          _closeDisconnectDialogIfOpen();
          if (state.navigateToDashboard) _goDashboardOnce();
          return;
        }

        if (state.navigateToDashboard) {
          _goDashboardOnce();
          return;
        }

        if (!state.isConnected) {
          unawaited(UuidBluetoothManager().clearAllConnections());
          await _showDisconnectDialog(context);
          return;
        } else {
          _closeDisconnectDialogIfOpen();
        }

        if (state.analysisReady) {
          _pushGeneratingOnce(state);
          return;
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          final state = context.read<BluetoothExhaleCubit>().state;
          await _onCancel(context, state);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: ExhaleScreenAppBar(
            context: context,
            cancelTestClicked: () async {
              final state = context.read<BluetoothExhaleCubit>().state;
              await _onCancel(context, state);
            },
          ),
          body: SafeArea(
            child: _ExhaleBody(
              clientProfileModel: widget.exhaleScreenParams.clientProfileModel,
              dietPlanStrategyModel: widget.exhaleScreenParams.dietPlanStrategyModel,
              minRange: widget.exhaleScreenParams.minRange,
              maxRange: widget.exhaleScreenParams.maxRange,
              breathingSettings: widget.exhaleScreenParams.breathingSettings,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExhaleBody extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final BreathingSettings breathingSettings;

  const _ExhaleBody({
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
    required this.breathingSettings,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothExhaleCubit, BluetoothExhaleState>(
      buildWhen: (p, c) =>
      p.exhaleFailed != c.exhaleFailed ||
          p.progress != c.progress ||
          p.inRange != c.inRange ||
          p.exhaleStarted != c.exhaleStarted ||
          p.holdSecondsLeft != c.holdSecondsLeft ||
          p.isConnected != c.isConnected ||
          p.error != c.error ||
          p.startTimeoutLeftSec != c.startTimeoutLeftSec ||
          p.startTimeoutRunning != c.startTimeoutRunning,
      builder: (context, state) {
        if (state.exhaleFailed) {
          return ExhaleFailed(
            state: state,
            onStartAgain: () async {
              await context.read<BluetoothExhaleCubit>().cancelTest();
            },
          );
        }

        return NewExhaleScreen2(
          state: state,
          breathingSettings: breathingSettings,
        );
      },
    );
  }
}