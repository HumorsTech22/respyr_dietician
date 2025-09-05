import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class UuidBluetoothManager {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _notifyChar;
  BluetoothCharacteristic? _writeChar;

  final _connCtrl = StreamController<bool>.broadcast();
  final _dataCtrl = StreamController<String>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _notifySub;

  bool _isConnected = false;

  final Guid serviceUuid = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid notifyCharacteristicUuid = Guid(
    "49535343-1e4d-4bd9-ba61-23c647249616",
  );
  final Guid writeCharacteristicUuid = Guid(
    "6e400003-b5a3-f393-e0a9-e50e24dcca9e",
  );

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStream => _connCtrl.stream;
  Stream<String> get dataStream => _dataCtrl.stream;

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 8),
    void Function(List<ScanResult>)? onResults,
  }) async {
    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();

    await FlutterBluePlus.startScan(timeout: timeout);

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final filtered =
          results.where((r) {
            final adv = r.advertisementData;

            final matchesName = r.device.platformName.startsWith("Respyr");
            final matchesService = adv.serviceUuids.contains(
              serviceUuid.toString(),
            );

            return matchesName || matchesService;
          }).toList();

      if (filtered.isNotEmpty) {
        onResults?.call(filtered);
      }
    });
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();
  Future<void> connect(BluetoothDevice device) async {
    await stopScan();
    await _device?.disconnect();
    _device = device;

    print("🔌 Connecting to ${device.remoteId.str}...");
    await device.connect(autoConnect: false);

    _connSub?.cancel();
    _connSub = device.connectionState.listen((s) async {
      final connected = s == BluetoothConnectionState.connected;
      _isConnected = connected;
      _connCtrl.add(connected);

      print("📡 Connection state update: $connected");

      if (connected) {
        // Only discover after confirmed connection
        await _discoverAndSubscribe();
      } else {
        _teardown();
      }
    });
  }

  // 🔑 Connect by deviceId (remoteId.str). Will scan if needed.
  Future<void> connectById(
    String id, {
    Duration scanTimeout = const Duration(seconds: 10),
  }) async {
    // 1) Already connected?
    final connected = await FlutterBluePlus.connectedDevices;
    final already = connected.where((d) => d.remoteId.str == id).toList();
    if (already.isNotEmpty) {
      return connect(already.first);
    }

    // 2) Discover by scanning
    final found = Completer<void>();
    StreamSubscription<List<ScanResult>>? sub;

    await FlutterBluePlus.stopScan();
    await FlutterBluePlus.startScan(timeout: scanTimeout);

    sub = FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        if (r.device.remoteId.str == id) {
          try {
            await FlutterBluePlus.stopScan();
            await sub?.cancel();
            await connect(r.device);
            if (!found.isCompleted) found.complete();
          } catch (e) {
            if (!found.isCompleted) found.completeError(e);
          }
          return;
        }
      }
    });

    try {
      await found.future;
    } finally {
      await FlutterBluePlus.stopScan();
      await sub?.cancel();
    }
  }

  Future<void> _discoverAndSubscribe() async {
    if (_device == null) return;
    print("🔍 Discovering services...");

    final services = await _device!.discoverServices();

    BluetoothCharacteristic? notifyChar;
    BluetoothCharacteristic? writeChar;

    for (final s in services) {
      if (s.uuid == serviceUuid) {
        print("Service found: ${s.uuid}");
        for (final c in s.characteristics) {
          print("  Char: ${c.uuid}");
          if (c.uuid == notifyCharacteristicUuid) notifyChar = c;
          if (c.uuid == writeCharacteristicUuid) writeChar = c;
        }
      }
    }

    if (notifyChar == null || writeChar == null) {
      print("❌ Required notify/write characteristics NOT found");

      throw Exception('Required notify/write characteristics not found');
    }

    _notifyChar = notifyChar;
    _writeChar = writeChar;

    await _notifyChar!.setNotifyValue(true);
    await _notifySub?.cancel();
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
    final canWriteWithResponse = _writeChar!.properties.write;
    await _writeChar!.write(
      data.codeUnits,
      withoutResponse: !canWriteWithResponse,
    );
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
