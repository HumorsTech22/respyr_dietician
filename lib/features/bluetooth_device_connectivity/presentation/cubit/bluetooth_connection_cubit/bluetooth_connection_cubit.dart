import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:respyr_dietitian/common/ble_logging/get_os_version.dart';
import 'package:respyr_dietitian/common/ble_logging/get_phone_model.dart' show getPhoneModel;

import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'bluetooth_connection_state.dart';

import 'package:respyr_dietitian/common/ble_logging/ble_logger_http.dart';

class BluetoothConnectionCubit extends Cubit<BluetoothConnectionState> {
  final BluetoothRepository repo;

  Timer? _readyTimeoutTimer;
  StreamSubscription? _connSub;
  StreamSubscription? _dataSub;
  StreamSubscription? _readySub;
  StreamSubscription? _scanSub;
  StreamSubscription<fbp.BluetoothAdapterState>? _adapterSub;

  Timer? _scanRetryTimer;
  Timer? _pruneTimer;
  Timer? _scanKickTimer;

  Timer? _connectGraceTimer;
  bool _connectAttemptActive = false;
  String? _selectedDeviceId;

  static const Duration _readyTimeout = Duration(seconds: 5);

  static const Duration _scanRetryEvery = Duration(seconds: 3);
  static const Duration _deviceStaleAfter = Duration(seconds: 6);
  static const Duration _pruneEvery = Duration(seconds: 2);

  static const Duration _scanKickEvery = Duration(seconds: 7);
  static const Duration _scanKickGap = Duration(milliseconds: 200);

  static const Duration _connectGraceDuration = Duration(seconds: 4);

  bool _wasEverConnected = false;

  bool _handshakeCompleted = false;
  bool _handshakeInProgress = false;

  bool _initCalled = false;
  bool _scanRequested = false;
  bool _startingScan = false;

  bool deviceIsExhaleOrInhaleModeCalled = false;

  final _frameBuffer = _BleFrameBuffer();
  final Map<String, _SeenDevice> _seen = {};

  bool _firstRxLogged = false;

  bool _sessionStarted = false;
  String? _sessionId;
  String? _profileIdForSession;

  BluetoothConnectionCubit(this.repo) : super(const BluetoothConnectionState());



  void _log(String msg) {
    if (kDebugMode) {
      print("🟦 BLE_CUBIT | $msg");
    }
  }

  String _cap(String s, int n) {
    if (s.length <= n) return s;
    return s.substring(0, n);
  }

  void _bleLog(
      String screen,
      String direction,
      String eventType,
      String message, [
        String? payload,
        Map<String, dynamic>? meta,
      ]) {
    BleLoggerHttp.I.logEvent(
      screen: screen,
      direction: direction,
      eventType: eventType,
      message: message,
      payloadText: _cap(payload ?? "", 220),
      meta: meta,
    );
  }

  Future<void> _ensureSessionStarted({String? profileId}) async {
    if (_sessionStarted) return;

    _sessionStarted = true;
    _profileIdForSession = profileId ?? _profileIdForSession ?? "unknown_profile";
    _sessionId = "sess_${DateTime.now().millisecondsSinceEpoch}";

    final appVersion = "1.0.0";
    final platform =
    defaultTargetPlatform == TargetPlatform.iOS ? "ios" : "android";

    final phoneModel = await getPhoneModel();
    final osVersion = await getOsVersion();

    await BleLoggerHttp.I.createSession(
      sessionId: _sessionId!,
      profileId: _profileIdForSession!,
      appVersion: appVersion,
      platform: platform,
      osVersion: osVersion,
      phoneModel: phoneModel,
    );

    BleLoggerHttp.I.logEvent(
      screen: "connect",
      direction: "ui",
      eventType: "ui",
      message: "Connect flow started",
      payloadText: "profile=${_profileIdForSession!}",
      allowBeforeSession: true,
    );
  }

  void safeEmit(BluetoothConnectionState s) {
    if (!isClosed) {
      emit(s);
      _log(
        "EMIT => status=${s.status}, scan=${s.isScanning}, conn=${s.isConnected}, "
            "connecting=${s.isConnecting}, id=${s.connectingDeviceId}, ready=${s.deviceReady}",
      );
    }
  }

  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');
  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');

