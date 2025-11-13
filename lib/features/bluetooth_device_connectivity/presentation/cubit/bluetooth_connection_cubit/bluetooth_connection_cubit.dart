import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';

class BluetoothConnectionCubit extends Cubit<BluetoothConnectionState> {
  final BluetoothRepository repo;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;
  StreamSubscription<List<BluetoothDeviceModel>>? _scanSub;
  StreamSubscription<bool>? _readySub;
  Timer? _scanTimer;

  BluetoothConnectionCubit(this.repo) : super(const BluetoothConnectionState());

  // ✅ Safe emit wrapper
  void safeEmit(BluetoothConnectionState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> init() async {
    _listenConnection();
    _listenData();

    // ✅ Check if already connected before scanning
    final connectedDeviceId = await repo.getAlreadyConnectedDeviceId();

    if (connectedDeviceId != null) {
      safeEmit(
        state.copyWith(
          isConnected: true,
          connectingDeviceId: connectedDeviceId,
          status: BluetoothConnectionStatus.connected,
        ),
      );

      // Send "!" to reinitialize communication
      await Future.delayed(const Duration(milliseconds: 300));
      await sendCommand("!");
    } else {
      startScan();
    }
  }

  void startScan({Duration timeout = const Duration(seconds: 15)}) {
    _scanSub?.cancel();
    _scanTimer?.cancel();

    safeEmit(
      state.copyWith(
        status: BluetoothConnectionStatus.scanning,
        isScanning: true,
        devices: [],
        connectingDeviceId: null,
      ),
    );

    _scanSub = repo
        .scan(timeout: timeout)
        .listen(
          (devices) {
            if (isClosed) return;
            safeEmit(state.copyWith(devices: devices));
          },
          onError: (e) {
            if (isClosed) return;
            safeEmit(
              state.copyWith(
                status: BluetoothConnectionStatus.textError,
                isScanning: false,
                error: '$e',
              ),
            );
          },
        );

    _scanTimer = Timer(timeout, () {
      if (isClosed) return;
      _scanSub?.cancel();
      safeEmit(state.copyWith(isScanning: false));
    });
  }

  Future<void> connectById(String id) async {
    safeEmit(
      state.copyWith(
        connectingDeviceId: id,
        status: BluetoothConnectionStatus.connecting,
      ),
    );

    try {
      await repo.connectById(id);
      safeEmit(
        state.copyWith(
          isConnected: true,
          status: BluetoothConnectionStatus.connected,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          isConnected: false,
          connectingDeviceId: null,
          status: BluetoothConnectionStatus.textError,
          error: e.toString(),
        ),
      );
      startScan();
    }
  }

  void _listenConnection() {
    _connSub?.cancel();
    _connSub = repo.connectionStatusStream().listen((connected) async {
      if (isClosed) return;

      if (connected) {
        print("✅ Bluetooth Connected");

        safeEmit(
          state.copyWith(
            isConnected: true,
            status: BluetoothConnectionStatus.connected,
          ),
        );

        await for (final ready in repo.deviceReadyStream()) {
          if (isClosed) return;
          if (ready) {
            print("✅ Device Ready – Sending initial command '!'");
            await sendCommand("!");
            break;
          }
        }
      } else {
        print("❌ Disconnected – restarting scan...");
        safeEmit(
          state.copyWith(
            isConnected: false,
            connectingDeviceId: null,
            status: BluetoothConnectionStatus.disconnected,
            devices: [],
          ),
        );

        // Wait a short delay before scanning to avoid overlap
        await Future.delayed(const Duration(seconds: 1));
        if (!isClosed) startScan();
      }
    });
  }

  Future<void> disconnect() async {
    print("🔌 Disconnect requested...");
    await repo.disconnect();

    // Cancel all active listeners immediately
    await _connSub?.cancel();
    await _dataSub?.cancel();
    await _scanSub?.cancel();
    await _readySub?.cancel();
    _scanTimer?.cancel();

    safeEmit(
      state.copyWith(
        isConnected: false,
        connectingDeviceId: null,
        status: BluetoothConnectionStatus.disconnected,
      ),
    );
  }

  Future<void> sendCommand(String data) async {
    try {
      print("📤 Sending to device: $data");
      await repo.sendData(data);
      safeEmit(state.copyWith(lastData: data));
    } catch (e) {
      print("❌ Send error: $e");
      safeEmit(state.copyWith(error: "Send error: $e"));
    }
  }

  void sendAbort() {
    if (state.isConnected) {
      print("⚠️ Sending abort '&'");
      repo.sendData("&");
    }
  }

  void _listenData() {
    _dataSub?.cancel();
    _dataSub = repo.receivedDataStream().listen(
      (s) async {
        if (isClosed) return;
        final clean = s.trim();
        print("📩 Received: $clean");

        if (clean.startsWith("H")) {
          final deviceId = clean.substring(1).trim();
          print("✅ Parsed Device ID: $deviceId");
          safeEmit(
            state.copyWith(lastData: clean, connectingDeviceId: deviceId),
          );
          print("🚀 Sending '{' after device ID handshake...");
          await Future.delayed(const Duration(milliseconds: 300));
          if (!isClosed) await sendCommand("{");
        } else {
          safeEmit(state.copyWith(lastData: clean));
        }
      },
      onError: (e) {
        if (isClosed) return;
        print("❌ Error receiving data: $e");
        safeEmit(state.copyWith(error: "Receive error: $e"));
      },
    );
  }

  @override
  Future<void> close() async {
    print("🧹 Closing BluetoothConnectionCubit...");
    await _connSub?.cancel();
    await _dataSub?.cancel();
    await _scanSub?.cancel();
    await _readySub?.cancel();
    _scanTimer?.cancel();
    return super.close();
  }
}
