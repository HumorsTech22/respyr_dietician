import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class OtaUpdateState extends Equatable {
  final bool isScanning;
  final bool isConnecting;
  final bool isConnected;
  final bool isRunningOta;

  final String status;
  final String logText;
  final String receivedText;

  final String connectedDeviceName;
  final String connectedDeviceId;

  final int progressCurrent;
  final int progressTotal;

  final int elapsedSeconds;
  final double speedKbPerSec;

  final List<ScanResult> devices;

  const OtaUpdateState({
    required this.isScanning,
    required this.isConnecting,
    required this.isConnected,
    required this.isRunningOta,
    required this.status,
    required this.logText,
    required this.receivedText,
    required this.connectedDeviceName,
    required this.connectedDeviceId,
    required this.progressCurrent,
    required this.progressTotal,
    required this.elapsedSeconds,
    required this.speedKbPerSec,
    required this.devices,
  });

  factory OtaUpdateState.initial() {
    return const OtaUpdateState(
      isScanning: false,
      isConnecting: false,
      isConnected: false,
      isRunningOta: false,
      status: 'Waiting...',
      logText: '',
      receivedText: '',
      connectedDeviceName: '',
      connectedDeviceId: '',
      progressCurrent: 0,
      progressTotal: 0,
      elapsedSeconds: 0,
      speedKbPerSec: 0,
      devices: [],
    );
  }

  OtaUpdateState copyWith({
    bool? isScanning,
    bool? isConnecting,
    bool? isConnected,
    bool? isRunningOta,
    String? status,
    String? logText,
    String? receivedText,
    String? connectedDeviceName,
    String? connectedDeviceId,
    int? progressCurrent,
    int? progressTotal,
    int? elapsedSeconds,
    double? speedKbPerSec,
    List<ScanResult>? devices,
  }) {
    return OtaUpdateState(
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      isRunningOta: isRunningOta ?? this.isRunningOta,
      status: status ?? this.status,
      logText: logText ?? this.logText,
      receivedText: receivedText ?? this.receivedText,
      connectedDeviceName: connectedDeviceName ?? this.connectedDeviceName,
      connectedDeviceId: connectedDeviceId ?? this.connectedDeviceId,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      speedKbPerSec: speedKbPerSec ?? this.speedKbPerSec,
      devices: devices ?? this.devices,
    );
  }

  @override
  List<Object?> get props => [
    isScanning,
    isConnecting,
    isConnected,
    isRunningOta,
    status,
    logText,
    receivedText,
    connectedDeviceName,
    connectedDeviceId,
    progressCurrent,
    progressTotal,
    elapsedSeconds,
    speedKbPerSec,
    devices,
  ];
}