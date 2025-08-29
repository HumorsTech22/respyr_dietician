import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/breathe_tube/breathe_tube_state.dart';

class BreatheTubeCubit extends Cubit<BreatheTubeState> {
  final UsbCommunicationService usbService;
  final AudioHelper audioHelper;
  Timer? _progressTimer;

  BreatheTubeCubit(this.usbService, this.audioHelper)
    : super(const BreatheTubeState()) {
    _init();
  }

  void _init() async {
    // Check initial devices
    final devices = await usbService.listDevices();
    if (devices.isNotEmpty) {
      emit(state.copyWith(isConnected: true));
      startProgress();
    }

    // Listen for connection changes
    usbService.setUsbSerialListener(
      onConnectionStatusChanged: (status) {
        final connected = status.toLowerCase().trim() == "connected";
        handleUsbConnected(connected);
      },
      onError: (err) => emit(state.copyWith(error: err)),
    );
  }

  void startProgress() {
    const totalDuration = 5;
    const steps = totalDuration * 1000 ~/ 10;
    const incrementValue = 1.0 / steps;

    audioHelper.playPlaceBreatheTube();

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!state.isConnected || !state.hasInternet) {
        timer.cancel();
        return;
      }

      final value = (state.progress + incrementValue).clamp(0.0, 1.0);
      emit(state.copyWith(progress: value));

      if (value >= 1.0) {
        timer.cancel();
        emit(state.copyWith(isCompleted: true));
      }
    });
  }

  void handleUsbConnected(bool connected) {
    emit(state.copyWith(isConnected: connected));
    if (!connected) {
      _progressTimer?.cancel();
      audioHelper.stopAudio();
      showDisconnectedDialog();
    }
  }

  void handleInternetChanged(bool hasInternet) {
    emit(state.copyWith(hasInternet: hasInternet));
    if (!hasInternet) {
      _progressTimer?.cancel();
    } else if (state.progress < 1 && state.isConnected) {
      startProgress();
    }
  }

  void showDisconnectedDialog() {
    emit(state.copyWith(isDialogShown: true));
  }

  void cancelTest() {
    _progressTimer?.cancel();
    emit(state.copyWith(isTestCancelled: true));
  }

  @override
  Future<void> close() {
    _progressTimer?.cancel();
    return super.close();
  }
}