  Future<void> init({String? profileId}) async {
    if (_initCalled) return;
    _initCalled = true;

    await _ensureSessionStarted(profileId: profileId);

    _listenAdapter();
    _listenConnection();
    _listenData();
    _listenDeviceReady();

    _bleLog(
      "connect",
      "ui",
      "init",
      "init() called",
      "repo.isConnected=${repo.isConnected},",
    );

    if (repo.isConnected) {
      _wasEverConnected = true;
      _handshakeCompleted = false;
      _handshakeInProgress = false;
      _frameBuffer.clear();
      deviceIsExhaleOrInhaleModeCalled = false;
      _firstRxLogged = false;
      _connectAttemptActive = false;
      _connectGraceTimer?.cancel();

      safeEmit(state.copyWith(
        isConnected: true,
        isConnecting: false,
        status: BluetoothConnectionStatus.connected,
        isScanning: false,
        clearTextError: true,
        deviceIsInhaleOrExhaleMode: false,
        deviceReady: false,
      ));

      _bleLog("connect", "ble", "connected_state", "Already connected at init");

      try {
      //  await repo.prepareForNewSession();
        _bleLog("connect", "ble", "prepare", "prepareForNewSession OK (init)");
      } catch (e) {
        _bleLog(
          "connect",
          "error",
          "prepare_fail",
          "prepareForNewSession FAIL (init)",
          e.toString(),
        );
      }


      if(repo.isConnected){
        // Already connected, so proceed to the next process immediately
        _wasEverConnected = true;
        _handshakeCompleted = false;
        _handshakeInProgress = false;
        _frameBuffer.clear();
        deviceIsExhaleOrInhaleModeCalled = false;
        _firstRxLogged = false;
        _connectAttemptActive = false;
        _connectGraceTimer?.cancel();

        safeEmit(state.copyWith(
          isConnected: true,
          isConnecting: false,
          status: BluetoothConnectionStatus.connected,
          isScanning: false,
          clearTextError: true,
          deviceIsInhaleOrExhaleMode: false,
          deviceReady: false,
        ));

        _bleLog("connect", "ble", "connected_state", "Already connected at init");
        _checkAppReadiness();
      }
      // if (repo.isReady) {
      //   _bleLog(
      //     "connect",
      //     "ble",
      //     "ready",
      //     "repo.isReady=true -> handshake now (init)",
      //   );
      //   await _checkAppReadiness();
      // } else {
      //   _bleLog(
      //     "connect",
      //     "ble",
      //     "not_ready",
      //     "connected but not ready -> waiting READY_STREAM (init)",
      //   );
      // }
      return;
    }

    safeEmit(state.copyWith(
      status: BluetoothConnectionStatus.disconnected,
      isScanning: false,
      isConnecting: false,
      isConnected: false,
      devices: const [],
      deviceReady: false,
      isDeviceError: false,
      clearTextError: true,
      clearConnectingDeviceId: true,
      deviceIsInhaleOrExhaleMode: false,
    ));

    _scanRequested = true;
    await _startScanFlow();
  }

  void _listenAdapter() {
    _adapterSub?.cancel();
    _adapterSub = fbp.FlutterBluePlus.adapterState.listen((s) async {
      _log("ADAPTER_STREAM => $s");
      _bleLog("connect", "ble", "adapter_state", "ADAPTER_STREAM", s.toString());

      if (s == fbp.BluetoothAdapterState.off) {
        // Bluetooth turned off
        _handleBluetoothOff();
      }
    }, onError: (e) {
      _log("ADAPTER_STREAM ERROR => $e");
      _bleLog("connect", "error", "adapter_error", "ADAPTER_STREAM ERROR", e.toString());
    });
  }

  void _handleBluetoothOff() async{
    // When Bluetooth is turned off, stop scanning and reset state
    _log("Bluetooth is off, stopping scan and resetting state.");

    _readyTimeoutTimer?.cancel();
    _scanRetryTimer?.cancel();
    _pruneTimer?.cancel();
    _scanKickTimer?.cancel();
    _connectGraceTimer?.cancel();

    _handshakeCompleted = false;
    _handshakeInProgress = false;
    deviceIsExhaleOrInhaleModeCalled = false;
    _frameBuffer.clear();
    _seen.clear();
    _firstRxLogged = false;
    _connectAttemptActive = false;
    _selectedDeviceId = null;

    try {
      await repo.stopScan();
    } catch (_) {}

    _bleLog("connect", "ble", "bt_off", "Bluetooth OFF -> stop scan, reset state");

    // Clear devices from the list
    safeEmit(state.copyWith(
      isScanning: false,
      devices: const [],
      deviceReady: false,
      isConnected: false,
      isConnecting: false,
      status: BluetoothConnectionStatus.disconnected,
      isDeviceError: false,
      clearConnectingDeviceId: true,
      deviceIsInhaleOrExhaleMode: false,
    ));
  }

