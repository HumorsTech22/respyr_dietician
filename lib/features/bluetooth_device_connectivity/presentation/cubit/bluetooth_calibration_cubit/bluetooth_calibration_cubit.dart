import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothCalibrationCubit extends Cubit<BluetoothCalibrationState> {
  final BluetoothRepository bluetoothRepo;
  final AudioHelper audioHelper;
  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  bool signalsAlreadySent = false;
  bool isDisposed = false;
  bool _isRunningCalibration = false;

  BluetoothCalibrationCubit(this.bluetoothRepo, this.audioHelper)
    : super(const BluetoothCalibrationState());

  void init() {
    _connSub = bluetoothRepo.connectionStatusStream().listen((connected) {
      handleBluetoothConnection(connected);
    });

    _dataSub = bluetoothRepo.receivedDataStream().listen((data) {
      onBluetoothDataReceived(data);
    });
  }

  Future<void> handleBluetoothConnection(bool connected) async {
    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected) {
      print("Bluetooth Connected");
      if (_isRunningCalibration) {
        _isRunningCalibration = true;
        await Future.delayed(Duration(seconds: 1));
        await _startCalibrationSequence();
      }
    } else {
      audioHelper.stopAudio();
      _dataSub?.cancel();
      _dataSub = null;
      _connSub?.cancel();
      _connSub = null;
      print("Bluetooth Disconnected");
    }

    if (!state.isDialogShown) {
      showDisconnectedDialog();
    }
  }

  void onBluetoothDataReceived(String data) {
    if (data.isEmpty) return;
    final normalized = data.trim().toLowerCase();
    print("Received Bluetooth Data: '$data' (normalized: '$normalized')");

    if (normalized.contains("inhale") && !state.navigateToInhaleScreen) {
      print("Inhale Detected -> Navigating to inhale screen");
      stop();
      emit(state.copyWith(navigateToInhaleScreen: true));
    }
  }

  void resetNavigationFlag() {
    emit(state.copyWith(navigateToInhaleScreen: false));
  }

  Future<void> sendCalibrationCommand(int step) async {
    try {
      if (step == 1) {
        final prefs = await SharedPreferences.getInstance();
        final signal = prefs.getString("isFirstReading") ?? "{";
        print("➡️ Sending calibration data to device...");
        await bluetoothRepo.sendData("?");
        await bluetoothRepo.sendData("}");
        await bluetoothRepo.sendData(signal);
        await bluetoothRepo.sendData("+");
        print("✅ Calibration data sent to device");
      }
    } catch (e) {
      print("❌ Failed to send data: $e");
      emit(
        state.copyWith(textError: "Failed to send data to Bluetooth device"),
      );
    }
  }

  Future<void> _startCalibrationSequence() async {
    signalsAlreadySent = false;

    for (int i = 1; i <= 5; i++) {
      if (isDisposed ||
          state.navigateToInhaleScreen ||
          !state.isBluetoothConnected) {
        return;
      }

      if (i < 5) {
        await Future.delayed(Duration(seconds: 20));
      }

      emit(state.copyWith(completedSteps: i));
      print("Calibration step completed: $i");

      if (!signalsAlreadySent) {
        await sendCalibrationCommand(1);
        signalsAlreadySent = true;
      }
    }
    print("🚦 Calibration steps done, waiting for inhale command...");
  }

  void toggleMute() => audioHelper.stopAudio();
  bool get isMuted => audioHelper.isMuted;

  void pause() {
    audioHelper.stopAudio();
    emit(state.copyWith(isMuted: false));
  }

  void resume() {
    emit(state.copyWith(isMuted: false));
    if (state.isBluetoothConnected) _startCalibrationSequence();
  }

  void stop() {
    isDisposed = true;
    _connSub?.cancel();
    _dataSub?.cancel();
    _connSub = null;
    _dataSub = null;
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }

  void showDisconnectedDialog() {
    if (!state.isDialogShown) {
      emit(state.copyWith(isDialogShown: true));
    }
  }
}
