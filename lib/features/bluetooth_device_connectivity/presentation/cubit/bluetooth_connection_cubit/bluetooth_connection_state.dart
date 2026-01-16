import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';

enum BluetoothConnectionStatus {
  initial,
  scanning,
  connecting,
  connected,
  disconnected,
  textError,
}

class BluetoothConnectionState extends Equatable {
  final BluetoothConnectionStatus status;
  final List<BluetoothDeviceModel> devices;
  final bool isScanning;
  final bool isConnected;
  final String? lastData;
  final String? textError;
  final String? connectingDeviceId;
  final double? batteryPercentage;

  // ✅ NEW: device error info for UI (optional)
  final String? deviceErrorMessage;

  const BluetoothConnectionState({
    this.status = BluetoothConnectionStatus.initial,
    this.devices = const [],
    this.isScanning = false,
    this.isConnected = false,
    this.lastData,
    this.textError,
    this.connectingDeviceId,
    this.batteryPercentage,
    this.deviceErrorMessage,
  });

  BluetoothConnectionState copyWith({
    BluetoothConnectionStatus? status,
    List<BluetoothDeviceModel>? devices,
    bool? isScanning,
    bool? isConnected,
    String? lastData,
    String? textError,
    String? connectingDeviceId,
    double? batteryPercentage,
    String? deviceErrorMessage,
  }) {
    return BluetoothConnectionState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      isConnected: isConnected ?? this.isConnected,
      lastData: lastData ?? this.lastData,
      textError: textError ?? this.textError,
      connectingDeviceId: connectingDeviceId ?? this.connectingDeviceId,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      deviceErrorMessage: deviceErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    devices,
    isScanning,
    isConnected,
    lastData,
    textError,
    connectingDeviceId,
    batteryPercentage,
    deviceErrorMessage,
  ];
}