  void _listenConnection() {
    _connSub?.cancel();

    _log("_listenConnection() subscribed");
    _bleLog("connect", "ble", "sub", "_listenConnection subscribed");

    _connSub = repo.connectionStatusStream().listen((connected) async {
      _log(
        "CONN_STREAM => connected=$connected | state(connecting=${state.isConnecting}, wasEver=$_wasEverConnected, attempt=$_connectAttemptActive)",
      );
      _bleLog("connect", "ble", "conn_stream", "CONN_STREAM", "connected=$connected");

      if (connected) {
        _wasEverConnected = true;
        _handshakeCompleted = false;
        _handshakeInProgress = false;
        deviceIsExhaleOrInhaleModeCalled = false;
        _frameBuffer.clear();
        _firstRxLogged = false;
        _connectAttemptActive = false;

        safeEmit(state.copyWith(
          isConnected: true,
          isConnecting: false,
          status: BluetoothConnectionStatus.connected,
          isScanning: false,
          clearTextError: true,
          deviceIsInhaleOrExhaleMode: false,
          deviceReady: false,
        ));

        _bleLog("connect", "ble", "connected", "Connected");

        return;
      }

      // If device gets disconnected, remove it from the list
      if (!connected && _seen.containsKey(_selectedDeviceId)) {
        _seen.remove(_selectedDeviceId);  // Remove the disconnected device
        _bleLog("connect", "ble", "disconnected", "Device disconnected, removing from list");
      }

      safeEmit(state.copyWith(
        isConnected: false,
        isConnecting: false,
        deviceReady: false,
        status: BluetoothConnectionStatus.disconnected,
        clearConnectingDeviceId: true,
        deviceIsInhaleOrExhaleMode: false,
      ));

      _bleLog("connect", "ble", "disconnected", "Disconnected -> reset & rescan");

      _scanRequested = true;

      final s = await fbp.FlutterBluePlus.adapterState.first;
      if (s == fbp.BluetoothAdapterState.on && !state.isScanning) {
        await _startScanFlow();
      }
    }, onError: (e) {
      _log("CONN_STREAM ERROR => $e");
      _bleLog("connect", "error", "conn_error", "CONN_STREAM ERROR", e.toString());
    });
  }

  void _listenDeviceReady() {
    _readySub?.cancel();

    _log("_listenDeviceReady() subscribed");
    _bleLog("connect", "ble", "sub", "_listenDeviceReady subscribed");

    _readySub = repo.deviceReadyStream().listen((isGattReady) async {
      _log("READY_STREAM => isGattReady=$isGattReady | connected=${state.isConnected}");
      _bleLog(
        "connect",
        "ble",
        "ready_stream",
        "READY_STREAM",
        "isGattReady=$isGattReady connected=${state.isConnected}",
      );

      if (!state.isConnected) return;
      if (!isGattReady) return;

      await _checkAppReadiness();
    }, onError: (e) {
      _log("READY_STREAM ERROR => $e");
      _bleLog("connect", "error", "ready_error", "READY_STREAM ERROR", e.toString());
    });
  }

  void _listenData() {
    _dataSub?.cancel();

    _log("_listenData() subscribed");
    _bleLog("connect", "ble", "sub", "_listenData subscribed");

    _dataSub = repo.receivedDataStream().listen((data) {
      final cleaned = data.trim();
      if (cleaned.isEmpty) return;

      _log("DATA_STREAM => '$cleaned'");

      if (!_firstRxLogged) {
        _firstRxLogged = true;
        _bleLog("connect", "rx", "ble_rx", "First RX", cleaned);
      } else {
        _bleLog("connect", "rx", "ble_rx", "RX", cleaned);
      }

      onBleData(cleaned);
      safeEmit(state.copyWith(lastData: cleaned));
    }, onError: (e) {
      _log("DATA_STREAM ERROR => $e");
      _bleLog("connect", "error", "data_error", "DATA_STREAM ERROR", e.toString());
    });
  }

