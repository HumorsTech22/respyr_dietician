import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../common/dialogs/cancel_Test_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_cubit_new.dart';
import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_new_state.dart';
import '../widgets/new_inhale_screen.dart';
import '../widgets/new_start_test_counter_screen.dart';
import '../../../../features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';

enum InhaleView { loading, countdown, inhale, hold, failed }

class BluetoothInhaleScreenNew extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  const BluetoothInhaleScreenNew({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BluetoothInhaleCubitNew(context.read<BluetoothRepository>()),
      child: _InhaleViewScaffold(
        clientProfileModel: clientProfileModel,
        dietPlanStrategyModel: dietPlanStrategyModel,
        minRange: minRange,
        maxRange: maxRange,
      ),
    );
  }
}

class _InhaleViewScaffold extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  const _InhaleViewScaffold({
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  @override
  State<_InhaleViewScaffold> createState() => _InhaleViewScaffoldState();
}

class _InhaleViewScaffoldState extends State<_InhaleViewScaffold> {
  bool _disconnectDialogShown = false;
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothInhaleCubitNew, BluetoothInhaleCubitNewState>(
      listenWhen: (p, c) =>
      p.isConnected != c.isConnected ||
          p.holdFinished != c.holdFinished ||
          p.inhaleFailed != c.inhaleFailed ||
          p.navigateToDashboard != c.navigateToDashboard,
      listener: (context, state) => _handleStateLogic(context, state),
      child: BlocBuilder<BluetoothInhaleCubitNew, BluetoothInhaleCubitNewState>(
        builder: (context, state) {
          final view = _resolveView(state);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              actions: [
                IconButton(
                  onPressed: () => _onCancel(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: _buildBody(view, state),
          );
        },
      ),
    );
  }

  InhaleView _resolveView(BluetoothInhaleCubitNewState s) {
    if (s.inhaleFailed) return InhaleView.failed;
    if (s.startCounterStarted && !s.startCounterFinished) return InhaleView.countdown;
    if (s.holdStarted && !s.holdFinished) return InhaleView.hold;
    if (s.startCounterFinished) return InhaleView.inhale;
    return InhaleView.loading;
  }

  String _failureText(BluetoothInhaleCubitNewState s) {
    if (s.holdBreathViolation.trim().isNotEmpty) return s.holdBreathViolation.trim();
    return s.inhaleFailReason.trim().isNotEmpty ? s.inhaleFailReason.trim() : "Test failed.";
  }

  Widget _buildBody(InhaleView view, BluetoothInhaleCubitNewState state) {
    switch (view) {
      case InhaleView.failed:
        return _StatusText(text: _failureText(state));

      case InhaleView.countdown:
        return SafeArea(child: NewStartTestCounterScreen(state: state));

      case InhaleView.hold:
      case InhaleView.inhale:
        return SafeArea(child: NewInhaleScreen(state: state));

      case InhaleView.loading:
        return const Center(child: CircularProgressIndicator());
    }
  }

  void _handleStateLogic(BuildContext context, BluetoothInhaleCubitNewState state) async {
    if (!mounted) return;

    // ✅ 0) Already navigated? ignore further events
    if (_navigated) return;

    // ✅ 1) NAVIGATION PRIORITY (cancel always wins)
    if (state.navigateToDashboard) {
      _navigated = true;
      _closeDisconnectDialogIfOpen(context);
      context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
      return;
    }

    // ✅ 2) DISCONNECT DIALOG (only if not navigating)
    if (!state.isConnected) {
      await _showDisconnectDialog(context);
      return;
    } else {
      _closeDisconnectDialogIfOpen(context);
    }

    // ✅ 3) If failed, stop here (UI already shows failed view)
    if (state.inhaleFailed) return;

    if (state.holdFinished) {
      _navigated = true;
      _closeDisconnectDialogIfOpen(context);
      context.go(
        AppRoutes.bluetoothExhaleScreen,
        extra: {
          "clientProfileModel": widget.clientProfileModel,
          "dietPlanStrategyModel": widget.dietPlanStrategyModel,
          "baseValue": state.blowExhaleBaseValue.toStringAsFixed(2),
          "min_range": widget.minRange,
          "max_range": widget.maxRange,
        },
      );
    }

  }

  void _onCancel(BuildContext context) {
    showCancelTestDialog(context, () async {
      await context.read<BluetoothInhaleCubitNew>().cancelTest();
    });
  }

  Future<void> _showDisconnectDialog(BuildContext context) async {
    if (!mounted) return;
    if (_disconnectDialogShown) return;

    _disconnectDialogShown = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Device Disconnected"),
        content: const Text("Please reconnect your device to continue."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text("Retry"),
          ),
          TextButton(
            onPressed: () async {
              // ✅ Use cancelTest() so rules apply:
              // - save time only after hold started
              // - send '&' only if connected
              // - navigateToDashboard true
              Navigator.pop(ctx);
              await context.read<BluetoothInhaleCubitNew>().cancelTest();
            },
            child: const Text("Cancel"),
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
}

class _StatusText extends StatelessWidget {
  final String text;
  const _StatusText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF252525),
          ),
        ),
      ),
    );
  }
}
