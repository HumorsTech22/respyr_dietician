import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'bluetooth_connection_state.dart';

class BluetoothConnectionCubit extends Cubit<BluetoothConnectionState> {
  final BluetoothRepository repo;

  Timer? _readyTimeoutTimer;

  StreamSubscription? _connSub;
  StreamSubscription? _dataSub;
  StreamSubscription? _readySub;
  StreamSubscription? _scanSub;

  static const Duration _readyTimeout = Duration(seconds: 5);

  bool _wasEverConnected = false;

  // ✅ NEW: handshake control (prevents infinite loop)
  bool _handshakeCompleted = false;
  bool _handshakeInProgress = false;

  BluetoothConnectionCubit(this.repo) : super(const BluetoothConnectionState());

  void _log(String msg) {
    if (kDebugMode) {
      // ignore: avoid_print
      print("🟦 BLE_CUBIT | $msg");
    }
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

  Future<void> init() async {
    _log("init() repo.isConnected=${repo.isConnected}");

    _listenConnection();
    _listenData();
    _listenDeviceReady();

    if (repo.isConnected) {
      _wasEverConnected = true;
      safeEmit(state.copyWith(
        isConnected: true,
        isConnecting: false,
        status: BluetoothConnectionStatus.connected,
        isScanning: false,
      ));
      await _checkAppReadiness();
    } else {
      startScan();
    }
  }

  void _listenConnection() {
    _connSub?.cancel();

    _log("_listenConnection() subscribed");
    _connSub = repo.connectionStatusStream().listen((connected) async {
      _log(
        "CONN_STREAM => connected=$connected | state(connecting=${state.isConnecting}, wasEver=$_wasEverConnected)",
      );

      if (connected) {
        _wasEverConnected = true;

        // ✅ reset handshake flags for new connection
        _handshakeCompleted = false;
        _handshakeInProgress = false;

        safeEmit(state.copyWith(
          isConnected: true,
          isConnecting: false,
          status: BluetoothConnectionStatus.connected,
          isScanning: false,
        ));

        _log("CONNECTED ✅ -> start readiness check");
        await _checkAppReadiness();
        return;
      }

      // Ignore transient false during initial connect attempt
      if (state.isConnecting && !_wasEverConnected) {
        _log("IGNORED transient DISCONNECTED (during connecting) ⚠️");
        return;
      }

      _log("REAL DISCONNECT ❌ -> teardown flags + startScan()");

      _readyTimeoutTimer?.cancel();
      _handshakeCompleted = false;
      _handshakeInProgress = false;

      safeEmit(state.copyWith(
        isConnected: false,
        isConnecting: false,
        deviceReady: false,
        status: BluetoothConnectionStatus.disconnected,
      ));

      if (!state.isScanning) startScan();
    }, onError: (e) {
      _log("CONN_STREAM ERROR => $e");
    });
  }

  void _listenDeviceReady() {
    _readySub?.cancel();

    _log("_listenDeviceReady() subscribed");
    _readySub = repo.deviceReadyStream().listen((isGattReady) async {
      _log("READY_STREAM => isGattReady=$isGattReady | state.isConnected=${state.isConnected}");
      if (isGattReady && state.isConnected) {
        await _checkAppReadiness();
      }
    }, onError: (e) {
      _log("READY_STREAM ERROR => $e");
    });
  }

  void _listenData() {
    _dataSub?.cancel();


    _log("_listenData() subscribed");
    _dataSub = repo.receivedDataStream().listen((data) {
      final cleaned = data.trim();
      if (cleaned.isEmpty) return;


      _log("DATA_STREAM => '$cleaned'");

      if(cleaned.contains("ERROR")){
        String errorMessage = cleaned=="{ERROR:003}" ? "LOW_BATTERY" : "DEVICE_ERROR";
        safeEmit(state.copyWith(isDeviceError: true, textError: errorMessage));
      }

      safeEmit(state.copyWith(lastData: cleaned));

      if (cleaned.contains("%")) {
        _log("READY PACKET detected (%) ✅");
        _handleReadyPacket();
      }
    }, onError: (e) {
      _log("DATA_STREAM ERROR => $e");
    });
  }

  // ------------------- Handshake -------------------

  Future<void> _checkAppReadiness() async {
    _log("_checkAppReadiness() called | completed=$_handshakeCompleted, inProgress=$_handshakeInProgress");

    if (!state.isConnected) return;
    if (_handshakeCompleted) return;

    // ✅ Only allow one timer/session
    if (_handshakeInProgress) return;
    _handshakeInProgress = true;

    _readyTimeoutTimer?.cancel();

    // Send once immediately
    await _sendHandshake();

    // If % not received within 5 sec -> send again until % arrives
    _readyTimeoutTimer = Timer.periodic(_readyTimeout, (timer) async {
      if (!state.isConnected) {
        _log("Stop handshake timer (not connected)");
        timer.cancel();
        _handshakeInProgress = false;
        return;
      }

      if (_handshakeCompleted) {
        _log("Stop handshake timer (received %)");
        timer.cancel();
        _handshakeInProgress = false;
        return;
      }

      _log("Handshake retry (no % yet) -> sending again");
      await _sendHandshake();
    });
  }

  Future<void> _sendHandshake() async {
    try {
      _log("SEND '{' and '%' ...");
      await repo.sendData("{");
      await repo.sendData("%");
    } catch (e) {
      _log("SEND ERROR => $e");
    }
  }

  void _handleReadyPacket() {
    if (_handshakeCompleted) return;

    _log("_handleReadyPacket() -> STOP handshake");
    _handshakeCompleted = true;
    _handshakeInProgress = false;
    _readyTimeoutTimer?.cancel();

    safeEmit(state.copyWith(deviceReady: true));
  }

  // ------------------- Scan -------------------

  void startScan({Duration timeout = const Duration(seconds: 15)}) {
    if (state.isConnected || state.isConnecting) return;

    _scanSub?.cancel();

    safeEmit(state.copyWith(
      status: BluetoothConnectionStatus.scanning,
      isScanning: true,
      isConnecting: false,
      devices: const [],
      textError: null,
    ));

    _scanSub = repo.scan(timeout: timeout).listen(
          (devices) {
        safeEmit(state.copyWith(
          devices: devices,
          isScanning: true,
        ));
      },
      onError: (e) {
        safeEmit(state.copyWith(
          status: BluetoothConnectionStatus.textError,
          textError: e.toString(),
          isScanning: false,
          isConnecting: false,
        ));
      },
      onDone: () {
        safeEmit(state.copyWith(isScanning: false));
      },
    );
  }

  Future<void> connectById(String id) async {
    if (state.isConnecting || state.isConnected) return;

    _scanSub?.cancel();
    try {
      await repo.stopScan();
    } catch (_) {}

    _wasEverConnected = false;

    // ✅ reset handshake for new attempt
    _handshakeCompleted = false;
    _handshakeInProgress = false;

    safeEmit(state.copyWith(
      connectingDeviceId: id,
      status: BluetoothConnectionStatus.connecting,
      isConnecting: true,
      isScanning: false,
      textError: null,
      deviceReady: false,
    ));

    try {
      await repo.connectById(id);
    } catch (e) {
      safeEmit(state.copyWith(
        status: BluetoothConnectionStatus.textError,
        textError: e.toString(),
        isConnecting: false,
        isConnected: false,
        connectingDeviceId: null,
      ));
      startScan();
    }
  }

  Future<void> disconnect() async {
    try {
      await repo.disconnect();
    } catch (_) {}
  }

  void sendAbort() {
    if (state.isConnected) {
      try {
        repo.sendData("&");
      } catch (_) {}
    }
  }

  @override
  Future<void> close() async {
    _readyTimeoutTimer?.cancel();
    await _connSub?.cancel();
    await _dataSub?.cancel();
    await _readySub?.cancel();
    await _scanSub?.cancel();
    return super.close();
  }
}
