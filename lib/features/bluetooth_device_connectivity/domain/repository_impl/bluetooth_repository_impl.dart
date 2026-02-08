import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';

class BluetoothRepositoryImpl implements BluetoothRepository {
  final UuidBluetoothManager _ds;

  BluetoothRepositoryImpl(this._ds);

  @override
  bool get isConnected => _ds.isConnected;

  @override
  Stream<bool> connectionStatusStream() => _ds.connectionStream;

  @override
  Stream<String> receivedDataStream() => _ds.dataStream;

  @override
  Stream<bool> deviceReadyStream() => _ds.deviceReadyStream;

  @override
  Future<void> stopScan() => _ds.stopScan();

  @override
  Stream<List<BluetoothDeviceModel>> scan({Duration? timeout}) {
    // timeout is ignored intentionally because scan is continuous.
    final ctrl = StreamController<List<BluetoothDeviceModel>>.broadcast();
    bool started = false;

    Future<void> start() async {
      if (started) return;
      started = true;

      try {
        await _ds.startScan(
          onResults: (results) {
            final devices = results.map((r) {
              final name = r.device.platformName;
              return BluetoothDeviceModel(
                id: r.device.remoteId.str,
                name: name.isNotEmpty ? name : r.device.remoteId.str,
                rssi: r.rssi,
              );
            }).toList();

            if (!ctrl.isClosed) ctrl.add(devices);
          },
        );
      } catch (e) {
        if (!ctrl.isClosed) ctrl.addError(e);
      }
    }

    start();

    ctrl.onCancel = () async {
      try {
        await _ds.stopScan();
      } catch (_) {}
      if (!ctrl.isClosed) await ctrl.close();
    };

    return ctrl.stream;
  }

  @override
  Future<void> connectById(String id) async {
    // stop scan before connecting
    try {
      await _ds.stopScan();
    } catch (_) {}
    await _ds.connectById(id);
  }

  @override
  Future<void> disconnect() => _ds.disconnect();

  @override
  Future<void> sendData(String data) => _ds.write(data);

  @override
  Future<String?> getAlreadyConnectedDeviceId() async {
    final connectedDevices = await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      return connectedDevices.first.remoteId.str;
    }
    return null;
  }
}
