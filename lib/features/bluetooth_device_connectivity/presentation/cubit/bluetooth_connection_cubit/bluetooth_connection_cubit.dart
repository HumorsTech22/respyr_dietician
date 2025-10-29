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

  void init() {
    _listenConnection();
    _listenData();
    startScan();
  }

  void startScan({Duration timeout = const Duration(seconds: 15)}) {
    _scanSub?.cancel();
    _scanTimer?.cancel();

    emit(
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
            emit(state.copyWith(devices: devices));
          },
          onError: (e) {
            emit(
              state.copyWith(
                status: BluetoothConnectionStatus.textError,
                isScanning: false,
                error: '$e',
              ),
            );
          },
        );

    _scanTimer = Timer(timeout, () {
      _scanSub?.cancel();
      emit(state.copyWith(isScanning: false));
    });
  }

  Future<void> connectById(String id) async {
    emit(
      state.copyWith(
        connectingDeviceId: id,
        status: BluetoothConnectionStatus.connecting,
      ),
    );

    try {
      await repo.connectById(id);
      emit(
        state.copyWith(
          isConnected: true,
          status: BluetoothConnectionStatus.connected,
        ),
      );
    } catch (e) {
      emit(
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
      if (connected) {
        print("✅ Bluetooth Connected");

        emit(
          state.copyWith(
            isConnected: true,
            status: BluetoothConnectionStatus.connected,
          ),
        );

        // Wait until the device is fully ready before sending
        await for (final ready in repo.deviceReadyStream()) {
          if (ready) {
            print("✅ Device Ready – Sending initial command '!' ...");
            await sendCommand("!");
            break;
          }
        }
      } else {
        print("❌ Disconnected");
        emit(
          state.copyWith(
            isConnected: false,
            connectingDeviceId: null,
            status: BluetoothConnectionStatus.disconnected,
            devices: [],
          ),
        );
        startScan();
      }
    });
  }

  Future<void> disconnect() async {
    await repo.disconnect();
    emit(
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
      emit(state.copyWith(lastData: data));
    } catch (e) {
      print("❌ Send error: $e");
      emit(state.copyWith(error: "Send error: $e"));
    }
  }

  void sendAbort() {
    if (state.isConnected) repo.sendData("&");
  }

  void _listenData() {
    _dataSub?.cancel();
    _dataSub = repo.receivedDataStream().listen((s) async {
      final clean = s.trim();
      print("📩 Received: $clean");

      if (clean.startsWith("H")) {
        final deviceId = clean.substring(1).trim();
        print("✅ Parsed Device ID: $deviceId");
        emit(state.copyWith(lastData: clean, connectingDeviceId: deviceId));
        print("🚀 Sending '{' after device ID handshake...");
        await Future.delayed(const Duration(milliseconds: 300));
        await sendCommand("{");
      } else {
        emit(state.copyWith(lastData: clean));
      }
    }, onError: (e) => print("❌ Error receiving data: $e"));
  }

  @override
  Future<void> close() {
    _connSub?.cancel();
    _dataSub?.cancel();
    _scanSub?.cancel();
    _readySub?.cancel();
    _scanTimer?.cancel();
    return super.close();
  }
}
