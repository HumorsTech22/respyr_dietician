import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/common/dialogs/bluetooth_enable_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/device_inhale_or_exhale_mode.dart';
import 'package:respyr_dietitian/common/dialogs/device_low_battery.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/calibration_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/device_connectivity_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/device_section.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import 'package:respyr_dietitian/common/ble_logging/ble_logger_http.dart';

class BluetoothDeviceConnectivity extends StatelessWidget {

  final DeviceConnectivityParams deviceConnectivityParams;

  const BluetoothDeviceConnectivity({
    super.key, required this.deviceConnectivityParams,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => BluetoothConnectionCubit(ctx.read<BluetoothRepository>())
        ..init(profileId: deviceConnectivityParams.clientProfileModel.profileId),
      child: _BluetoothDeviceConnectivityView(deviceConnectivityParams: deviceConnectivityParams,),
    );
  }
}

class _BluetoothDeviceConnectivityView extends StatefulWidget {

  final DeviceConnectivityParams deviceConnectivityParams;


  const _BluetoothDeviceConnectivityView({required this.deviceConnectivityParams});

  @override
  State<_BluetoothDeviceConnectivityView> createState() =>
      __BluetoothDeviceConnectivityViewState();
}

class __BluetoothDeviceConnectivityViewState
    extends State<_BluetoothDeviceConnectivityView> {
  bool _dialogShown = false;
  bool _exiting = false;

  // Timeout duration for scanning
  static const Duration _scanTimeout = Duration(seconds: 15);
  int _scanRetryCount = 0;
  final int _maxRetryCount = 3;
  bool _isScanning = false;
  bool _isConnecting = false;

  Future<void> _safeExit() async {
    if (_exiting) return;
    _exiting = true;

    final cubit = context.read<BluetoothConnectionCubit>();

    // Best-effort cleanup
    try {
      cubit.sendAbort();
    } catch (_) {}

    try {
      await cubit.disconnect();
      await cubit.close();
    } catch (_) {}

    // Optional: hard clear (kept but safe)
    try {
      await UuidBluetoothManager().stopScan();
    } catch (_) {}

    if (!mounted) return;
    _navigateToDashboard();
  }

  Future<void> _retryConnection() async {
    // Check if the max retry attempts have been reached
    if (_scanRetryCount >= _maxRetryCount) {
      _showErrorMessage("Maximum retry attempts reached.");
      return;
    }

    _scanRetryCount++;

    try {
      final cubit = context.read<BluetoothConnectionCubit>();
      await cubit.disconnect();
      await cubit.close();
      await cubit.init(profileId: widget.deviceConnectivityParams.clientProfileModel.profileId); // Retry initialization
    } catch (e) {
      _showErrorMessage("Connection failed: $e");
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _startScan() async {
    if (_isScanning) return; // Prevent multiple scan attempts

    setState(() {
      _isScanning = true;
    });

    final cubit = context.read<BluetoothConnectionCubit>();

    try {
      await cubit.init(profileId: widget.deviceConnectivityParams.clientProfileModel.profileId);
      await UuidBluetoothManager().startScan(); // Start scanning
      _scanRetryCount = 0; // Reset retry count after a successful scan start
    } catch (e) {
      _showErrorMessage("Scan failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    print("testAllow");
    print(widget.deviceConnectivityParams.featuresAllowData.testAllow);
    print(widget.deviceConnectivityParams.featuresAllowData.practiceTestAllow);
    print(widget.deviceConnectivityParams.featuresAllowData.detailedScores);
    print(widget.deviceConnectivityParams.featuresAllowData.dieticianId);

    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        // canPop=false so back won't pop; we handle exit ourselves
        _safeExit();
      },
      child: StreamBuilder<fbp.BluetoothAdapterState>(
        stream: fbp.FlutterBluePlus.adapterState,
        initialData: fbp.BluetoothAdapterState.unknown,
        builder: (context, snapshot) {
          final adapterState = snapshot.data;

          if (adapterState == fbp.BluetoothAdapterState.unknown) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF308BF9)),
              ),
            );
          }

          if (adapterState != fbp.BluetoothAdapterState.on && !_dialogShown) {
            _dialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showBluetoothEnableDialog(
                context: context,
                onButtonPressed: () {
                  fbp.FlutterBluePlus.turnOn();
                },
              ).then((_) => _dialogShown = false);
            });
          }

          if (adapterState == fbp.BluetoothAdapterState.on && _dialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              _dialogShown = false;
            });
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: _safeExit,
                  icon: SvgPicture.asset("assets/images/common/closeicon.svg"),
                ),
              ],
            ),
            backgroundColor: Colors.white,
              body: SafeArea(
                child: BlocListener<BluetoothConnectionCubit, BluetoothConnectionState>(
                  listenWhen: (prev, curr) {
                    // 1. Only listen if we just ENTERED inhale/exhale mode
                    final enteredMode = !prev.deviceIsInhaleOrExhaleMode &&
                        curr.deviceIsInhaleOrExhaleMode;

                    // 2. Only listen if LOW_BATTERY just appeared
                    final lowBatteryAppeared = (!prev.isDeviceError || prev.textError != "LOW_BATTERY") &&
                        (curr.isDeviceError && curr.textError == "LOW_BATTERY");

                    return enteredMode || lowBatteryAppeared;
                  },
                  listener: (context, state) {
                    // Notice: Removed 'await' on showDialog.
                    // It's safer to let the dialog manage its own lifecycle
                    // rather than holding up the BlocListener's execution.

                    if (state.deviceIsInhaleOrExhaleMode) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => PopScope( // Replaced deprecated WillPopScope
                          canPop: false,
                          child: DeviceInhaleOrExhaleMode(
                            onOk: () async {
                              if (context.mounted) await _safeExit();
                            },
                          ),
                        ),
                      );
                    } else if (state.isDeviceError && state.textError == "LOW_BATTERY") {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => PopScope( // Replaced deprecated WillPopScope
                          canPop: false,
                          child: DeviceLowBattery(
                            message: state.textError ?? '',
                            onOk: () async {
                              if (context.mounted) await _safeExit();
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
                    builder: (context, state) {
                      if (adapterState != fbp.BluetoothAdapterState.on) {
                        return _bluetoothOffUI();
                      }
                      return DeviceSection(state: state);
                    },
                  ),
                ),
              ),
            bottomNavigationBar: _bottomButton(),
          );
        },
      ),
    );
  }

  Widget _bottomButton() {
    return SafeArea(
      top: false,
      child: BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
        builder: (context, state) {
          final isReady = state.deviceReady == true;
          final canStart = state.isConnected && isReady;

          String buttonText;
          if (!state.isConnected && state.isScanning) {
            buttonText = "Start";
          } else if (state.isConnected && !isReady) {
            buttonText = "Checking device...";
          } else {
            buttonText = "Start";
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canStart
                    ? () {

                  final params = CalibrationParams(
                      clientProfileModel: widget.deviceConnectivityParams.clientProfileModel,
                      dietPlanStrategyModel: widget.deviceConnectivityParams.dietPlanStrategyModel,
                      minRange: widget.deviceConnectivityParams.minRange,
                      maxRange: widget.deviceConnectivityParams.maxRange,
                      featuresAllowData: widget.deviceConnectivityParams.featuresAllowData,
                      userHabitsModel: widget.deviceConnectivityParams.userHabitsModel

                  );

                  if (widget.deviceConnectivityParams.isTestTaken) {
                    context.go(
                      AppRoutes.retakeTestScreen,
                      extra: widget.deviceConnectivityParams,
                    );
                  } else {


                    context.push(AppRoutes.bluetoothCalibrationScreen, extra: params,);
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  backgroundColor: canStart
                      ? const Color(0xFF308BF9)
                      : const Color(0xFFD9D9D9),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    color: canStart ? Colors.white : const Color(0xFF959595),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bluetoothOffUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/device_connection/bluetooth_disconnected.svg",
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(
            'Bluetooth is Off',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please enable Bluetooth to connect a device',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {
    BleLoggerHttp.I.endSession(reason: "completed");
    context.go(
      AppRoutes.clientDashboard,
      extra: widget.deviceConnectivityParams.clientProfileModel,
    );
  }
}