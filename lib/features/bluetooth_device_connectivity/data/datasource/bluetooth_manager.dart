import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// ✅ Link status so UI can show "Reconnecting..." / "Disconnected" etc.
enum BleLinkStatus { connecting, connected, reconnecting, disconnected }

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

  /// ✅ NEW: for UI
  final _linkCtrl = StreamController<BleLinkStatus>.broadcast();
  Stream<BleLinkStatus> get linkStatusStream => _linkCtrl.stream;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSub;

  bool _isConnected = false;

  // ✅ prevent double-connect calls
  bool _connecting = false;

  // ✅ (optional) allow future reconnect logic if you add later
  bool autoReconnectEnabled = true;

  // ====== UUIDs ======
  final Guid serviceUuid = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid notifyCharacteristicUuid =
  Guid("49535343-1e4d-4bd9-ba61-23c647249616");
  final Guid writeCharacteristicUuid =
  Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStream => _connCtrl.stream;
  Stream<String> get dataStream => _dataCtrl.stream;
  Stream<bool> get deviceReadyStream => _readyCtrl.stream;

  void _emitLink(BleLinkStatus s) {
    if (!_linkCtrl.isClosed) _linkCtrl.add(s);
  }

  void _handleBluetoothOff() {
    _isConnected = false;
    if (!_connCtrl.isClosed) _connCtrl.add(false);
    if (!_readyCtrl.isClosed) _readyCtrl.add(false);

    _emitLink(BleLinkStatus.disconnected);
    _teardown();
  }

  // ===================== SCAN =====================

  /// flutter_blue_plus ^2.2.1 compatible scan
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 8),
    void Function(List<ScanResult>)? onResults,
    String nameContains = "respyr",
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

    // listen scan results BEFORE startScan (safer)
    await _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final filtered = results.where((r) {
        // iOS: device.platformName may be empty, use advertisementData.advName too
        final devName = (r.device.platformName).toLowerCase();
        final advName = (r.advertisementData.advName).toLowerCase();
        final matchesName =
            devName.contains(nameContains) || advName.contains(nameContains);

        // In ^2.2.1, serviceUuids is List<Guid>
        final advUuids = r.advertisementData.serviceUuids
            .map((e) => e.toString().toLowerCase())
            .toList();

        final matchesService =
        advUuids.contains(serviceUuid.toString().toLowerCase());

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

    try {
      await FlutterBluePlus.startScan(timeout: timeout);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("⚠️ startScan error: $e");
      }
      return;
    }
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

  // ===================== CONNECT =====================

  /// Connect directly by device instance
  Future<void> connect(
      BluetoothDevice device, {
        VoidCallback? onConnected,
        Duration readyTimeout = const Duration(seconds: 12),
      }) async {
    if (_connecting) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("⚠️ connect() ignored — already connecting");
      }
      return;
    }

    _connecting = true;
    _emitLink(BleLinkStatus.connecting);

    final readyCompleter = Completer<void>();

    try {
      await stopScan();

      // disconnect previous
      if (_device != null && _device!.remoteId != device.remoteId) {
        try {
          await _device?.disconnect();
        } catch (_) {}
      }

      _device = device;
      _notifyChar = null;
      _writeChar = null;

      if (kDebugMode) {
        // ignore: avoid_print
        print("🔌 Connecting to ${device.remoteId.str}...");
      }

      await _connSub?.cancel();
      _connSub = device.connectionState.listen((s) async {
        final connected = (s == BluetoothConnectionState.connected);
        _isConnected = connected;

        if (!_connCtrl.isClosed) _connCtrl.add(connected);

        if (connected) {
          _emitLink(BleLinkStatus.connected);

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

            onConnected?.call();

            if (!readyCompleter.isCompleted) {
              readyCompleter.complete();
            }
          } catch (e, st) {
            if (kDebugMode) {
              // ignore: avoid_print
              print("❌ Discover/subscribe failed: $e\n$st");
            }
            if (!readyCompleter.isCompleted) {
              readyCompleter.completeError(e);
            }
            _emitLink(BleLinkStatus.disconnected);
            _teardown();
          }
        } else {
          // disconnected (includes supervision timeout)
          _emitLink(BleLinkStatus.disconnected);
          _teardown();
        }
      });

      try {
        await device.connect(license: License.free, autoConnect: false);
      } catch (e) {
        final msg = e.toString().toLowerCase();
        // ignore harmless "already connected"
        if (!msg.contains("already connected")) {
          if (kDebugMode) {
            // ignore: avoid_print
            print("⚠️ device.connect() threw: $e");
          }
          _emitLink(BleLinkStatus.disconnected);
          _teardown();
          rethrow;
        }
      }

      await readyCompleter.future.timeout(readyTimeout, onTimeout: () {
        throw TimeoutException("BLE connect timeout");
      });
    } finally {
      _connecting = false;
    }
  }

  /// Connect by remoteId.str
  Future<void> connectById(
      String id, {
        Duration scanTimeout = const Duration(seconds: 10),
      }) async {
    List<BluetoothDevice> connected = const [];
    try {
      connected = await FlutterBluePlus.connectedDevices;
    } catch (_) {}

    final already = connected.where((d) => d.remoteId.str == id).toList();
    if (already.isNotEmpty) {
      return connect(already.first);
    }

    final found = Completer<void>();
    StreamSubscription<List<ScanResult>>? sub;

    await stopScan();

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
      await FlutterBluePlus.startScan(timeout: scanTimeout);
      await found.future;
    } finally {
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}
      await sub?.cancel();
      await stopScan();
    }
  }

  // ===================== DISCOVER + NOTIFY =====================

  Future<void> _discoverAndSubscribe() async {
    final d = _device;
    if (d == null) throw Exception('No device');

    if (kDebugMode) {
      // ignore: avoid_print
      print("🔍 Discovering services...");
    }

    // small delay helps on iOS sometimes
    await Future.delayed(const Duration(milliseconds: 250));

    final services = await d.discoverServices();

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

    await _notifySub?.cancel();

    // enable notifications
    try {
      await _notifyChar!.setNotifyValue(true);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 250));
      await _notifyChar!.setNotifyValue(true);
    }

    // ^2.2.1 uses onValueReceived
    _notifySub = _notifyChar!.onValueReceived.listen((value) {
      if (value.isEmpty) return;
      final s = String.fromCharCodes(value);

      if (kDebugMode) {
        // ignore: avoid_print
        print('📨 Notification: $s');
      }

      if (!_dataCtrl.isClosed) _dataCtrl.add(s);
    }, onError: (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("⚠️ notify stream error: $e");
      }
    });

    if (kDebugMode) {
      // ignore: avoid_print
      print("✅ Notification subscription established");
    }
  }

  // ===================== WRITE =====================

  /// ✅ Updated for iOS reliability:
  /// - If iOS and characteristic supports "write", prefer withResponse (withoutResponse=false)
  /// - Else fallback to withoutResponse only when "writeWithoutResponse" is available
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

    final bytes = data.codeUnits;

    final supportsWrite = _writeChar!.properties.write;
    final supportsWriteWoResp = _writeChar!.properties.writeWithoutResponse;

    // iOS: prefer withResponse whenever possible
    bool withoutResponse;
    if (Platform.isIOS) {
      withoutResponse = !supportsWrite; // if no write, we must use withoutResponse
    } else {
      // Android: use withoutResponse if available and write is not available
      withoutResponse = !supportsWrite && supportsWriteWoResp;
    }

    // sanity: if neither exists, this will fail but we log properly
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _writeChar!.write(bytes, withoutResponse: withoutResponse);
        if (kDebugMode) {
          // ignore: avoid_print
          print("✅ Write success: '$data' (withoutResponse=$withoutResponse)");
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

  // ===================== DISCONNECT / TEARDOWN =====================

  Future<void> disconnect() async {
    _emitLink(BleLinkStatus.disconnected);
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
    List<BluetoothDevice> connected = const [];
    try {
      connected = await FlutterBluePlus.connectedDevices;
    } catch (_) {}

    if (_device != null) {
      final ok = connected.any((d) => d.remoteId == _device!.remoteId);
      _emitLink(ok ? BleLinkStatus.connected : BleLinkStatus.disconnected);
      return ok;
    }
    _emitLink(BleLinkStatus.disconnected);
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
          // await d.clearGattCache();
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

    _emitLink(BleLinkStatus.disconnected);
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
    if (!_linkCtrl.isClosed) _linkCtrl.close();
  }
}