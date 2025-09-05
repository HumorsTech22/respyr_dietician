// import 'dart:async';
// import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/bluetooth_manager.dart';
// import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';
// import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';

// class BluetoothRepositoryImpl implements BluetoothRepository {
//   final BluetoothManager _ds;

//   BluetoothRepositoryImpl(this._ds);

//   @override
//   bool get isConnected => _ds.isConnected;

//   @override
//   Stream<bool> connectionStatusStream() => _ds.connectionStream;

//   @override
//   Stream<String> receivedDataStream() => _ds.dataStream;

//   @override
//   Stream<List<BluetoothDeviceModel>> scan({
//     Duration? timeout,
//     String? filterName,
//   }) async* {
//     final ctrl = StreamController<List<BluetoothDeviceModel>>();
//     await _ds.startScan(
//       timeout: timeout ?? const Duration(seconds: 8),
//       filterName: filterName,
//       onResults: (results) {
//         final devices =
//             results
//                 .map(
//                   (r) => BluetoothDeviceModel(
//                     id: r.device.remoteId.str,
//                     name: r.device.advName,
//                     rssi: r.rssi,
//                   ),
//                 )
//                 .toList();
//         ctrl.add(devices);
//       },
//     );

//     yield* ctrl.stream;

//     // Stop scan when listener cancels
//     ctrl.onCancel = () {
//       _ds.stopScan();
//     };
//   }

//   // @override
//   // Stream<List<BluetoothDeviceModel>> scan({
//   //   Duration? timeout,
//   //   String? filterName, // you can remove this param
//   // }) async* {
//   //   final ctrl = StreamController<List<BluetoothDeviceModel>>();
//   //   await _ds.startScan(
//   //     timeout: timeout ?? const Duration(seconds: 8),
//   //     onResults: (results) {
//   //       final devices =
//   //           results
//   //               .map(
//   //                 (r) => BluetoothDeviceModel(
//   //                   id: r.device.remoteId.str,
//   //                   name: r.device.advName,
//   //                   rssi: r.rssi,
//   //                 ),
//   //               )
//   //               .toList();
//   //       ctrl.add(devices);
//   //     },
//   //   );

//   //   yield* ctrl.stream;

//   //   ctrl.onCancel = () {
//   //     _ds.stopScan();
//   //   };
//   // }

//   @override
//   Future<void> connectById(String id) => _ds.connectById(id);

//   @override
//   Future<void> disconnect() => _ds.disconnect();

//   @override
//   Future<void> sendData(String data) => _ds.write(data);
// }

import 'dart:async';
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
}
