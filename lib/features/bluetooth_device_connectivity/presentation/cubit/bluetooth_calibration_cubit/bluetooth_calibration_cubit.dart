import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothCalibrationCubit extends Cubit<BluetoothCalibrationState> {
  final BluetoothRepository repo;
  final AudioHelper _audioHelper;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;
  Timer? _inhaleTimeoutTimer;

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
    if (repo.isConnected) {
      handleBluetoothConnection(true);
    }
  }

  Future<void> handleBluetoothConnection(bool connected) async {
    if (_disposed) return;
    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected) {
      print("✅ Bluetooth Connected");
      if (!_isRunningCalibration) {
        _isRunningCalibration = true;
        await Future.delayed(const Duration(seconds: 1));
        _startCalibrationSequence();
      }
    } else {
      print("❌ Bluetooth Disconnected");
      _audioHelper.stopAudio();
      if (!state.isDialogShown) {
        showDisconnectedDialog();
      }
    }
  }

  void onBluetoothDataReceived(String data) {
    if (data.isEmpty || _disposed) return;

    final normalized = data.trim().toLowerCase();
    print("📨 Received Bluetooth Data: '$normalized'");

    if (normalized.contains("inhale") && !state.navigateToInhaleScreen) {
      print("➡️ Inhale detected → Navigating to inhale screen");
      _inhaleTimeoutTimer?.cancel(); // ✅ Stop waiting timer
      stop();
      emit(
        state.copyWith(
          navigateToInhaleScreen: true,
          waitForInhaleCmd: false,
          showPleaseWaitMessage: false,
        ),
      );
    }
  }

  Future<void> sendCalibrationCommand(int step) async {
    try {
      if (step == 1 && !signalsAlreadySent) {
        final prefs = await SharedPreferences.getInstance();
        final signal = prefs.getString("isFirstReading") ?? "{";

        print("➡️ Sending calibration commands to device...");

        await repo.sendData("?");
        await repo.sendData("}");
        await repo.sendData(signal);
        await repo.sendData("+");

        signalsAlreadySent = true;
        print("✅ Calibration commands sent successfully");
      }
    } catch (e) {
      print("❌ Failed to send calibration commands: $e");
      emit(
        state.copyWith(textError: "Failed to send data to Bluetooth device"),
      );
    }
  }

  void sendAbort() {
    repo.sendData("&");
  }

  Future<void> setCancelOrDisconnectFlag({bool isCancel = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final DateTime now = DateTime.now();
    final Duration offset = const Duration(minutes: 1);
    final DateTime futureTime = now.add(offset);
    await prefs.setString(
      'cancel_or_disconnect_time',
      futureTime.toIso8601String(),
    );
  }

  Future<void> _startCalibrationSequence() async {
    if (!_isRunningCalibration || _disposed) return;

    signalsAlreadySent = false;

    for (int i = 1; i <= 5; i++) {
      if (_disposed ||
          !state.isBluetoothConnected ||
          state.navigateToInhaleScreen)
        return;

      await Future.delayed(Duration(seconds: i == 1 ? 20 : 10));

      if (i == 3) _audioHelper.playActivatingSensors();
      if (i == 4) _audioHelper.playStartBreathTest();

      if (_disposed) return;
      emit(state.copyWith(completedSteps: i));
      print("✅ Calibration step $i completed");

      await sendCalibrationCommand(i);
    }

    // ✅ Done with calibration
    emit(state.copyWith(waitForInhaleCmd: true));
    print("🚦 Calibration sequence done, waiting for inhale...");

    _inhaleTimeoutTimer?.cancel();
    _inhaleTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_disposed && !state.navigateToInhaleScreen) {
        print("⏳ No inhale detected within 30s — showing please wait...");
        emit(state.copyWith(showPleaseWaitMessage: true));
      }
    });
  }

  void showDisconnectedDialog() {
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
      emit(state.copyWith(isBluetoothConnected: false));
    }
  }

  void stop() {
    _disposed = true;
    _inhaleTimeoutTimer?.cancel();
    _connSub?.cancel();
    _dataSub?.cancel();
    _audioHelper.stopAudio();
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
