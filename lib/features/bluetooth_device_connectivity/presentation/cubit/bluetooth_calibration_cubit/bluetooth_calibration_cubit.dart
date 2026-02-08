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

  Timer? _screenTimer;
  Timer? _inhaleTimeoutTimer;

  // ✅ NEW: handshake loop timers/flags
  Timer? _ackRetryTimer;
  static const Duration _ackWait = Duration(seconds: 10);
  bool _calibrationAckReceived = false;
  bool _handshakeLoopRunning = false;

  int _screenRemainingSeconds = 100;

  bool _isRunningCalibration = false;
  bool _disposed = false;

  BluetoothCalibrationCubit(this.repo, this._audioHelper)
      : super(const BluetoothCalibrationState()) {
    init();
  }

  void init() {
    _connSub = repo.connectionStatusStream().listen(handleBluetoothConnection);
    _dataSub = repo.receivedDataStream().listen(onBluetoothDataReceived);

    // If already connected when screen opens
    if (repo.isConnected) {
      handleBluetoothConnection(true);
    }
  }

  // ===================== CONNECTION =====================

  Future<void> handleBluetoothConnection(bool connected) async {
    if (_disposed) return;

    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected) {
      // ✅ Start infinite ?{ loop until ACK '{' received
      _startHandshakeLoop();
    } else {
      _stopAll();

      if (!state.isDialogShown) showDisconnectedDialog();
    }
  }

  // ===================== DATA =====================

  void onBluetoothDataReceived(String data) {
    if (_disposed || data.isEmpty) return;

    final normalized = data.trim().toLowerCase();

    // ✅ ACK: device entered calibration mode
    // You said: within 10 sec device sends '{' if successful
    if (!_calibrationAckReceived && normalized == "{") {
      _calibrationAckReceived = true;
      _stopHandshakeLoop(); // ✅ stop resending ?{

      // ✅ start 100 sec timer ONLY after ACK
      _startScreenTimer100s();

      // ✅ now start calibration sequence (progress steps/audio)
      if (!_isRunningCalibration) {
        _isRunningCalibration = true;
        Future.delayed(const Duration(seconds: 1), _startCalibrationSequence);
      }
      return;
    }

    // Existing inhale logic
    if (normalized.contains("inhale") && !state.navigateToInhaleScreen) {
      _inhaleTimeoutTimer?.cancel();
      _screenTimer?.cancel();
      _audioHelper.stopAudio();

      emit(state.copyWith(
        navigateToInhaleScreen: true,
        waitForInhaleCmd: false,
        showPleaseWaitMessage: false,
      ));

      _cancelStreamsOnly();
    }
  }

  // ===================== HANDSHAKE LOOP (?{) =====================

  void _startHandshakeLoop() {
    if (_disposed) return;
    if (_handshakeLoopRunning) return;

    _handshakeLoopRunning = true;
    _calibrationAckReceived = false;

    // reset UI a bit (optional)
    emit(state.copyWith(
      isTimeStarted: false,
      isTimeOver: false,
      remainingSeconds: 100,
      completedSteps: 0,
      waitForInhaleCmd: false,
      showPleaseWaitMessage: false,
      allSignalSent: false,
      navigateToInhaleScreen: false,
    ));

    _sendHandshakeAndWait();
  }

  Future<void> _sendHandshakeAndWait() async {
    if (_disposed || !state.isBluetoothConnected) return;
    if (_calibrationAckReceived) return;

    try {
      await repo.sendData("?");
      await repo.sendData("{");
    } catch (_) {
      // ignore -> we will retry anyway
    }

    // wait 10 sec; if no ACK, send again (repeat forever)
    _ackRetryTimer?.cancel();
    _ackRetryTimer = Timer(_ackWait, () {
      if (_disposed || !state.isBluetoothConnected) return;
      if (_calibrationAckReceived) return;
      _sendHandshakeAndWait();
    });
  }

  void _stopHandshakeLoop() {
    _handshakeLoopRunning = false;
    _ackRetryTimer?.cancel();
    _ackRetryTimer = null;
  }

  // ===================== 100s TIMER =====================

  void _startScreenTimer100s() {
    if (_disposed) return;

    _screenTimer?.cancel();
    _screenRemainingSeconds = 100;

    emit(state.copyWith(
      isTimeStarted: true,
      remainingSeconds: _screenRemainingSeconds,
      isTimeOver: false,
    ));

    _screenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed || state.navigateToInhaleScreen) {
        timer.cancel();
        return;
      }

      _screenRemainingSeconds--;

      if (_screenRemainingSeconds <= 0) {
        timer.cancel();
        emit(state.copyWith(remainingSeconds: 0, isTimeOver: true));
        return;
      }

      emit(state.copyWith(remainingSeconds: _screenRemainingSeconds));
    });
  }

  // ===================== CALIBRATION SEQUENCE (unchanged) =====================

  Future<void> _startCalibrationSequence() async {
    if (_disposed || !state.isBluetoothConnected) return;

    emit(state.copyWith(allSignalSent: false));

    for (int i = 1; i <= 5; i++) {
      if (_disposed || !state.isBluetoothConnected || state.navigateToInhaleScreen) return;

      await Future.delayed(Duration(seconds: i == 1 ? 20 : 10));

      if (_disposed || !state.isBluetoothConnected || state.navigateToInhaleScreen) return;

      if (i == 3) _audioHelper.playActivatingSensors();
      if (i == 4) _audioHelper.playStartBreathTest();

      emit(state.copyWith(completedSteps: i));

      // ✅ If you still want to send your command only at step 1:
      if (i == 1) {
        try {
          // You already entered calibration mode (ACK received),
          // so "allSignalSent" can be treated as true here.
          emit(state.copyWith(allSignalSent: true));
        } catch (_) {}
      }
    }

    emit(state.copyWith(waitForInhaleCmd: true));

    _inhaleTimeoutTimer?.cancel();
    _inhaleTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_disposed && !state.navigateToInhaleScreen) {
        emit(state.copyWith(showPleaseWaitMessage: true));
      }
    });
  }

  // ===================== UI HELPERS =====================

  void sendAbort() {
    repo.sendData("&");
  }

  void showDisconnectedDialog() {
    if (!_disposed) emit(state.copyWith(isDialogShown: true));
  }

  void dialogDismissed() {
    if (!_disposed) emit(state.copyWith(isDialogShown: false));
  }

  Future<void> disconnect() async {
    try {
      await repo.disconnect();
    } finally {
      if (!_disposed) emit(state.copyWith(isBluetoothConnected: false));
    }
  }

  // ===================== STOP/CLEANUP =====================

  void _cancelStreamsOnly() {
    _inhaleTimeoutTimer?.cancel();
    _screenTimer?.cancel();
    _stopHandshakeLoop();
    _connSub?.cancel();
    _dataSub?.cancel();
  }

  void _stopAll() {
    _audioHelper.stopAudio();

    _inhaleTimeoutTimer?.cancel();
    _screenTimer?.cancel();
    _stopHandshakeLoop();

    _calibrationAckReceived = false;
    _isRunningCalibration = false;

    emit(state.copyWith(
      completedSteps: 0,
      waitForInhaleCmd: false,
      showPleaseWaitMessage: false,
      allSignalSent: false,
      isTimeStarted: false,
      isTimeOver: false,
      remainingSeconds: 100,
      navigateToInhaleScreen: false,
    ));
  }

  void stop() {
    _cancelStreamsOnly();
    _audioHelper.stopAudio();
  }

  @override
  Future<void> close() {
    _disposed = true;
    stop();
    return super.close();
  }

  void stopScreenOperation() {
    if (_disposed) return;

    _inhaleTimeoutTimer?.cancel();
    _screenTimer?.cancel();
    _stopHandshakeLoop();
    _audioHelper.stopAudio();

    emit(state.copyWith(
      waitForInhaleCmd: false,
      showPleaseWaitMessage: false,
    ));
  }
}
