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
    init();
  }

  void init() {
    _connSub = bluetoothRepo.connectionStatusStream().listen((connected) {
      print("📡 Bluetooth Breathe tube status changed: $connected");

      emit(state.copyWith(isBluetoothConnected: connected));

      if (connected) {
        if (!_isProgressRunning && state.progress < 1.0) {
          _startProgress();
        }
      } else {
        _showDisconnectedDialog();
      }
    });

    final initiallyConnected = bluetoothRepo.isConnected;
    emit(state.copyWith(isBluetoothConnected: initiallyConnected));
    if (initiallyConnected && !_isProgressRunning) {
      _startProgress();
    }
  }

  bool get _isProgressRunning => _progressTimer?.isActive ?? false;

  void _startProgress() async {
    const durationMs = 5000;
    const stepMs = 50;
    const steps = durationMs ~/ stepMs;
    const incrementValue = 1.0 / steps;

    audioHelper.playPlaceBreatheTube();

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(Duration(milliseconds: stepMs), (timer) {
      if (!state.isBluetoothConnected) {
        timer.cancel();
        audioHelper.stopAudio();
        return;
      }

      final newValue = (state.progress + incrementValue).clamp(0.0, 1.0);
      emit(state.copyWith(progress: newValue));

      if (newValue >= 1.0 && state.isBluetoothConnected) {
        timer.cancel();
        audioHelper.stopAudio();
        emit(state.copyWith(isCompleted: true));
      }
    });
  }

  void _pauseProgress() {
    _progressTimer?.cancel();
    audioHelper.stopAudio();
  }

  void _showDisconnectedDialog() {
    if (!state.isDialogShown) {
      _pauseProgress();
      emit(state.copyWith(isDialogShown: true));
    }
  }

  void cancelTest() {
    emit(state.copyWith(hasTestCancelled: true));
  }

  void handleInternetChanged(bool hasInternet) {
    emit(state.copyWith(hasInternet: hasInternet));

    if (!hasInternet) {
      _pauseProgress();
    } else if (state.progress < 1 &&
        state.isBluetoothConnected &&
        !_isProgressRunning) {
      _startProgress();
    }
  }

  Future<void> connectById(String id) async {
    await bluetoothRepo.connectById(id);
  }

  Future<void> disconnect() async {
    await bluetoothRepo.disconnect();
  }

  void dialogDismissed() {
    emit(state.copyWith(isDialogShown: false));
  }

  @override
  Future<void> close() {
    _pauseProgress();
    _connSub?.cancel();
    return super.close();
  }
}
