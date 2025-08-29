import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/features/device_connectivity/domain/usb_repository.dart';
import 'package:respyr_dietitian/features/device_connectivity/domain/usecase/device_check_usecase.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/usb_connection/usb_connection_state.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class UsbCubit extends Cubit<UsbState> {
  final UsbRepository repository;
  final DeviceCheckUsecase deviceCheckUsecase;
  Timer? _healthCheckTimer;

  UsbCubit(this.repository, this.deviceCheckUsecase) : super(const UsbState()) {
    _init();
  }

  void _init() {
    repository.setUsbListener(
      onConnectionStatusChanged: (status) async {
        final connected = status.toLowerCase().trim() == "connected";

        emit(
          state.copyWith(
            isConnected: connected,
            deviceId: connected ? state.deviceId : null,
          ),
        );

        if (connected) {
          repository.sendData("!");
        } else {
          _healthCheckTimer?.cancel();
          emit(
            state.copyWith(
              isConnected: false,
              deviceId: null,
              isChecking: false,
            ),
          );
        }
      },
      onDataReceived: (data) {
        if (data.startsWith("H")) {
          final cleanId = data.substring(1).trim();
          emit(state.copyWith(deviceId: cleanId));
          print("📥 Clean Device ID stored: RESPYR$cleanId");
        }
      },
      onCommandSent: (command) {
        debugPrint("Command sent to Device: $command");
      },
      onError: (error) {
        debugPrint("USB Error: $error");
      },
    );

    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final devices = await repository.listDevices();
    if (devices.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      await repository.connectToDevice(devices.first);
    } else {
      emit(state.copyWith(isConnected: false, deviceId: null));
    }
  }

  Future<void> checkAndProceed({required BuildContext context}) async {
    emit(state.copyWith(isChecking: true));

    repository.sendData("!");

    String? deviceId;
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (state.deviceId != null) {
        deviceId = state.deviceId;
        break;
      }
    }

    if (deviceId == null) {
      emit(
        state.copyWith(
          isChecking: false,
          errorMessage: "Device ID not received. Please reconnect.",
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Device ID not received. Please reconnect."),
          ),
        );
      }
      return;
    }

    final result = await deviceCheckUsecase.checkSignal(deviceId);

    // Send signal back to device like clinical app
    repository.sendData(result.signal);
    repository.sendData("%");

    emit(state.copyWith(isDeviceReady: result.isReady));

    if (result.isReady) {
      if (context.mounted) context.push(AppRoutes.breatheTubeScreen);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Device ID not received. Try Again ")),
        );
      }
    }

    if (context.mounted) {
      emit(state.copyWith(isChecking: false));
    }
  }

  @override
  Future<void> close() {
    _healthCheckTimer?.cancel();
    return super.close();
  }
}
