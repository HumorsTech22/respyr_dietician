import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_breathe_tube_cubit/bluetooth_breathe_tube_state.dart';

class BluetoothBreatheTubeCubit extends Cubit<BluetoothBreatheTubeState> {
  final BluetoothRepository bluetoothRepo;
  final AudioHelper audioHelper;

  StreamSubscription<bool>? _connSub;
  Timer? _progressTimer;

  BluetoothBreatheTubeCubit(this.bluetoothRepo, this.audioHelper)
    : super(const BluetoothBreatheTubeState()) {
    _init();
  }

  void _init() {
    // Listen to live connection changes
    _connSub = bluetoothRepo.connectionStatusStream().listen((connected) {
      print("📡 Bluetooth status changed: $connected"); // ADD HERE

      emit(state.copyWith(isBluetoothConnected: connected));

      if (connected) {
        _startProgress();
      } else {
        _progressTimer?.cancel();
        audioHelper.stopAudio();
        _showDisconnectedDialog();
      }
    });

    // Check current connection immediately
    final initiallyConnected = bluetoothRepo.isConnected;
    emit(state.copyWith(isBluetoothConnected: initiallyConnected));

    if (initiallyConnected) {
      _startProgress();
    }
  }

  void _startProgress() {
    const totalDuration = 5; // seconds
    const steps = totalDuration * 1000 ~/ 10; // 10ms per step
    const incrementValue = 1.0 / steps;

    audioHelper.playPlaceBreatheTube();
    print("🎬 Starting progress...");

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!state.isBluetoothConnected) {
        print("⛔ Progress stopped: not connected");

        timer.cancel();
        return;
      }

      final value = (state.progress + incrementValue).clamp(0.0, 1.0);
      print("⏱ Progress: ${(value * 100).toInt()}%");

      emit(state.copyWith(progress: value));

      if (value >= 1.0) {
        timer.cancel();
        emit(state.copyWith(isCompleted: true));
      }
    });
  }

  void _showDisconnectedDialog() {
    emit(state.copyWith(isDialogShown: true));
  }

  void cancelTest() {
    emit(state.copyWith(hasTestCancelled: true));
  }

  void handleInternetChanged(bool hasInternet) {
    emit(state.copyWith(hasInternet: hasInternet));
    if (!hasInternet) {
      _progressTimer?.cancel();
    } else if (state.progress < 1 && state.isBluetoothConnected) {
      _startProgress();
    }
  }

  Future<void> connectById(String id) async {
    await bluetoothRepo.connectById(id);
  }

  Future<void> disconnect() async {
    await bluetoothRepo.disconnect();
  }

  @override
  Future<void> close() {
    _progressTimer?.cancel();
    _connSub?.cancel();
    return super.close();
  }
}
