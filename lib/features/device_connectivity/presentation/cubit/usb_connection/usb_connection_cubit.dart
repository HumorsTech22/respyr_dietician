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

  Completer<String>? _deviceIdCompleter;

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
        debugPrint("📥 Raw USB data received: $data");

        if (data.startsWith("H")) {
          final cleanId = data.substring(1).trim();
          emit(state.copyWith(deviceId: cleanId));
          debugPrint("📥 Clean Device ID stored: RESPYR$cleanId");

          if (_deviceIdCompleter != null && !_deviceIdCompleter!.isCompleted) {
            _deviceIdCompleter!.complete(cleanId);
          }
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

    _deviceIdCompleter = Completer<String>();

    repository.sendData("!");

    String? deviceId;
    try {
      deviceId = await _deviceIdCompleter!.future.timeout(
        const Duration(seconds: 3),
      );
    } catch (_) {
      deviceId = null;
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
          const SnackBar(content: Text("Device ID not received. Please wait.")),
        );
      }
      return;
    }

    final result = await deviceCheckUsecase.checkSignal(deviceId);
    debugPrint(
      "🔍 checkSignal => signal=${result.signal}, isReady=${result.isReady}, deviceId=$deviceId",
    );

    // Send signal back to device like clinical app
    repository.sendData(result.signal);
    debugPrint("📤 Sent signal: ${result.signal}");
    repository.sendData("%");
    debugPrint("📤 Sent terminator: %");

    emit(state.copyWith(isDeviceReady: result.isReady));

    if (context.mounted) {
      if (result.isReady) {
        context.push(AppRoutes.breatheTubeScreen);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Device not ready. Try Again")),
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
