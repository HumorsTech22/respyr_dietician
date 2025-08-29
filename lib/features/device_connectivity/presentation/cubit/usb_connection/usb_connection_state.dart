// usb_cubit_state.dart
import 'package:equatable/equatable.dart';

class UsbState extends Equatable {
  final bool isConnected;
  final bool isChecking;
  final String? deviceId;
  final bool isDeviceReady;
  final String? errorMessage;

  const UsbState({
    this.isConnected = false,
    this.isChecking = false,
    this.isDeviceReady = false,
    this.errorMessage,
    this.deviceId,
  });

  UsbState copyWith({
    bool? isConnected,
    bool? isChecking,
    String? deviceId,
    bool? isDeviceReady,
    String? errorMessage,
  }) {
    return UsbState(
      isConnected: isConnected ?? this.isConnected,
      isChecking: isChecking ?? this.isChecking,
      deviceId: deviceId ?? this.deviceId,
      isDeviceReady: isDeviceReady ?? this.isDeviceReady,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isConnected,
    isChecking,
    deviceId,
    isDeviceReady,
    errorMessage,
  ];
}