  Future<void> _startScanFlow({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (_startingScan) return;
    if (state.isConnected || state.isConnecting) return;

    _startingScan = true;
    try {
      final s = await fbp.FlutterBluePlus.adapterState.first;
      if (s != fbp.BluetoothAdapterState.on) {
        _bleLog("connect", "ble", "scan_wait_bt_on", "Waiting adapter ON before scanning");
        await fbp.FlutterBluePlus.adapterState
            .firstWhere((x) => x == fbp.BluetoothAdapterState.on);
      }

      await repo.ensureScanPrerequisites();
      await Future.delayed(const Duration(milliseconds: 350));

      _bleLog("connect", "ble", "scan_start", "startScanFlow -> startScan()");
      startScan(timeout: timeout);
    } catch (e) {
      _bleLog("connect", "error", "scan_flow_error", "startScanFlow error", e.toString());
      safeEmit(state.copyWith(
        status: BluetoothConnectionStatus.textError,
        textError: e.toString(),
        isScanning: false,
        isConnecting: false,
      ));
    } finally {
      _startingScan = false;
    }
  }

  Future<void> _checkAppReadiness() async {
    _log(
      "_checkAppReadiness() called | completed=$_handshakeCompleted, inProgress=$_handshakeInProgress",
    );

    _bleLog(
      "connect",
      "ble",
      "check_readiness",
      "_checkAppReadiness",
      "completed=$_handshakeCompleted inProgress=$_handshakeInProgress ",
    );

    if (!state.isConnected) return;
    // if (!repo.isReady) return;
    if (_handshakeCompleted) return;
    if (_handshakeInProgress) return;

    _handshakeInProgress = true;

    _readyTimeoutTimer?.cancel();

    await _sendHandshake();

    _readyTimeoutTimer = Timer.periodic(_readyTimeout, (timer) async {
      if (!state.isConnected) {
        timer.cancel();
        _handshakeInProgress = false;
        return;
      }

      if (_handshakeCompleted) {
        timer.cancel();
        _handshakeInProgress = false;
        return;
      }

      if (!repo.isConnected) {
        _log("READY_TIMEOUT tick but repo not ready -> waiting");
        _bleLog(
          "connect",
          "ble",
          "ready_timeout_wait",
          "READY_TIMEOUT tick but repo not ready",
        );
        return;
      }

      _bleLog("connect", "tx", "ble_tx", "READY_TIMEOUT -> resend handshake");
      await _sendHandshake();
    });
  }

  Future<void> _sendHandshake() async {
    try {
      _bleLog("connect", "tx", "ble_tx", "TX handshake", "{ then %");
      await repo.sendData("{");
      await repo.sendData("%");
    } catch (e) {
      _log("SEND ERROR => $e");
      _bleLog("connect", "error", "tx_error", "SEND handshake error", e.toString());
    }
  }

  void _handleReadyPacket() {
    if (_handshakeCompleted) return;

    _handshakeCompleted = true;
    _handshakeInProgress = false;
    _readyTimeoutTimer?.cancel();

    _bleLog("connect", "ble", "handshake_ok", "Handshake ready packet received (%)");
    safeEmit(state.copyWith(deviceReady: true));
  }

  void _pruneAndEmit() {
    final now = DateTime.now();
    _seen.removeWhere((_, v) => now.difference(v.lastSeen) > _deviceStaleAfter);
    final list = _seen.values.map((e) => e.device).toList();

    safeEmit(state.copyWith(
      devices: list,
      isScanning: true,
    ));
  }

  bool _hasRespyrInSeen() {
    for (final v in _seen.values) {
      if (v.device.name.trim().toLowerCase().contains("respyr")) return true;
    }
    return false;
  }

  void _attachRepoScan({Duration timeout = const Duration(seconds: 15)}) {
    _scanSub?.cancel();

    _scanSub = repo.scan(timeout: timeout).listen(
          (devices) {
        final now = DateTime.now();

        int added = 0;
        for (final d in devices) {
          final name = d.name.trim().toLowerCase();
          if (!name.contains("respyr")) continue;
          _seen[d.id] = _SeenDevice(d, now);
          added++;
        }

        if (added > 0) {
          _bleLog(
            "connect",
            "ble",
            "scan_found_respyr",
            "SCAN found respyr",
            "count=$added",
          );
        }

        _pruneAndEmit();
      },
      onError: (e) {
        _bleLog("connect", "error", "scan_error", "SCAN error", e.toString());
        safeEmit(state.copyWith(
          status: BluetoothConnectionStatus.textError,
          textError: e.toString(),
          isScanning: false,
          isConnecting: false,
        ));
      },
      onDone: () {
        _bleLog("connect", "ble", "scan_done", "SCAN done");
        safeEmit(state.copyWith(isScanning: false));
      },
    );
  }

  void startScan({Duration timeout = const Duration(seconds: 15)}) {
    if (state.isConnected || state.isConnecting) return;

    _scanSub?.cancel();
    _scanRetryTimer?.cancel();
    _pruneTimer?.cancel();
    _scanKickTimer?.cancel();
    _connectGraceTimer?.cancel();
    _seen.clear();

    _bleLog("connect", "ble", "scan_start", "SCAN start", "timeout=${timeout.inSeconds}s");

    safeEmit(state.copyWith(
      status: BluetoothConnectionStatus.scanning,
      isScanning: true,
      isConnecting: false,
      devices: const [],
      isDeviceError: false,
      clearTextError: true,
      clearConnectingDeviceId: true,
      deviceReady: false,
      deviceIsInhaleOrExhaleMode: false,
    ));

    _attachRepoScan(timeout: timeout);

    _pruneTimer = Timer.periodic(_pruneEvery, (_) {
      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;
      _pruneAndEmit();
    });

    _scanRetryTimer = Timer.periodic(_scanRetryEvery, (_) async {
      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;

      if (_hasRespyrInSeen()) return;

      _log("SCAN_RETRY -> no Respyr yet, restarting repo scan");
      _bleLog("connect", "ble", "scan_retry", "SCAN_RETRY -> restart scan");

      try {
        await repo.stopScan();
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 250));

      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;

      _attachRepoScan(timeout: timeout);
    });

    _scanKickTimer = Timer.periodic(_scanKickEvery, (_) async {
      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;

      _log("SCAN_KICK -> restarting scan to catch device power cycle");
      _bleLog("connect", "ble", "scan_kick", "SCAN_KICK -> restart scan");

      try {
        await repo.stopScan();
      } catch (_) {}

      await Future.delayed(_scanKickGap);

      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;

      _attachRepoScan(timeout: timeout);
    });
  }

