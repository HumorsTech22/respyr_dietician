import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class UuidBluetoothManager {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _notifyChar;
  BluetoothCharacteristic? _writeChar;

  final _connCtrl = StreamController<bool>.broadcast();
  final _dataCtrl = StreamController<String>.broadcast();
  final _readyCtrl = StreamController<bool>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _notifySub;

  bool _isConnected = false;

  // UUIDs
  final Guid serviceUuid = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid notifyCharacteristicUuid = Guid(
    "49535343-1e4d-4bd9-ba61-23c647249616",
  );
  final Guid writeCharacteristicUuid = Guid(
    "6e400002-b5a3-f393-e0a9-e50e24dcca9e",
  );

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStream => _connCtrl.stream;
  Stream<String> get dataStream => _dataCtrl.stream;
  Stream<bool> get deviceReadyStream => _readyCtrl.stream;

  // ----------------- Scan -----------------
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 8),
    void Function(List<ScanResult>)? onResults,
  }) async {
    // ensure no scan running
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
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

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  // ----------------- Connect -----------------
  Future<void> connect(BluetoothDevice device, {Function? onConnected}) async {
    await stopScan();
    await _device?.disconnect();
    _device = device;

    print("🔌 Connecting to ${device.remoteId.str}...");

    // connect
    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      // connect sometimes throws; continue to listen to connectionState anyway
      if (kDebugMode) print("⚠️ connect() threw: $e");
    }

    // subscribe to connection state
    _connSub?.cancel();
    _connSub = device.connectionState.listen((s) async {
      final connected = s == BluetoothConnectionState.connected;
      _isConnected = connected;
      _connCtrl.add(connected);

      if (connected) {
        try {
          // Optional: request larger MTU (Android). ignore errors.
          try {
            await device.requestMtu(247);
            if (kDebugMode) print("✅ MTU requested");
          } catch (e) {
            if (kDebugMode) print("⚠️ MTU request failed: $e");
          }

          await _discoverAndSubscribe();

          // Only consider device ready after notify subscription established
          _readyCtrl.add(true);
          if (onConnected != null) onConnected();
        } catch (e, st) {
          if (kDebugMode) {
            print("❌ Discover/subscribe failed: $e\n$st");
          }
          // If critical failure, tear down and emit disconnected
          _teardown();
          _isConnected = false;
          _connCtrl.add(false);
        }
      } else {
        _teardown();
      }
    });
  }

  Future<void> connectById(
    String id, {
    Duration scanTimeout = const Duration(seconds: 10),
  }) async {
    final connected = await FlutterBluePlus.connectedDevices;
    final already = connected.where((d) => d.remoteId.str == id).toList();
    if (already.isNotEmpty) {
      return connect(already.first);
    }

    final found = Completer<void>();
    StreamSubscription<List<ScanResult>>? sub;

    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
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
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}
      await sub?.cancel();
    }
  }

  // ----------------- Discover & subscribe -----------------
  Future<void> _discoverAndSubscribe() async {
    if (_device == null) throw Exception('No device');

    print("🔍 Discovering services...");
    final services = await _device!.discoverServices();

    BluetoothCharacteristic? notifyChar;
    BluetoothCharacteristic? writeChar;

    for (final s in services) {
      if (s.uuid == serviceUuid) {
        if (kDebugMode) print("Service found: ${s.uuid}");
        for (final c in s.characteristics) {
          if (kDebugMode) print("  Char: ${c.uuid} props: ${c.properties}");
          if (c.uuid == notifyCharacteristicUuid) notifyChar = c;
          if (c.uuid == writeCharacteristicUuid) writeChar = c;
        }
      }
    }

    if (notifyChar == null || writeChar == null) {
      throw Exception('Required notify/write characteristics not found');
    }

    _notifyChar = notifyChar;
    _writeChar = writeChar;

    // Ensure notifications enabled and subscription established before returning "ready"
    try {
      await _notifyChar!.setNotifyValue(true);
    } catch (e) {
      // Some devices need small delay before setNotify; try again once
      await Future.delayed(const Duration(milliseconds: 250));
      await _notifyChar!.setNotifyValue(true);
    }

    await _notifySub?.cancel();
    // subscribe to incoming bytes and forward as string
    _notifySub = _notifyChar!.onValueReceived.listen((value) {
      if (value.isEmpty) return;
      final s = String.fromCharCodes(value);
      if (kDebugMode) print('📨 noti: $s');
      _dataCtrl.add(s);
    });

    // Small safety delay to allow peripheral to start notifications
    await Future.delayed(const Duration(milliseconds: 150));
    if (kDebugMode) print("✅ Notification subscription established");
  }

  Future<void> write(String data, {int maxRetries = 3}) async {
    // Guard against invalid state
    if (_device == null || !_isConnected) {
      if (kDebugMode) print("⚠️ Write skipped — no active device connection");
      return;
    }
    if (_writeChar == null) {
      if (kDebugMode) print("⚠️ Write skipped — writeChar not initialized");
      return;
    }

    final canWriteWithResponse = _writeChar!.properties.write;
    final withoutResponse = !canWriteWithResponse;
    final bytes = data.codeUnits;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (!_isConnected || _writeChar == null) {
          if (kDebugMode)
            print("⚠️ Write aborted — connection lost during retry");
          return;
        }

        if (kDebugMode) {
          print(
            "📤 Writing attempt $attempt: '$data' (withoutResponse=$withoutResponse)",
          );
        }

        await _writeChar!.write(bytes, withoutResponse: withoutResponse);
        if (kDebugMode) print("✅ Write success");
        return;
      } catch (e) {
        if (kDebugMode) print("⚠️ Write attempt $attempt failed: $e");

        // If disconnected mid-retry, stop immediately
        if (!_isConnected || _writeChar == null) {
          if (kDebugMode) print("⚠️ Stopping retry — device disconnected");
          return;
        }

        if (attempt >= maxRetries) {
          if (kDebugMode) print("❌ Write failed after $maxRetries attempts");
          return;
        }

        await Future.delayed(Duration(milliseconds: 200 * attempt));
      }
    }
  }

  // ----------------- Disconnect -----------------
  Future<void> disconnect() async {
    try {
      await _device?.disconnect();
    } catch (e) {
      if (kDebugMode) print("⚠️ disconnect threw: $e");
    } finally {
      _isConnected = false;
      _connCtrl.add(false);
      _teardown();
    }
  }

  void _teardown() {
    try {
      _notifySub?.cancel();
      _connSub?.cancel();
    } catch (_) {}

    _notifySub = null;
    _connSub = null;
    _notifyChar = null;
    _writeChar = null;
    _device = null;
    _isConnected = false;

    if (!_connCtrl.isClosed) _connCtrl.add(false);
    if (!_readyCtrl.isClosed) _readyCtrl.add(false);
  }

  void dispose() {
    _scanSub?.cancel();
    _notifySub?.cancel();
    _connSub?.cancel();
    _connCtrl.close();
    _dataCtrl.close();
    _readyCtrl.close();
  }
}
