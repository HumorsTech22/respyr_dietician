import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../common/dialogs/cancel_Test_dialog.dart';
import '../../../../common/dialogs/disconnection_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_cubit_new.dart';
import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_new_state.dart';
import '../widgets/new_inhale_screen.dart';
import '../widgets/new_start_test_counter_screen.dart' hide rh;
import '../../../../features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import '../../../../core/size/get_height.dart';
import '../widgets/test_failed_suggestion_item.dart';

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
          p.navigateToDashboard != c.navigateToDashboard ||
          p.holdBreathViolation != c.holdBreathViolation,
      listener: (context, state) => _handleStateLogic(context, state),
      child: BlocBuilder<BluetoothInhaleCubitNew, BluetoothInhaleCubitNewState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              _onCancel(context: context, state: state );
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: _buildAppBar( context: context, onBackClicked: () {
                _onCancel(context: context, state: state );
              }),
              body: SafeArea(child: _buildScreen(context, state)),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({required BuildContext context, required VoidCallback onBackClicked}) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () => {onBackClicked()},
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildScreen(BuildContext context, BluetoothInhaleCubitNewState state) {
    // ✅ FAILED UI
    if (state.inhaleFailed) {
      final isHoldBreach = state.holdBreathViolation.trim().isNotEmpty;

      if (isHoldBreach) {
        return HoldBreachFailed(
          text: state.holdBreathViolation.trim(),
          // ✅ restart properly (not cancel)
          onStartAgain: () => context.read<BluetoothInhaleCubitNew>().cancelTest(),
        );
      }

      final msg = state.inhaleFailReason.trim().isNotEmpty
          ? state.inhaleFailReason.trim()
          : "Test failed.";

      // ✅ Start again should restart, not cancel
      return InhaleFailed(
        text: msg,
        onStartAgain: () => context.read<BluetoothInhaleCubitNew>().cancelTest(),
      );
    }

    // ✅ COUNTER UI
    if (state.startCounterStarted && !state.startCounterFinished) {
      return NewStartTestCounterScreen(state: state);
    }

    // ✅ MAIN INHALE/HOLD UI
    if (state.startCounterFinished || (state.holdStarted && !state.holdFinished)) {
      return NewInhaleScreen(state: state);
    }

    return const Center(child: CircularProgressIndicator());
  }

  void _handleStateLogic(BuildContext context, BluetoothInhaleCubitNewState state) async {
    if (!mounted) return;
    if (_navigated) return;

    // ✅ Navigate out if cubit requests
    if (state.navigateToDashboard) {
      _navigated = true;
      _closeDisconnectDialogIfOpen(context);
      context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
      return;
    }

    // ✅ Disconnect dialog
    if (!state.isConnected) {
      await _showDisconnectDialog(context);
      return;
    } else {
      _closeDisconnectDialogIfOpen(context);
    }

    // ✅ If failed, stay on this screen (UI will show fail view)
    if (state.inhaleFailed) return;

    // ✅ Next screen after hold success
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

  void _onCancel({required BuildContext context, required BluetoothInhaleCubitNewState state }) {
    if(state.inhaleFailed){
       context.read<BluetoothInhaleCubitNew>().cancelTest();
    }else{
      showCancelTestDialog(context, () async {
        context.read<BluetoothInhaleCubitNew>().cancelTest();
      });
    }
  }

  Future<void> _showDisconnectDialog(BuildContext context) async {
    if (!mounted) return;
    if (_disconnectDialogShown) return;
    _disconnectDialogShown = true;
    await showDeviceDisconnectedBox(context: context, onButtonPressed: () { context.read<BluetoothInhaleCubitNew>().cancelTest(); });
    _disconnectDialogShown = false;
  }

  void _closeDisconnectDialogIfOpen(BuildContext context) {
    if (!_disconnectDialogShown) return;
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
    _disconnectDialogShown = false;
  }
}

class HoldBreachFailed extends StatelessWidget {
  final String text;
  final VoidCallback onStartAgain;

  const HoldBreachFailed({
    super.key,
    required this.text,
    required this.onStartAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Don’t inhale or exhale during hold",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 25),
              fontWeight: FontWeight.w600,
              height: rh(context: context, px: 1.29),
              letterSpacing: rh(context: context, px: -1),
            ),
          ),
          SizedBox(height: rh(context: context, px: 12)),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 16),
              fontWeight: FontWeight.w500,
              height: rh(context: context, px: 1.30),
              letterSpacing: rh(context: context, px: -0.20),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF308BF9),
                padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 18)),
                elevation: 0,
              ),
              child: Text(
                "START AGAIN",
                style: GoogleFonts.poppins(
                  fontSize: rh(context: context, px: 15),
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: rh(context: context, px: 1.10),
                  letterSpacing: rh(context: context, px: 0.30),
                ),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 65)),
        ],
      ),
    );
  }
}

class InhaleFailed extends StatelessWidget {
  final String text;
  final VoidCallback onStartAgain;

  const InhaleFailed({
    super.key,
    required this.text,
    required this.onStartAgain,
  });

  bool _isExhaleCase(String t) {
    final s = t.toLowerCase();
    return s.contains("exhale");
  }

  bool _isDroppedCase(String t) {
    return t.trim() == "Inhale dropped to 0";
  }

  @override
  Widget build(BuildContext context) {
    final isExhale = _isExhaleCase(text);
    final isDropped = _isDroppedCase(text);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isExhale ? "Oops! You exhaled instead of inhaling." : "Keep the ball in the range for longer",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 25),
              fontWeight: FontWeight.w600,
              height: rh(context: context, px: 1.29),
              letterSpacing: rh(context: context, px: -1),
            ),
          ),

          const Spacer(),

          if (isDropped) ...[
            Text(
              "Here’s how to get it right",
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 18),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.30),
                letterSpacing: rh(context: context, px: -0.36),
              ),
            ),
            SizedBox(height: rh(context: context, px: 24)),
            TestFailedSuggestionItem(
              step: "1",
              text: "Sit comfortably upright with your feet flat on the ground and shoulders back.",
            ),
            SizedBox(height: rh(context: context, px: 24)),
            TestFailedSuggestionItem(
              step: "2",
              text: "Place only the tip of the Respyr device into your mouth.",
            ),
            SizedBox(height: rh(context: context, px: 24)),
            TestFailedSuggestionItem(
              step: "3",
              text: "Keep your breathing slow, steady, and gentle throughout the test.",
            ),
          ],

          SizedBox(height: rh(context: context, px: 45)),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF308BF9),
                padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 18)),
                elevation: 0,
              ),
              child: Text(
                "START AGAIN",
                style: GoogleFonts.poppins(
                  fontSize: rh(context: context, px: 15),
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: rh(context: context, px: 1.10),
                  letterSpacing: rh(context: context, px: 0.30),
                ),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 19)),
        ],
      ),
    );
  }
}


