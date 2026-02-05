import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'bluetooth_connection_state.dart';

class BluetoothConnectionCubit extends Cubit<BluetoothConnectionState> {
  final BluetoothRepository repo;
  Timer? _readyTimeoutTimer;
  bool _waitingReady = false;
  bool _startupRunning = false;

  static const Duration _readyTimeout = Duration(seconds: 3);

  BluetoothConnectionCubit(this.repo) : super(const BluetoothConnectionState());

  void safeEmit(BluetoothConnectionState s) {
    if (!isClosed) emit(s);
  }

  // ================= INIT =================
  Future<void> init() async {
    print("Initializing Bluetooth Connection...");

    _listenConnection();
    _listenData();

    // already connected case (coming back from calibration)
    if (repo.isConnected) {
      print("Device already connected.");
      safeEmit(state.copyWith(
        isConnected: true,
        status: BluetoothConnectionStatus.connected,
        isScanning: false,
        deviceReady: false,
        isDeviceError: false,
      ));

      await _checkDeviceReadiness();
    } else {
      print("Device not connected. Starting scan...");
      startScan();
    }
  }

  // ================= SCAN =================
  void startScan({Duration timeout = const Duration(seconds: 15)}) {
    print("Starting scan for Bluetooth devices...");

    safeEmit(state.copyWith(
      status: BluetoothConnectionStatus.scanning,
      isScanning: true,
      devices: [],
      connectingDeviceId: null,
      deviceReady: false,
      textError: null,
    ));

    repo.scan(timeout: timeout).listen(
          (devices) {
        print("Scan results: Found ${devices.length} devices.");
        safeEmit(state.copyWith(devices: devices));
      },
      onError: (e) {
        print("Scan error: $e");
        safeEmit(state.copyWith(
          status: BluetoothConnectionStatus.textError,
          isScanning: false,
          textError: e.toString(),
        ));
      },
    );
  }

  // ================= CONNECT =================
  Future<void> connectById(String id) async {
    print("Connecting to device with ID: $id");

    safeEmit(state.copyWith(
      connectingDeviceId: id,
      status: BluetoothConnectionStatus.connecting,
      textError: null,
      deviceReady: false,
    ));

    try {
      await repo.connectById(id);
      print("Successfully connected to device with ID: $id");
      await _checkDeviceReadiness();
    } catch (e) {
      print("Error connecting to device: $e");
      safeEmit(state.copyWith(
        isConnected: false,
        connectingDeviceId: null,
        status: BluetoothConnectionStatus.textError,
        textError: e.toString(),
      ));
      startScan();
    }
  }

  // ================= CONNECTION LISTENER =================
  void _listenConnection() {
    repo.connectionStatusStream().listen((connected) async {
      print("Connection status changed: $connected");

      if (connected) {
        safeEmit(state.copyWith(
          isConnected: true,
          status: BluetoothConnectionStatus.connected,
          isScanning: false,
          textError: null,
          deviceReady: false,
        ));
        await _checkDeviceReadiness();
      } else {
        safeEmit(state.copyWith(
          isConnected: false,
          connectingDeviceId: null,
          status: BluetoothConnectionStatus.disconnected,
          devices: [],
          deviceReady: false,
        ));
        startScan();
      }
    });
  }

  // ================= READY CHECK =================
  Future<void> _checkDeviceReadiness() async {
    if (_startupRunning) return;
    _startupRunning = true;

    print("Checking if the device is ready...");

    // Send readiness check
    await _sendReadyCheck();

    // Start a timeout to handle failure if no response
    _readyTimeoutTimer = Timer(_readyTimeout, () {
      print("Ready timeout reached. Retrying readiness check...");
      if (!state.deviceReady) {
        _sendReadyCheck();
      }
    });
  }

  Future<void> _sendReadyCheck() async {
    print("Sending readiness check...");

    try {
      await repo.sendData("{"); // Send the readiness check command
      await repo.sendData("%"); // Send the readiness check command
      print("Ready check sent successfully.");
    } catch (e) {
      print("Error sending readiness check: $e");
      safeEmit(state.copyWith(isDeviceError: true, textError: "Device not ready"));
    }
  }

  // ================= DATA LISTENER =================
  void _listenData() {
    print("Listening for data...");

    repo.receivedDataStream().listen((data) {
      final cleanedData = data.trim();
      if (cleanedData.isEmpty) return;

      print("Received data: '$cleanedData'");

      if (cleanedData == "%" ) {
        print("Device is ready.");
        _handleReadyPacket();
      }
    });
  }

  void _handleReadyPacket() {
    print("Handling ready packet...");
    _readyTimeoutTimer?.cancel();
    _readyTimeoutTimer = null;
    if(!state.deviceReady){
      safeEmit(state.copyWith(deviceReady: true));
    }
  }

  // ================= SEND =================
  void sendAbort() {
    if (state.isConnected) {
      print("Sending abort...");
      try {
        repo.sendData("&"); // Abort command
      } catch (_) {
        print("Error sending abort.");
      }
    }
  }

  @override
  Future<void> close() async {
    print("Closing Bluetooth Connection Cubit...");
    _readyTimeoutTimer?.cancel();
    await super.close();
  }
}
