import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_state.dart';

class BluetoothCalibrationCubit extends Cubit<BluetoothCalibrationState> {
  final BluetoothRepository repo;
  final AudioHelper _audioHelper;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;
  Timer? _inhaleTimeoutTimer;

  // ✅ NEW: screen open 100s timer
  Timer? _screenTimer;
  int _screenRemainingSeconds = 100;

  bool signalsAlreadySent = false;
  bool _isRunningCalibration = false;
  bool _disposed = false;

  BluetoothCalibrationCubit(this.repo, this._audioHelper)
      : super(const BluetoothCalibrationState()) {
    init();
  }

  void init() {
    _connSub = repo.connectionStatusStream().listen((connected) {
      handleBluetoothConnection(connected);
    });

    _dataSub = repo.receivedDataStream().listen((data) {
      onBluetoothDataReceived(data);
    });

    // ✅ NEW: start 100 seconds timer immediately when screen opens
    _startScreenTimer100s();

    // If already connected when cubit created
    if (repo.isConnected) {
      handleBluetoothConnection(true);
    }
  }

  // ✅ NEW: 100 seconds countdown on screen open
  void _startScreenTimer100s() {
    if (_disposed) return;

    _screenTimer?.cancel();
    _screenRemainingSeconds = 100;

    emit(
      state.copyWith(
        isTimeStarted: true,
        remainingSeconds: _screenRemainingSeconds,
        isTimeOver: false,
      ),
    );

    _screenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      // if already navigating, no need to keep timer running
      if (state.navigateToInhaleScreen) {
        timer.cancel();
        return;
      }

      _screenRemainingSeconds--;

      if (_screenRemainingSeconds <= 0) {
        timer.cancel();
        _screenRemainingSeconds = 0;

        emit(
          state.copyWith(
            remainingSeconds: 0,
            isTimeOver: true,
          ),
        );
        return;
      }

      emit(state.copyWith(remainingSeconds: _screenRemainingSeconds));
    });
  }

  Future<void> handleBluetoothConnection(bool connected) async {
    if (_disposed) return;

    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected) {
      // ✅ when reconnect happens, reset & restart timer again if needed
      // (kept minimal, not changing your flow)
      if (state.isTimeOver) {
        _startScreenTimer100s();
      }

      print("✅ Bluetooth Connected");

      // Start calibration only once
      if (!_isRunningCalibration) {
        _isRunningCalibration = true;
        await Future.delayed(const Duration(seconds: 1));
        _startCalibrationSequence();
      }
    } else {
      print("❌ Bluetooth Disconnected");

      _audioHelper.stopAudio();
      _inhaleTimeoutTimer?.cancel();
      _screenTimer?.cancel(); // ✅ NEW

      // reset calibration flags so it can start again on reconnect
      signalsAlreadySent = false;
      _isRunningCalibration = false;

      emit(
        state.copyWith(
          completedSteps: 0,
          waitForInhaleCmd: false,
          showPleaseWaitMessage: false,
          allSignalSent: false,
        ),
      );

      if (!state.isDialogShown) {
        showDisconnectedDialog();
      }
    }
  }

  void onBluetoothDataReceived(String data) {
    if (_disposed) return;
    if (data.isEmpty) return;

    final normalized = data.trim().toLowerCase();
    print("📨 Received Bluetooth Data: '$normalized'");

    if (normalized.contains("inhale") && !state.navigateToInhaleScreen) {
      print("➡️ Inhale detected → Navigating to inhale screen");

      _inhaleTimeoutTimer?.cancel();
      _screenTimer?.cancel(); // ✅ NEW
      _audioHelper.stopAudio();

      emit(
        state.copyWith(
          navigateToInhaleScreen: true,
          waitForInhaleCmd: false,
          showPleaseWaitMessage: false,
        ),
      );

      // If you want to stop streams once inhale received:
      _cancelStreamsOnly();
    }
  }

  Future<void> sendCalibrationCommand(int step) async {
    if (_disposed) return;
    if (!state.isBluetoothConnected) return;

    try {
      // You send the signals only once (at step 1)
      if (step == 1 && !signalsAlreadySent) {
        print("➡️ Sending calibration commands to device...");

        await repo.sendData("?");
        // await repo.sendData("}");
        await repo.sendData("{");
        // await repo.sendData("+");

        signalsAlreadySent = true;
        print("✅ Calibration commands sent successfully");

        // ✅ NOW mark as true
        emit(state.copyWith(allSignalSent: true));
      }
    } catch (e) {
      print("❌ Failed to send calibration commands: $e");
      emit(state.copyWith(textError: "Failed to send data to Bluetooth device"));
    }
  }

  void sendAbort() {
    repo.sendData("&");
  }

  Future<void> _startCalibrationSequence() async {
    if (_disposed) return;
    if (!state.isBluetoothConnected) return;

    // ✅ Reset flags at start
    signalsAlreadySent = false;
    emit(state.copyWith(allSignalSent: false));

    for (int i = 1; i <= 5; i++) {
      if (_disposed) return;
      if (!state.isBluetoothConnected) return;
      if (state.navigateToInhaleScreen) return;

      await Future.delayed(Duration(seconds: i == 1 ? 20 : 10));

      if (_disposed) return;
      if (!state.isBluetoothConnected) return;
      if (state.navigateToInhaleScreen) return;

      if (i == 3) _audioHelper.playActivatingSensors();
      if (i == 4) _audioHelper.playStartBreathTest();

      emit(state.copyWith(completedSteps: i));
      print("✅ Calibration step $i completed");

      await sendCalibrationCommand(i);
    }

    if (_disposed) return;

    // ✅ Done with calibration
    emit(state.copyWith(waitForInhaleCmd: true));
    print("🚦 Calibration sequence done, waiting for inhale...");

    _inhaleTimeoutTimer?.cancel();
    _inhaleTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_disposed) return;
      if (!state.navigateToInhaleScreen) {
        print("⏳ No inhale detected within 30s — showing please wait...");
        emit(state.copyWith(showPleaseWaitMessage: true));
      }
    });
  }

  void showDisconnectedDialog() {
    if (_disposed) return;
    emit(state.copyWith(isDialogShown: true));
  }

  void dialogDismissed() {
    if (_disposed) return;
    emit(state.copyWith(isDialogShown: false));
  }

  Future<void> disconnect() async {
    try {
      await repo.disconnect();
    } catch (e) {
      print("⚠️ disconnect failed: $e");
    } finally {
      if (_disposed) return;
      emit(state.copyWith(isBluetoothConnected: false));
    }
  }

  /// Cancel streams/timers but don't mark cubit disposed (so you can still emit if needed)
  void _cancelStreamsOnly() {
    _inhaleTimeoutTimer?.cancel();
    _screenTimer?.cancel(); // ✅ NEW
    _connSub?.cancel();
    _dataSub?.cancel();
  }

  void stop() {
    _cancelStreamsOnly();
    _audioHelper.stopAudio();
    _screenTimer?.cancel();
  }

  @override
  Future<void> close() {
    _inhaleTimeoutTimer?.cancel();
    _screenTimer?.cancel();
    _disposed = true;
    stop();
    return super.close();
  }

  void stopScreenOperation() {
    if (_disposed) return;

    _inhaleTimeoutTimer?.cancel();
    _screenTimer?.cancel();
    _audioHelper.stopAudio();

    emit(
      state.copyWith(
        waitForInhaleCmd: false,
        showPleaseWaitMessage: false,
      ),
    );
  }

}
