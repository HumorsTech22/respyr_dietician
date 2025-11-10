import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';

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
  Stream<List<BluetoothDeviceModel>> scan({Duration? timeout}) async* {
    final ctrl = StreamController<List<BluetoothDeviceModel>>();

    ctrl.onCancel = () {
      _ds.stopScan();
    };

    await _ds.startScan(
      timeout: timeout ?? const Duration(seconds: 8),
      onResults: (results) {
        final devices =
            results.map((r) {
              return BluetoothDeviceModel(
                id: r.device.remoteId.str,
                name:
                    r.device.platformName.isNotEmpty
                        ? r.device.platformName
                        : r.device.remoteId.str,
                rssi: r.rssi,
              );
            }).toList();
        ctrl.add(devices);
      },
    );

    yield* ctrl.stream;
  }

  @override
  Future<void> connectById(String id) async {
    await _ds.connectById(id);
  }

  @override
  Future<void> disconnect() async {
    await _ds.disconnect();
  }

  @override
  Future<void> sendData(String data) async {
    await _ds.write(data);
  }

  // ✅ Implementation moved here (was invalid in abstract class)
  @override
  Future<String?> getAlreadyConnectedDeviceId() async {
    final connectedDevices = await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      final device = connectedDevices.first;
      print("🔄 Already connected device found: ${device.remoteId.str}");
      return device.remoteId.str;
    }
    return null;
  }
}
