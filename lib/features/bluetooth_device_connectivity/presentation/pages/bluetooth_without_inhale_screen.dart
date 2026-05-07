import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/exhale_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/inhale_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/breathing_graph-1.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/dialogs/cancel_Test_dialog.dart';
import '../../../../common/dialogs/disconnection_dialog.dart';
import '../../../../core/size/get_height.dart';
import '../../../../features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../data/datasource/bluetooth_manager.dart';
import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_new_state.dart';
import '../cubit/bluetooth_without_inhale/bluetooth_without_inhale_cubit.dart';
import '../widgets/hold_breach_failed.dart';
import '../widgets/inhale_failed.dart';
import '../widgets/new_inhale_screen.dart';

// ✅ IMPORTANT: use SAME shared handoff class as original screen
import 'bluetooth_inhale_screen_new.dart';

class BluetoothWithoutInhaleScreen extends StatelessWidget {
  final InhaleScreenParams inhaleScreenParams;

  const BluetoothWithoutInhaleScreen({
    super.key,
    required this.inhaleScreenParams,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BluetoothWithoutInhaleCubit(
        context.read<BluetoothRepository>(),
        inhaleScreenParams.breathingSettings,
      ),
      child: _BluetoothWithoutInhaleView(
        inhaleScreenParams: inhaleScreenParams,
      ),
    );
  }
}

class _BluetoothWithoutInhaleView extends StatefulWidget {
  final InhaleScreenParams inhaleScreenParams;

  const _BluetoothWithoutInhaleView({
    required this.inhaleScreenParams,
  });

  @override
  State<_BluetoothWithoutInhaleView> createState() =>
      _BluetoothWithoutInhaleViewState();
}

