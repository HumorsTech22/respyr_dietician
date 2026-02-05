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
  Timer? _screenTimer;
  Timer? _ackTimer;

  int _screenRemainingSeconds = 100;

  bool signalsAlreadySent = false;
  bool _isRunningCalibration = false;
  bool _disposed = false;

  bool _waitingForAck = false;
  bool _ackReceived = false;
  int _ackRetryCount = 0;
  static const int _maxAckRetries = 1;

  BluetoothCalibrationCubit(this.repo, this._audioHelper)
      : super(const BluetoothCalibrationState()) {
    init();
  }

  void init() {
    _connSub = repo.connectionStatusStream().listen(handleBluetoothConnection);
    _dataSub = repo.receivedDataStream().listen(onBluetoothDataReceived);
    _startScreenTimer100s();

    if (repo.isConnected) {
      handleBluetoothConnection(true);
    }
  }

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

  Future<void> handleBluetoothConnection(bool connected) async {
    if (_disposed) return;

    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected) {
      if (state.isTimeOver) _startScreenTimer100s();

      if (!_isRunningCalibration) {
        _isRunningCalibration = true;
        await Future.delayed(const Duration(seconds: 1));
        _startCalibrationSequence();
      }
    } else {
      _audioHelper.stopAudio();
      _inhaleTimeoutTimer?.cancel();
      _screenTimer?.cancel();
      _ackTimer?.cancel();

      _waitingForAck = false;
      _ackReceived = false;
      _ackRetryCount = 0;

      signalsAlreadySent = false;
      _isRunningCalibration = false;

      emit(state.copyWith(
        completedSteps: 0,
        waitForInhaleCmd: false,
        showPleaseWaitMessage: false,
        allSignalSent: false,
      ));

      if (!state.isDialogShown) showDisconnectedDialog();
    }
  }

  void onBluetoothDataReceived(String data) {
    if (_disposed || data.isEmpty) return;

    final normalized = data.trim().toLowerCase();

    if (_waitingForAck && !_ackReceived && normalized == "{") {
      _ackReceived = true;
      _stopAckWait();
    }

    if (normalized.contains("inhale") && !state.navigateToInhaleScreen) {
      _inhaleTimeoutTimer?.cancel();
      _screenTimer?.cancel();
      _ackTimer?.cancel();
      _audioHelper.stopAudio();

      emit(state.copyWith(
        navigateToInhaleScreen: true,
        waitForInhaleCmd: false,
        showPleaseWaitMessage: false,
      ));

      _cancelStreamsOnly();
    }
  }

  void _startAckWaitTimer() {
    _ackTimer?.cancel();
    _waitingForAck = true;
    _ackReceived = false;

    _ackTimer = Timer(const Duration(seconds: 5), () {
      if (_disposed || _ackReceived) return;

      if (_ackRetryCount < _maxAckRetries) {
        _ackRetryCount++;
        _sendHandshakeAgain();
      } else {
        _restartCalibrationFromStart();
      }
    });
  }

  Future<void> _sendHandshakeAgain() async {
    if (_disposed || !state.isBluetoothConnected) return;

    try {
      await repo.sendData("?");
      await repo.sendData("{");
      _startAckWaitTimer();
    } catch (_) {
      _restartCalibrationFromStart();
    }
  }

  void _stopAckWait() {
    _ackTimer?.cancel();
    _waitingForAck = false;
  }

  void _restartCalibrationFromStart() {
    if (_disposed) return;

    _ackTimer?.cancel();
    _inhaleTimeoutTimer?.cancel();
    _audioHelper.stopAudio();

    signalsAlreadySent = false;
    _isRunningCalibration = false;

    _waitingForAck = false;
    _ackReceived = false;
    _ackRetryCount = 0;

    emit(state.copyWith(
      completedSteps: 0,
      waitForInhaleCmd: false,
      showPleaseWaitMessage: false,
      allSignalSent: false,
      navigateToInhaleScreen: false,
    ));

    if (state.isBluetoothConnected) {
      _isRunningCalibration = true;
      _startCalibrationSequence();
    }
  }

  Future<void> sendCalibrationCommand(int step) async {
    if (_disposed || !state.isBluetoothConnected) return;

    if (step == 1 && !signalsAlreadySent) {
      try {
        await repo.sendData("?");
        await repo.sendData("{");

        signalsAlreadySent = true;
        emit(state.copyWith(allSignalSent: true));

        _ackRetryCount = 0;
        _startAckWaitTimer();
      } catch (_) {
        _restartCalibrationFromStart();
      }
    }
  }

  void sendAbort() {
    repo.sendData("&");
  }

  Future<void> _startCalibrationSequence() async {
    if (_disposed || !state.isBluetoothConnected) return;

    signalsAlreadySent = false;
    emit(state.copyWith(allSignalSent: false));

    _ackTimer?.cancel();
    _waitingForAck = false;
    _ackReceived = false;
    _ackRetryCount = 0;

    for (int i = 1; i <= 5; i++) {
      if (_disposed || !state.isBluetoothConnected || state.navigateToInhaleScreen) return;

      await Future.delayed(Duration(seconds: i == 1 ? 20 : 10));

      if (_disposed || !state.isBluetoothConnected || state.navigateToInhaleScreen) return;

      if (i == 3) _audioHelper.playActivatingSensors();
      if (i == 4) _audioHelper.playStartBreathTest();

      emit(state.copyWith(completedSteps: i));
      await sendCalibrationCommand(i);
    }

    emit(state.copyWith(waitForInhaleCmd: true));

    _inhaleTimeoutTimer?.cancel();
    _inhaleTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_disposed && !state.navigateToInhaleScreen) {
        emit(state.copyWith(showPleaseWaitMessage: true));
      }
    });
  }

  void showDisconnectedDialog() {
    if (_disposed) emit(state.copyWith(isDialogShown: true));
  }

  void dialogDismissed() {
    if (_disposed) emit(state.copyWith(isDialogShown: false));
  }

  Future<void> disconnect() async {
    try {
      await repo.disconnect();
    } finally {
      if (!_disposed) emit(state.copyWith(isBluetoothConnected: false));
    }
  }

  void _cancelStreamsOnly() {
    _inhaleTimeoutTimer?.cancel();
    _screenTimer?.cancel();
    _ackTimer?.cancel();
    _connSub?.cancel();
    _dataSub?.cancel();
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
    _ackTimer?.cancel();
    _audioHelper.stopAudio();

    emit(state.copyWith(
      waitForInhaleCmd: false,
      showPleaseWaitMessage: false,
    ));
  }
}
