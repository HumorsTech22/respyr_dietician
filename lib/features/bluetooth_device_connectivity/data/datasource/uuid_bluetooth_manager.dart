import 'dart:async';
import 'dart:io';
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
  StreamSubscription<BluetoothAdapterState>? _adapterStateSub;

  bool _isConnected = false;

  final Guid serviceUuid = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid readCharacteristicUuid =
  Guid("49535343-1e4d-4bd9-ba61-23c647249616");
  final Guid writeCharacteristicUuid =
  Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStream => _connCtrl.stream;
  Stream<String> get dataStream => _dataCtrl.stream;
  Stream<bool> get deviceReadyStream => _readyCtrl.stream;

  UuidBluetoothManager() {
    _adapterStateSub = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off ||
          state == BluetoothAdapterState.turningOff) {
        _handleBluetoothOff();
      }
    });
  }

  void _log(String msg) {
    if (kDebugMode) {
      // ignore: avoid_print
      print("🟩 BLE_MGR | $msg");
    }
  }

  void _handleBluetoothOff() {
    _log("Bluetooth OFF -> teardown");
    _isConnected = false;
    if (!_connCtrl.isClosed) _connCtrl.add(false);
    if (!_readyCtrl.isClosed) _readyCtrl.add(false);
    _teardown();
  }

  // ===================== SCAN (Continuous) =====================

  /// Continuous scanning: runs until you call stopScan().
  Future<void> startScan({
    void Function(List<ScanResult>)? onResults,
  }) async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _log("startScan blocked: adapterState=$adapterState");
      return;
    }

    await stopScan(); // ensure single scan session

    _log("startScan() continuous...");
    await FlutterBluePlus.startScan(); // ✅ no timeout

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final filtered = results.where((r) {
        final name = r.device.platformName;
        final matchesName = name.contains("Respyr");
        final matchesService =
        r.advertisementData.serviceUuids.contains(serviceUuid.toString());
        return matchesName || matchesService;
      }).toList();

      // ✅ Always emit (even empty) so UI stays synced
      onResults?.call(filtered);
    }, onError: (e) {
      _log("scanResults error: $e");
    });
  }

  /// Stops scanning only when you explicitly call it.
  Future<void> stopScan() async {
    _log("stopScan()");
    try {
      await _scanSub?.cancel();
    } catch (_) {}
    _scanSub = null;

    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  // ===================== CONNECT =====================

  /// Connect to a device by id. If not currently visible, it will keep scanning
  /// until it appears (no timeout).
  Future<void> connectById(String id) async {
    _log("connectById($id)");

    // if already connected by OS
    final connected = await FlutterBluePlus.connectedDevices;
    final already = connected.where((d) => d.remoteId.str == id).toList();
    if (already.isNotEmpty) {
      _log("already connected by OS -> connect(existing device)");
      return connect(already.first);
    }

    // Keep scanning until found
    final found = Completer<void>();
    StreamSubscription<List<ScanResult>>? sub;

    await stopScan();
    await FlutterBluePlus.startScan(); // ✅ continuous

    sub = FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        if (r.device.remoteId.str == id) {
          _log("target found in scan -> stopScan + connect()");
          try {
            await FlutterBluePlus.stopScan();
            await sub?.cancel();
            await connect(r.device); // ✅ waits until really connected
            if (!found.isCompleted) found.complete();
          } catch (e) {
            if (!found.isCompleted) found.completeError(e);
          }
          return;
        }
      }
    });

    try {
      await found.future; // ✅ no timeout restriction
    } finally {
      await sub?.cancel();
      await stopScan();
    }
  }

  /// Stable connect: returns only when connected + services discovered + notify enabled.
  Future<void> connect(
      BluetoothDevice device, {
        Duration readyTimeout = const Duration(seconds: 12),
      }) async {
    _log("connect(${device.remoteId.str})");

    if (_device != null && _device!.remoteId != device.remoteId) {
      try {
        _log("disconnect previous device...");
        await _device?.disconnect();
      } catch (_) {}
    }

    _device = device;
    _teardownInternalFields();

    final connectedCompleter = Completer<void>();

    await _connSub?.cancel();
    _connSub = device.connectionState.listen((s) async {
      final connected = s == BluetoothConnectionState.connected;
      _log("device.connectionState => $s");

      _isConnected = connected;
      if (!_connCtrl.isClosed) _connCtrl.add(connected);

      if (connected) {
        try {
          if (Platform.isAndroid) {
            await device.requestMtu(247);
          }

          await _discoverAndSubscribe();
          if (!_readyCtrl.isClosed) _readyCtrl.add(true);

          if (!connectedCompleter.isCompleted) {
            connectedCompleter.complete();
          }
        } catch (e) {
          _log("discover/subscribe failed: $e");
          if (!connectedCompleter.isCompleted) {
            connectedCompleter.completeError(e);
          }
          _teardown();
        }
      } else {
        // ✅ Ignore transient disconnected while still connecting
        if (!connectedCompleter.isCompleted) return;
        _teardown();
      }
    });

    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      // iOS might throw "already connected"
      final msg = e.toString().toLowerCase();
      if (!msg.contains("already connected")) rethrow;
    }

    // ✅ Wait until really connected + ready
    await connectedCompleter.future.timeout(readyTimeout, onTimeout: () {
      throw TimeoutException("BLE connect timeout");
    });
  }

  Future<void> disconnect() async {
    _log("disconnect()");
    try {
      await _device?.disconnect();
    } catch (e) {
      if (kDebugMode) print("⚠️ disconnect() threw: $e");
    } finally {
      _teardown();
    }
  }

  // ===================== DISCOVER + NOTIFY =====================

  Future<void> _discoverAndSubscribe() async {
    if (_device == null) throw Exception('No device');
    await Future.delayed(const Duration(milliseconds: 400));

    final services = await _device!.discoverServices();
    BluetoothCharacteristic? nChar;
    BluetoothCharacteristic? wChar;

    for (final s in services) {
      if (s.uuid == serviceUuid) {
        for (final c in s.characteristics) {
          if (c.uuid == readCharacteristicUuid ||
              (c.properties.notify && nChar == null)) {
            nChar = c;
          }
          if (c.uuid == writeCharacteristicUuid ||
              ((c.properties.write || c.properties.writeWithoutResponse) &&
                  wChar == null)) {
            wChar = c;
          }
        }
      }
    }

    if (nChar == null || wChar == null) {
      throw Exception('Chars not found');
    }

    _notifyChar = nChar;
    _writeChar = wChar;

    await _notifyChar!.setNotifyValue(true);
    await _notifySub?.cancel();
    _notifySub = _notifyChar!.onValueReceived.listen((value) {
      if (value.isNotEmpty && !_dataCtrl.isClosed) {
        _dataCtrl.add(String.fromCharCodes(value));
      }
    });
  }

  Future<void> write(String data, {int maxRetries = 3}) async {
    if (_device == null || !_isConnected || _writeChar == null) return;

    final bytes = data.codeUnits;
    final withoutResponse =
        _writeChar!.properties.writeWithoutResponse && !_writeChar!.properties.write;

    for (int i = 1; i <= maxRetries; i++) {
      try {
        await _writeChar!.write(bytes, withoutResponse: withoutResponse);
        return;
      } catch (e) {
        if (i == maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 120 * i));
      }
    }
  }

  // ===================== TEARDOWN =====================

  void _teardownInternalFields() {
    _notifyChar = null;
    _writeChar = null;
    _notifySub?.cancel();
    _notifySub = null;
  }

  void _teardown() {
    _teardownInternalFields();
    _connSub?.cancel();
    _connSub = null;
    _isConnected = false;

    if (!_readyCtrl.isClosed) _readyCtrl.add(false);
    if (!_connCtrl.isClosed) _connCtrl.add(false);
  }

  void dispose() {
    _log("dispose()");
    _adapterStateSub?.cancel();
    stopScan();
    _teardown();

    if (!_connCtrl.isClosed) _connCtrl.close();
    if (!_dataCtrl.isClosed) _dataCtrl.close();
    if (!_readyCtrl.isClosed) _readyCtrl.close();
  }
}
