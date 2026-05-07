import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';

class BleTerminalState {
  final List<BluetoothDeviceModel> devices;
  final List<String> logs;
  final bool scanning;
  final bool connected;
  final String? connectedId;

  const BleTerminalState({
    this.devices = const [],
    this.logs = const [],
    this.scanning = false,
    this.connected = false,
    this.connectedId,
  });

  BleTerminalState copyWith({
    List<BluetoothDeviceModel>? devices,
    List<String>? logs,
    bool? scanning,
    bool? connected,
    String? connectedId,
  }) {
    return BleTerminalState(
      devices: devices ?? this.devices,
      logs: logs ?? this.logs,
      scanning: scanning ?? this.scanning,
      connected: connected ?? this.connected,
      connectedId: connectedId ?? this.connectedId,
    );
  }
}

class BleTerminalCubit extends Cubit<BleTerminalState> {
  final BluetoothRepository repo;

  StreamSubscription? _scanSub;
  StreamSubscription? _dataSub;
  StreamSubscription? _connSub;

  BleTerminalCubit(this.repo) : super(const BleTerminalState());

  void init() {
    /// RX listener
    _dataSub = repo.receivedDataStream().listen((data) {
      final logs = List<String>.from(state.logs)..add("RX: $data");
      emit(state.copyWith(logs: logs));
    });

    /// Connection listener
    _connSub = repo.connectionStatusStream().listen((connected) {
      final logs = List<String>.from(state.logs);
      logs.add(connected ? "STATUS: CONNECTED" : "STATUS: DISCONNECTED");

      emit(state.copyWith(
        connected: connected,
        logs: logs,
        connectedId: connected ? state.connectedId : null,
      ));
    });
  }

  /// Scan
  void scan() {
    emit(state.copyWith(scanning: true, devices: []));

    _scanSub?.cancel();
    _scanSub = repo.scan().listen((devices) {
      emit(state.copyWith(
        devices: devices,
        scanning: true,
      ));
    });
  }

  /// Connect
  Future<void> connect(BluetoothDeviceModel device) async {
    final logs = List<String>.from(state.logs)..add("CONNECT → ${device.name}");
    emit(state.copyWith(logs: logs, connectedId: device.id));

    await repo.connectById(device.id);
  }

  /// Disconnect
  Future<void> disconnect() async {
    await repo.disconnect();
  }

  /// Send
  Future<void> send(String text) async {
    if (text.isEmpty) return;

    await repo.sendData(text);

    final logs = List<String>.from(state.logs)..add("TX: $text");
    emit(state.copyWith(logs: logs));
  }

  void clearLogs() {
    emit(state.copyWith(logs: []));
  }

  @override
  Future<void> close() {
    _scanSub?.cancel();
    _dataSub?.cancel();
    _connSub?.cancel();
    return super.close();
  }
}