  // Method to clear/abort a queued connection
  void cancelConnect() {
    if (_connectAttemptActive) {
      // Abort or cancel any in-progress connection
      _log("Canceling queued connection attempt.");
      _connectAttemptActive = false; // Reset the flag
      // Optionally, trigger cleanup like stopping the scan
      repo.stopScan();
      emit(state.copyWith(
        isConnecting: false,
        status: BluetoothConnectionStatus.disconnected,
        deviceReady: false,
      ));
    }
  }

  Future<void> connectById(String id, {String? profileId}) async {
    if (state.isConnecting || state.isConnected) return;

    await _ensureSessionStarted(profileId: profileId);

    _selectedDeviceId = id;
    _connectAttemptActive = true;
    _connectGraceTimer?.cancel();

    _bleLog("connect", "ui", "tap_connect", "User tapped Connect", "id=$id");

    final s = await fbp.FlutterBluePlus.adapterState.first;
    if (s != fbp.BluetoothAdapterState.on) {
      _bleLog("connect", "error", "bt_off", "Bluetooth is off");
      safeEmit(state.copyWith(
        status: BluetoothConnectionStatus.textError,
        textError: "Bluetooth is off",
      ));
      return;
    }

    _scanRequested = false;

    _scanRetryTimer?.cancel();
    _pruneTimer?.cancel();
    _scanKickTimer?.cancel();
    _scanSub?.cancel();
    _connectGraceTimer?.cancel();

    try {
      await repo.stopScan();
    } catch (_) {}

    _wasEverConnected = false;

    _handshakeCompleted = false;
    _handshakeInProgress = false;
    deviceIsExhaleOrInhaleModeCalled = false;
    _frameBuffer.clear();
    _firstRxLogged = false;

    safeEmit(state.copyWith(
      connectingDeviceId: id,
      status: BluetoothConnectionStatus.connecting,
      isConnecting: true,
      isScanning: false,
      deviceReady: false,
      isDeviceError: false,
      clearTextError: true,
    ));

    _bleLog("connect", "ble", "connecting", "Connecting...", "id=$id");

    try {
      await repo.connectById(id);
      _bleLog("connect", "ble", "connect_ok", "repo.connectById returned OK", "id=$id");
    } catch (e) {
      _connectAttemptActive = false;
      _bleLog("connect", "error", "connect_fail", "connectById error", e.toString());
      safeEmit(state.copyWith(
        status: BluetoothConnectionStatus.textError,
        textError: e.toString(),
        isConnecting: false,
        isConnected: false,
        clearConnectingDeviceId: true,
      ));
      _scanRequested = true;
      await _startScanFlow();
    }
  }

