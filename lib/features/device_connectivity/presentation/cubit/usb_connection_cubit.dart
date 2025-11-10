// usb_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/device_connectivity/domain/usb_repository.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/usb_connection_state.dart';

class UsbCubit extends Cubit<UsbState> {
  final UsbRepository repository;

  UsbCubit(this.repository) : super(const UsbState()) {
    _init();
  }

  void _init() {
    repository.setUsbListener(
      onConnectionStatusChanged: (status) async {
        final connected = status.toLowerCase().trim() == "connected";
        emit(state.copyWith(isConnected: connected));

        if (connected) {
          await Future.delayed(const Duration(seconds: 1));
          repository.sendData("!");
        }
      },
      onDataReceived: (data) {
        if (data.startsWith("H")) {
          emit(state.copyWith(deviceId: data.substring(1).trim()));
        }
      },
      onCommandSent: (command) {
        print("Command sent: $command");
      },
      onError: (error) {
        print("USB Error: $error");
      },
    );

    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final devices = await repository.listDevices();
    if (devices.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      await repository.connectToDevice(devices.first);
    }
  }

  Future<void> checkDevice() async {
    emit(state.copyWith(isChecking: true, deviceId: null));
    repository.sendData("!");

    int attempts = 0;
    while (state.deviceId == null && attempts < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    emit(state.copyWith(isChecking: false));
  }
}
