import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';

import 'inhale_state.dart';

class InhaleCubit extends Cubit<InhaleState> {
  final UsbCommunicationService usbService;
  final AudioHelper audioHelper;
  Timer? _timer;
  StreamSubscription<String>? _usbDataSubscription;
  bool _screenActive = true;
  InhaleCubit(this.usbService, this.audioHelper) : super(const InhaleState());

  void init() async {
    if (usbService.isConnected) {
      emit(state.copyWith(isConnected: true));
      _startTimer();

      _initializeUsbConnection();
      _startInhaleVoice();
    } else {
      handleDisconnection();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isDisposed || state.navigationToExhaleScreen) {
        timer.cancel();
        return;
      }
      final newCount = state.counter - 1;
      emit(state.copyWith(counter: newCount));

      if (newCount <= 0) timer.cancel();
    });
  }

  Future<void> _startInhaleVoice() async {
    await Future.delayed(const Duration(seconds: 1));
    audioHelper.playInhaleAudio();
  }

  void _initializeUsbConnection() {
    usbService.setUsbSerialListener(
      onConnectionStatusChanged: (status) {
        final isConnected = status == "connected";
        emit(state.copyWith(isConnected: isConnected));

        if (!isConnected && !state.isDisposed) {
          Future.delayed(const Duration(milliseconds: 500)).then((_) {
            if (!state.isConnected) {
              audioHelper.stopAudio();
              _timer?.cancel();
              handleDisconnection();
            }
          });
        }
      },
      onDataReceived: _onUsbDataReceived,
      onError: (error) {
        debugPrint("USB Error: $error");
      },
    );
    _usbDataSubscription = usbService.dataStream.listen(_onUsbDataReceived);
  }

  void _onUsbDataReceived(String data) {
    if (state.isDisposed || !_screenActive) return;

    final match = RegExp(r'/[\d.]+/').firstMatch(data);
    final extractedValue = match?.group(0);

    if (extractedValue != null) {
      emit(state.copyWith(lastExtractedValue: extractedValue));
    }

    if (data.contains("blownow") &&
        !state.navigationToExhaleScreen &&
        state.lastExtractedValue != null) {
      stopAllProcesses();
      _usbDataSubscription?.cancel();

      if (!state.hasInternet) {
        debugPrint("❌ No internet — holding at inhale screen.");
        return;
      }

      emit(state.copyWith(navigationToExhaleScreen: true));
    }
  }

  void handleDisconnection() {
    if (state.dialogShown) return;
    emit(state.copyWith(dialogShown: true));
    // 👉 Here you’ll call `showDeviceDisconnectedBox` in the UI (not inside cubit).
  }

  void stopAllProcesses() {
    emit(state.copyWith(isDisposed: true));
    _usbDataSubscription?.cancel();
  }

  void toggleMute() {
    audioHelper.toggleMute();
    emit(state.copyWith(isMuted: audioHelper.isMuted));
  }

  void setInternetStatus(bool hasInternet) {
    emit(state.copyWith(hasInternet: hasInternet));
  }

  void disposeResources() {
    emit(state.copyWith(isDisposed: true));
    _timer?.cancel();
    _usbDataSubscription?.cancel();
  }
}
