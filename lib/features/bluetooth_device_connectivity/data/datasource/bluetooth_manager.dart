import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _notifyChar;
  BluetoothCharacteristic? _writeChar;

  final _connCtrl = StreamController<bool>.broadcast();
  final _dataCtrl = StreamController<String>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _notifySub;

  bool _isConnected = false;

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStream => _connCtrl.stream;
  Stream<String> get dataStream => _dataCtrl.stream;

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 8),
    String? filterName,
    void Function(List<ScanResult>)? onResults,
  }) async {
    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();

    await FlutterBluePlus.startScan(timeout: timeout);

    _scanSub = FlutterBluePlus.scanResults.listen((result) {
      final filtered =
          result.where((r) {
            if (filterName == null) return true;
            final name = r.device.advName;
            return name.startsWith(filterName);
          }).toList();

      onResults?.call(filtered);
    });

    // _scanSub = FlutterBluePlus.scanResults.listen((result) {
    //   final devices = result.toList(); // no filter applied
    //   onResults?.call(devices);
    // });
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  Future<void> connectById(String id) async {
    await stopScan();

    final device = BluetoothDevice.fromId(id);
    await connect(device);
  }

  Future<void> connect(BluetoothDevice device) async {
    _device?.disconnect();
    _device = device;

    await device.connect(autoConnect: false);
    _isConnected = true;
    _connCtrl.add(true);

    _connSub?.cancel();
    _connSub = device.connectionState.listen((s) async {
      if (s == BluetoothConnectionState.disconnected) {
        _isConnected = false;
        _connCtrl.add(false);
        _teardown();
      }
    });
    await _discoverAndSubscribe();
  }

  Future<void> _discoverAndSubscribe() async {
    if (_device == null) return;

    final services = await _device!.discoverServices();

    BluetoothCharacteristic? notifyChar;
    BluetoothCharacteristic? writeChar;

    for (final s in services) {
      for (final c in s.characteristics) {
        if (c.properties.notify && notifyChar == null) notifyChar = c;
        if ((c.properties.write || c.properties.writeWithoutResponse) &&
            writeChar == null) {
          writeChar = c;
        }
      }
    }

    if (notifyChar == null || writeChar == null) {
      throw Exception('BLE characteristics not found (notify/write)');
    }

    _notifyChar = notifyChar;
    _writeChar = writeChar;

    await _notifyChar!.setNotifyValue(true);
    _notifySub?.cancel();
    _notifySub = _notifyChar!.onValueReceived.listen((value) {
      if (value.isEmpty) return;
      final s = String.fromCharCodes(value);
      if (kDebugMode) print('📨 $s');
      _dataCtrl.add(s);
    });
  }

  Future<void> write(String data) async {
    if (_writeChar == null || !_isConnected) {
      throw Exception('Device not ready for write');
    }
    final supportsWrite = _writeChar!.properties.write;
    await _writeChar!.write(data.codeUnits, withoutResponse: !supportsWrite);
  }

  Future<void> disconnect() async {
    try {
      await _device?.disconnect();
    } finally {
      _isConnected = false;
      _connCtrl.add(false);
      _teardown();
    }
  }

  void _teardown() {
    _notifySub?.cancel();
    _notifySub = null;
    _connSub?.cancel();
    _connSub = null;
    _notifyChar = null;
    _writeChar = null;
    _device = null;
  }

  void dispose() {
    _scanSub?.cancel();
    _notifySub?.cancel();
    _connSub?.cancel();
    _connCtrl.close();
    _dataCtrl.close();
  }
}