class _BluetoothWithoutInhaleViewState
    extends State<_BluetoothWithoutInhaleView> {
  bool _disconnectDialogShown = false;
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothWithoutInhaleCubit, BluetoothInhaleCubitNewState>(
      listenWhen: (previous, current) =>
      previous.isConnected != current.isConnected ||
          previous.holdFinished != current.holdFinished ||
          previous.inhaleFailed != current.inhaleFailed ||
          previous.navigateToDashboard != current.navigateToDashboard ||
          previous.holdBreathViolation != current.holdBreathViolation,
      listener: (context, state) => _handleStateLogic(context, state),
      child: BlocBuilder<BluetoothWithoutInhaleCubit, BluetoothInhaleCubitNewState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              _onCancel(context: context, state: state);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: _buildAppBar(
                context: context,
                onBackClicked: () => _onCancel(context: context, state: state),
              ),
              body: SafeArea(
                bottom: false,
                child: _buildScreen(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required VoidCallback onBackClicked,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: onBackClicked,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildScreen(
      BuildContext context,
      BluetoothInhaleCubitNewState state,
      ) {
    if (state.inhaleFailed) {
      final bool isHoldBreach = state.holdBreathViolation.trim().isNotEmpty;

      if (isHoldBreach) {
        return HoldBreachFailed(
          text: state.holdBreathViolation.trim(),
          onStartAgain: () =>
              context.read<BluetoothWithoutInhaleCubit>().cancelTest(),
        );
      }

      final String msg = state.inhaleFailReason.trim().isNotEmpty
          ? state.inhaleFailReason.trim()
          : "Test failed.";

      return InhaleFailed(
        text: msg,
        onStartAgain: () =>
            context.read<BluetoothWithoutInhaleCubit>().cancelTest(),
      );
    }

    if (state.startCounterStarted && !state.startCounterFinished) {
      return _SeamlessWithoutInhaleCountdown(state: state);
    }

    final bool showInhaleOnlyTimer = state.startCounterFinished &&
        state.inhaleStarted &&
        !state.inhaleFinished &&
        !state.holdStarted;

    if (showInhaleOnlyTimer) {
      return _WithoutInhaleTimerView(state: state, inhaleScreenParams: widget.inhaleScreenParams,);
    }

    if (state.holdStarted && !state.holdFinished) {
      return NewInhaleScreen(
        state: state,
        breathingSettings: widget.inhaleScreenParams.breathingSettings,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        children: [
          const Spacer(),
          Center(
            child: Text(
              "Something went wrong\nPlease start again",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  context.read<BluetoothWithoutInhaleCubit>().cancelTest(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF308BF9),
                padding: EdgeInsets.symmetric(
                  vertical: rh(context: context, px: 16),
                ),
                elevation: 0,
              ),
              child: Text(
                "Start Again",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w700,
                  height: rh(context: context, px: 1.0),
                  letterSpacing: rh(context: context, px: 0.30),
                ),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 48)),
        ],
      ),
    );
  }

  void _handleStateLogic(
      BuildContext context,
      BluetoothInhaleCubitNewState state,
      ) async {
    if (!mounted) return;
    if (_navigated) return;

    if (state.navigateToDashboard) {
      _navigated = true;
      _closeDisconnectDialogIfOpen(context);
      context.go(
        AppRoutes.clientDashboard,
        extra: widget.inhaleScreenParams.clientProfileModel,
      );
      return;
    }

    if (!state.isConnected) {
      UuidBluetoothManager().clearAllConnections();
      await _showDisconnectDialog(context);
    } else {
      _closeDisconnectDialogIfOpen(context);
    }

    if (state.inhaleFailed) return;

    if (state.holdFinished) {
      _navigated = true;
      _closeDisconnectDialogIfOpen(context);

      final params = ExhaleScreenParams(
        clientProfileModel: widget.inhaleScreenParams.clientProfileModel,
        baseValue: state.blowExhaleBaseValue.toStringAsFixed(2),
        dietPlanStrategyModel: widget.inhaleScreenParams.dietPlanStrategyModel,
        minRange: widget.inhaleScreenParams.minRange,
        maxRange: widget.inhaleScreenParams.maxRange,
        breathingSettings: widget.inhaleScreenParams.breathingSettings,
        featuresAllowData: widget.inhaleScreenParams.featuresAllowData,
        userHabitsModel: widget.inhaleScreenParams.userHabitsModel,
      );

      context.go(
        AppRoutes.bluetoothExhaleScreen,
        extra: params,
      );
    }
  }

  void _onCancel({
    required BuildContext context,
    required BluetoothInhaleCubitNewState state,
  }) {
    if (state.inhaleFailed) {
      context.read<BluetoothWithoutInhaleCubit>().cancelTest();
      return;
    }

    showCancelTestDialog(context, () async {
      context.read<BluetoothWithoutInhaleCubit>().cancelTest();
    });
  }

  Future<void> _showDisconnectDialog(BuildContext context) async {
    if (!mounted) return;
    if (_disconnectDialogShown) return;

    _disconnectDialogShown = true;

    await showDeviceDisconnectedBox(
      context: context,
      onButtonPressed: () {
        context.read<BluetoothWithoutInhaleCubit>().cancelTest();
      },
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


class _WithoutInhaleTimerView extends StatefulWidget {
  final BluetoothInhaleCubitNewState state;
  final InhaleScreenParams inhaleScreenParams;

  const _WithoutInhaleTimerView({
    required this.state,
    required this.inhaleScreenParams,
  });

  @override
  State<_WithoutInhaleTimerView> createState() => _WithoutInhaleTimerViewState();
}

class _WithoutInhaleTimerViewState extends State<_WithoutInhaleTimerView> {
  final ValueNotifier<double> _reading = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _reading.value = widget.state.progress;
  }

  @override
  void didUpdateWidget(covariant _WithoutInhaleTimerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.progress != widget.state.progress ||
        oldWidget.state.progressSigned != widget.state.progressSigned) {
      _reading.value = widget.state.progress;
    }
  }

  @override
  void dispose() {
    _reading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;


    final int inhaleTotalTime =
    (state.inhaleNeedTotalMillis / 1000).round().clamp(0, 9999);

    final int inhaleRemaining =
    (inhaleTotalTime - state.inBandSeconds.round()).clamp(0, inhaleTotalTime);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              "Inhale",
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
          SizedBox(height: rh(context: context, px: 20)),
          SizedBox(
            width: double.infinity,
            child: Text(
              "Inhale through your nose",
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
          SizedBox(height: rh(context: context, px: 22)),
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final safeH = (constraints.maxHeight <= 0)
                    ? rh(context: ctx, px: 300)
                    : constraints.maxHeight;

                final bool holdFlag = state.holdStarted;

                return Center(
                  child: RepaintBoundary(
                    child: BreathingTargetGraph(
                      reading: _reading,
                      height: safeH,
                      targetMin: widget
                          .inhaleScreenParams.breathingSettings.inhale.minBand
                          .toDouble(),
                      targetMax: widget
                          .inhaleScreenParams.breathingSettings.inhale.maxBand
                          .toDouble(),
                      hold: true,
                      holdCounter: inhaleRemaining,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: rh(context: context, px: 127)),

        ],
      ),
    );
  }
}

class _SeamlessWithoutInhaleCountdown extends StatefulWidget {
  final BluetoothInhaleCubitNewState state;

  const _SeamlessWithoutInhaleCountdown({
    required this.state,
  });

  @override
  State<_SeamlessWithoutInhaleCountdown> createState() =>
      _SeamlessWithoutInhaleCountdownState();
}

class _SeamlessWithoutInhaleCountdownState
    extends State<_SeamlessWithoutInhaleCountdown> {
  late VideoPlayerController _c3;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // 🚨 MAGIC: use SAME handoff as original inhale screen
    if (SharedVideoHandOff.controller != null) {
      _c3 = SharedVideoHandOff.controller!;
      _initialized = true;
    } else {
      _c3 = VideoPlayerController.asset(
        'assets/images/calibration/cali3.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _c3.initialize().then((_) {
        if (!mounted) return;
        _c3.setVolume(0.0);
        _c3.seekTo(_c3.value.duration).then((_) {
          if (!mounted) return;
          setState(() {
            _initialized = true;
          });
        });
      });
    }
  }

  @override
  void dispose() {
    // Clean up the handoff after use so it's ready for the next test
    SharedVideoHandOff.controller = null;

    // 🚨 ANTI-STUTTER FIX: Save a reference to the video controller
    final videoToKill = _c3;

    // Delay the hardware cleanup by 500ms!
    // This allows the route transition animation to finish beautifully
    // before we block the main thread to destroy the media codec.
    Future.delayed(const Duration(milliseconds: 500), () {
      videoToKill.dispose();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: rh(context: context, px: 20)),
        SizedBox(
          height: rh(context: context, px: 40),
          width: double.infinity,
          child: RichText(
            key: ValueKey("countdown_${widget.state.startCounter}"),
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Starting in...",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: rh(context: context, px: -1),
              ),
              children: [
                TextSpan(
                  text: "${widget.state.startCounter}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF308BF9),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 8,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: _c3.value.size.width,
                        height: _c3.value.size.height,
                        child: VideoPlayer(_c3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}