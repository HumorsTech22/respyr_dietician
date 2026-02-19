import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class UuidBluetoothManager {
  static final UuidBluetoothManager _instance = UuidBluetoothManager._internal();
  factory UuidBluetoothManager() => _instance;

  UuidBluetoothManager._internal() {
    _adapterStateSub = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off ||
          state == BluetoothAdapterState.turningOff) {
        if (kDebugMode) {
          // ignore: avoid_print
          print("⚠️ Bluetooth turned OFF — performing teardown");
        }
        _handleBluetoothOff();
      } else if (state == BluetoothAdapterState.on) {
        if (kDebugMode) {
          // ignore: avoid_print
          print("✅ Bluetooth adapter is ON");
        }
      }
    });
  }

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
  final Guid notifyCharacteristicUuid =
  Guid("49535343-1e4d-4bd9-ba61-23c647249616");
  final Guid writeCharacteristicUuid =
  Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStream => _connCtrl.stream;
  Stream<String> get dataStream => _dataCtrl.stream;
  Stream<bool> get deviceReadyStream => _readyCtrl.stream;

  void _handleBluetoothOff() {
    _isConnected = false;
    if (!_connCtrl.isClosed) _connCtrl.add(false);
    if (!_readyCtrl.isClosed) _readyCtrl.add(false);
    _teardown();
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 8),
    void Function(List<ScanResult>)? onResults,
  }) async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("⚠️ Cannot start scan — Bluetooth is off");
      }
      return;
    }

    await stopScan();

    await FlutterBluePlus.startScan(timeout: timeout);

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final filtered = results.where((r) {
        final adv = r.advertisementData;
        final matchesName = r.device.platformName.contains("Respyr");
        final matchesService = adv.serviceUuids.contains(serviceUuid.toString());
        return matchesName || matchesService;
      }).toList();

      if (filtered.isNotEmpty) {
        onResults?.call(filtered);
      }
    }, onError: (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("scanResults error: $e");
      }
    });
  }

  Future<void> stopScan() async {
    try {
      await _scanSub?.cancel();
    } catch (_) {}
    _scanSub = null;

    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  Future<void> connect(BluetoothDevice device, {Function? onConnected}) async {
    await stopScan();

    if (_device != null && _device!.remoteId != device.remoteId) {
      try {
        await _device?.disconnect();
      } catch (_) {}
    }

    _device = device;

    if (kDebugMode) {
      // ignore: avoid_print
      print("🔌 Connecting to ${device.remoteId.str}...");
    }

    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (!msg.contains("already connected")) {
        if (kDebugMode) {
          // ignore: avoid_print
          print("⚠️ connect() threw: $e");
        }
      }
    }

    await _connSub?.cancel();
    _connSub = device.connectionState.listen((s) async {
      final connected = s == BluetoothConnectionState.connected;
      _isConnected = connected;
      if (!_connCtrl.isClosed) _connCtrl.add(connected);

      if (connected) {
        try {
          if (Platform.isAndroid) {
            try {
              await device.requestMtu(247);
              if (kDebugMode) {
                // ignore: avoid_print
                print("✅ MTU requested");
              }
            } catch (e) {
              if (kDebugMode) {
                // ignore: avoid_print
                print("⚠️ MTU request failed: $e");
              }
            }
          }

          await _discoverAndSubscribe();

          if (!_readyCtrl.isClosed) _readyCtrl.add(true);
          if (onConnected != null) onConnected();
        } catch (e, st) {
          if (kDebugMode) {
            // ignore: avoid_print
            print("❌ Discover/subscribe failed: $e\n$st");
          }
          _teardown();
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

    await stopScan();
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
      await stopScan();
    }
  }

  Future<void> _discoverAndSubscribe() async {
    if (_device == null) throw Exception('No device');

    if (kDebugMode) {
      // ignore: avoid_print
      print("🔍 Discovering services...");
    }

    await Future.delayed(const Duration(milliseconds: 250));
    final services = await _device!.discoverServices();

    BluetoothCharacteristic? notifyChar;
    BluetoothCharacteristic? writeChar;

    for (final s in services) {
      if (s.uuid == serviceUuid) {
        for (final c in s.characteristics) {
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

    try {
      await _notifyChar!.setNotifyValue(true);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 250));
      await _notifyChar!.setNotifyValue(true);
    }

    await _notifySub?.cancel();
    _notifySub = _notifyChar!.onValueReceived.listen((value) {
      if (value.isEmpty) return;
      final s = String.fromCharCodes(value);
      if (kDebugMode) {
        // ignore: avoid_print
        print('📨 Notification: $s');
      }
      if (!_dataCtrl.isClosed) _dataCtrl.add(s);
    });

    if (kDebugMode) {
      // ignore: avoid_print
      print("✅ Notification subscription established");
    }
  }

  Future<void> write(String data, {int maxRetries = 3}) async {
    if (_device == null || !_isConnected) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("⚠️ Write skipped — not connected");
      }
      return;
    }
    if (_writeChar == null) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("⚠️ Write skipped — writeChar not ready");
      }
      return;
    }

    final canWriteWithResponse = _writeChar!.properties.write;
    final withoutResponse = !canWriteWithResponse;
    final bytes = data.codeUnits;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _writeChar!.write(bytes, withoutResponse: withoutResponse);
        if (kDebugMode) {
          // ignore: avoid_print
          print("✅ Write success");
        }
        return;
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print("⚠️ Write failed (attempt $attempt): $e");
        }
        if (attempt == maxRetries) return;
        await Future.delayed(Duration(milliseconds: 200 * attempt));
      }
    }
  }

  Future<void> disconnect() async {
    try {
      await _device?.disconnect();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("⚠️ disconnect() threw: $e");
      }
    } finally {
      _isConnected = false;
      if (!_connCtrl.isClosed) _connCtrl.add(false);
      _teardown();
    }
  }

  void _teardown() {
    try {
      _notifySub?.cancel();
    } catch (_) {}
    _notifySub = null;

    try {
      _connSub?.cancel();
    } catch (_) {}
    _connSub = null;

    _notifyChar = null;
    _writeChar = null;
    _device = null;
    _isConnected = false;

    if (!_connCtrl.isClosed) _connCtrl.add(false);
    if (!_readyCtrl.isClosed) _readyCtrl.add(false);
  }

  Future<bool> getCurrentConnectionState() async {
    final connected = await FlutterBluePlus.connectedDevices;
    if (_device != null) {
      return connected.any((d) => d.remoteId == _device!.remoteId);
    }
    return false;
  }

  Future<void> clearAllConnections() async {
    try {
      await stopScan();
    } catch (_) {}

    try {
      await _device?.disconnect();
    } catch (_) {}

    try {
      final connected = await FlutterBluePlus.connectedDevices;
      for (final d in connected) {
        try {
          await d.disconnect();
        } catch (_) {}
      }
    } catch (_) {}

    _device = null;
    _notifyChar = null;
    _writeChar = null;

    try {
      await _notifySub?.cancel();
    } catch (_) {}
    _notifySub = null;

    try {
      await _connSub?.cancel();
    } catch (_) {}
    _connSub = null;

    _isConnected = false;

    if (!_connCtrl.isClosed) _connCtrl.add(false);
    if (!_readyCtrl.isClosed) _readyCtrl.add(false);
  }

  void dispose() {
    try {
      _adapterStateSub?.cancel();
    } catch (_) {}
    _adapterStateSub = null;

    try {
      _scanSub?.cancel();
    } catch (_) {}
    _scanSub = null;

    try {
      _notifySub?.cancel();
    } catch (_) {}
    _notifySub = null;

    try {
      _connSub?.cancel();
    } catch (_) {}
    _connSub = null;

    if (!_connCtrl.isClosed) _connCtrl.close();
    if (!_dataCtrl.isClosed) _dataCtrl.close();
    if (!_readyCtrl.isClosed) _readyCtrl.close();
  }
}