  Future<void> disconnect() async {
    _connectAttemptActive = false;
    _connectGraceTimer?.cancel();
    _selectedDeviceId = null;

    _bleLog("connect", "ui", "disconnect", "User requested disconnect");
    try {
      await repo.disconnect();
    } catch (e) {
      _bleLog("connect", "error", "disconnect_error", "disconnect error", e.toString());
    }
  }

  void sendAbort() {
    if (state.isConnected) {
      _bleLog("connect", "tx", "ble_tx", "TX abort", "&");
      try {
        repo.sendData("&");
      } catch (e) {
        _bleLog("connect", "error", "abort_error", "sendAbort error", e.toString());
      }
    }
  }

  void onBleData(String cleaned) {
    if (cleaned.contains("%")) {
      _handleReadyPacket();
      cleaned = cleaned.replaceAll("%", "").trim();
      if (cleaned.isEmpty) return;
    }

    final frames = _frameBuffer.add(cleaned);
    for (final frame in frames) {
      _handleFullFrame(frame);
    }
  }

  void _handleFullFrame(String frame) {
    final f = frame.trim();

    _bleLog("connect", "parse", "frame", "FRAME", f);

    if (f.contains("ERROR")) {
      final errorMessage = f == "{ERROR:003}" ? "LOW_BATTERY" : "DEVICE_ERROR";
      _bleLog("connect", "error", "device_error", "DEVICE ERROR", "$errorMessage | $f");
      safeEmit(state.copyWith(isDeviceError: true, textError: errorMessage));
      return;
    }

    final bool isInhaleExhalePacket =
        _slashNum.hasMatch(f) || _curlyNum.hasMatch(f);

    if (isInhaleExhalePacket) {
      _log("✅ INHALE/EXHALE DETECTED => $f");
      _bleLog("connect", "ble", "inhale_exhale_mode", "Inhale/Exhale mode detected", f);

      if (!deviceIsExhaleOrInhaleModeCalled) {
        deviceIsExhaleOrInhaleModeCalled = true;
        safeEmit(state.copyWith(deviceIsInhaleOrExhaleMode: true));
      }
    }
  }

  @override
  Future<void> close() async {
    _bleLog("connect", "ui", "close", "Cubit close()");

    _readyTimeoutTimer?.cancel();
    _scanRetryTimer?.cancel();
    _pruneTimer?.cancel();
    _scanKickTimer?.cancel();
    _connectGraceTimer?.cancel();

    await _adapterSub?.cancel();
    await _connSub?.cancel();
    await _dataSub?.cancel();
    await _readySub?.cancel();
    await _scanSub?.cancel();

    return super.close();
  }
}

class _SeenDevice {
  final BluetoothDeviceModel device;
  DateTime lastSeen;
  _SeenDevice(this.device, this.lastSeen);
}

class _BleFrameBuffer {
  final StringBuffer _sb = StringBuffer();

  List<String> add(String chunk) {
    if (chunk.isEmpty) return const [];

    _sb.write(chunk);

    final all = _sb.toString();
    final out = <String>[];

    int searchFrom = 0;
    while (true) {
      final start = all.indexOf("{", searchFrom);
      if (start == -1) break;

      final end = all.indexOf("}", start);
      if (end == -1) break;

      out.add(all.substring(start, end + 1));
      searchFrom = end + 1;
    }

    if (out.isEmpty) {
      if (all.length > 2048) _sb.clear();
      return const [];
    }

    final lastEnd = all.lastIndexOf("}");
    final remaining = all.substring(lastEnd + 1);
    _sb.clear();
    _sb.write(remaining);

    return out;
  }

  void clear() => _sb.clear();
}