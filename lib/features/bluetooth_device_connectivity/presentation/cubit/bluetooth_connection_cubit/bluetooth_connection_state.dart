import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';

enum BluetoothConnectionStatus {
  initial,
  scanning,
  connecting,
  connected,
  disconnected,
  error,
}

class BluetoothConnectionState extends Equatable {
  final BluetoothConnectionStatus status;
  final List<BluetoothDeviceModel> devices;
  final bool isScanning;
  final bool isConnected;
  final String? lastData;
  final String? error;
  final String? connectingDeviceId;

  const BluetoothConnectionState({
    this.status = BluetoothConnectionStatus.initial,
    this.devices = const [],
    this.isScanning = false,
    this.isConnected = false,
    this.lastData,
    this.error,
    this.connectingDeviceId,
  });

  BluetoothConnectionState copyWith({
    BluetoothConnectionStatus? status,
    List<BluetoothDeviceModel>? devices,
    bool? isScanning,
    bool? isConnected,
    String? lastData,
    String? error,
    String? connectingDeviceId,
  }) => BluetoothConnectionState(
    status: status ?? this.status,
    devices: devices ?? this.devices,
    isScanning: isScanning ?? this.isScanning,
    isConnected: isConnected ?? this.isConnected,
    lastData: lastData ?? this.lastData,
    error: error,
    connectingDeviceId: connectingDeviceId ?? this.connectingDeviceId,
  );

  @override
  List<Object?> get props => [
    status,
    devices,
    isScanning,
    isConnected,
    lastData,
    error,
    connectingDeviceId,
  ];
}
