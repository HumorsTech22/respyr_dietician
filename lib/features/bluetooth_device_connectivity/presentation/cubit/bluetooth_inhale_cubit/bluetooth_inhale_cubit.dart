import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_inhale_cubit/bluetooth_inhale_state.dart';

class BluetoothInhaleCubit extends Cubit<BluetoothInhaleState> {
  final BluetoothRepository repo;
  final AudioHelper audioHelper;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;
  Timer? _timer;
  bool _isDispose = false;

  BluetoothInhaleCubit(this.repo, this.audioHelper)
    : super(const BluetoothInhaleState()) {
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
    if (_isDispose) return;

    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected) {
      print("✅ Bluetooth Connected");

      // counter started
      _startTimer();
    } else {
      print("❌ Bluetooth Disconnected");
      _timer?.cancel();
      audioHelper.stopAudio();
      if (!state.isDialogShown) {
        showDisconnectedDialog();
      }
    }
  }

  void showDisconnectedDialog() {
    emit(state.copyWith(isDialogShown: true));
  }

  void dialogDismissed() {
    emit(state.copyWith(isDialogShown: false));
  }

  void onBluetoothDataReceived(String data) {
    if (data.isEmpty || _isDispose) return;

    final normalized = data.trim().toLowerCase();
    print("📨 Received Bluetooth Data: '$data' (normalized: '$normalized')");

    final match = RegExp(r'/[\d.]+/').firstMatch(data);
    final extractedValue = match?.group(0);

    if (extractedValue != null) {
      emit(state.copyWith(lastExtractedValue: extractedValue));
      print("ExtractedValue = $extractedValue");
    }

    if (normalized.contains("blownow") &&
        !state.navigateToExhaleScreen &&
        state.lastExtractedValue != null) {
      stop();
      print(
        "➡️ 'blownow' detected → Navigating to Exhale screen with value: ${state.lastExtractedValue}",
      );
      emit(state.copyWith(navigateToExhaleScreen: true));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDispose || state.navigateToExhaleScreen) {
        timer.cancel();
        return;
      }

      final newCount = state.counter - 1;
      print("Counter: $newCount");

      emit(state.copyWith(counter: newCount));
      if (newCount <= 0) {
        timer.cancel();
      }
    });
  }

  void stop() {
    _isDispose = true;
    _connSub?.cancel();
    _dataSub?.cancel();
    _timer?.cancel();
    _connSub = null;
    _dataSub = null;
    audioHelper.stopAudio();
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
