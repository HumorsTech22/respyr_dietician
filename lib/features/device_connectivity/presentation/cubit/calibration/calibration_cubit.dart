import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/calibration/calibration_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalibrationCubit extends Cubit<CalibrationState> {
  final UsbCommunicationService usbService;
  final AudioHelper audioHelper;

  StreamSubscription<String>? _usbDataSubscription;
  bool signalsAlreadySent = false;
  bool isDisposed = false;
  bool _isRunningCalibration = false;
  bool _wasConnected = false;

  CalibrationCubit(this.usbService, this.audioHelper)
    : super(const CalibrationState());

  void init() {
    usbService.setUsbSerialListener(
      onConnectionStatusChanged: (status) async {
        final normalized = status.toLowerCase().trim();

        if (normalized == "connected") {
          _wasConnected = true; // mark that we have seen a connection
          handleUsbConnected(true);
        } else if (normalized == "disconnected") {
          handleUsbConnected(false);

          // 👇 only show dialog if device was connected before
          if (_wasConnected) {
            showDisconnectedDialog();
          }
        }
      },
      onError: (error) {
        print("❌ USB Error: $error");
        emit(state.copyWith(errorMessage: "USB Error: $error"));
      },
      onCommandSent: (cmd) {
        print("➡️ Command sent: $cmd");
      },
    );

    usbService.connect();
  }

  void handleUsbConnected(bool connected) async {
    emit(state.copyWith(isConnected: connected));

    if (connected) {
      print("🔌 Device connected");
      _usbDataSubscription ??= usbService.dataStream.listen(_onUsbDataReceived);

      if (!_isRunningCalibration) {
        _isRunningCalibration = true;
        await Future.delayed(const Duration(seconds: 1)); // let USB stabilize
        await _startCalibrationSequence();
        _isRunningCalibration = false;
      }
    } else {
      print("⚠️ Device disconnected");
      _usbDataSubscription?.cancel();
      _usbDataSubscription = null;
      audioHelper.stopAudio();
    }
  }

  void showDisconnectedDialog() {
    if (!state.isDialogShown) {
      emit(state.copyWith(isDialogShown: true));
    }
  }

  void _onUsbDataReceived(String data) {
    if (data.isEmpty) return;
    final normalized = data.trim().toLowerCase();
    print("⬅️ Received data: '$data' (normalized: '$normalized')");

    if (normalized.contains("inhale") && !state.navigateToInhaleScreen) {
      print("✅ Inhale detected → navigating to inhale screen");
      stop();
      emit(state.copyWith(navigateToInhaleScreen: true));
    }
  }

  Future<void> _startCalibrationSequence() async {
    signalsAlreadySent = false;

    for (int i = 1; i <= 5; i++) {
      if (isDisposed || state.navigateToInhaleScreen || !state.isConnected) {
        return; // stop if disconnected or navigation triggered
      }

      if (i < 5) {
        await Future.delayed(const Duration(seconds: 20));
      }

      emit(state.copyWith(completedSteps: i));
      print("⏳ Calibration step completed: $i");

      if (!signalsAlreadySent) {
        await sendStepSpecificData(1);
        signalsAlreadySent = true;
      }
    }

    print("🚦 Calibration steps done, waiting for inhale command...");
  }

  void resetNavigationFlag() {
    emit(state.copyWith(navigateToInhaleScreen: false));
  }

  Future<void> sendStepSpecificData(int step) async {
    try {
      if (step == 1) {
        final prefs = await SharedPreferences.getInstance();
        final signal = prefs.getString("isFirstReading") ?? "{";
        print("➡️ Sending calibration data to device...");
        await usbService.sendData("?");
        await usbService.sendData("}");
        await usbService.sendData(signal);
        await usbService.sendData("+");
        print("✅ Calibration data sent to device");
      }
    } catch (e) {
      print("❌ Failed to send data: $e");
      emit(state.copyWith(errorMessage: "Failed to send data to the device"));
    }
  }

  void toggleMute() => audioHelper.stopAudio();
  bool get isMuted => audioHelper.isMuted;

  void pause() {
    audioHelper.stopAudio();
    emit(state.copyWith(isMuted: true));
  }

  void resume() {
    emit(state.copyWith(isMuted: false));
    if (state.isConnected) _startCalibrationSequence();
  }

  void stop() {
    isDisposed = true;
    _usbDataSubscription?.cancel();
    _usbDataSubscription = null;
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
