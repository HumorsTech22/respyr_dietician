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
    _listenReady();
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
      _scanSub = null;
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
    } catch (e) {
      emit(
        state.copyWith(
          isConnected: false,
          connectingDeviceId: null,
          status: BluetoothConnectionStatus.textError,
          error: e.toString(),
        ),
      );
      if (_scanSub == null) {
        startScan();
      }
    }
  }

  void _listenConnection() {
    _connSub?.cancel();
    _connSub = repo.connectionStatusStream().listen((connected) {
      if (connected) {
        emit(
          state.copyWith(
            isConnected: true,
            connectingDeviceId: null,
            status: BluetoothConnectionStatus.connected,
          ),
        );
      } else {
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

  void _listenReady() {
    _readySub?.cancel();
    _readySub = repo.deviceReadyStream().listen((ready) async {
      if (ready) {
        // ✅ Device fully ready → send opening command
        try {
          await repo.sendData("{");
          emit(state.copyWith(lastData: "Sent opening command {"));
        } catch (e) {
          emit(state.copyWith(error: "Send error: $e"));
        }
      }
    });
  }

  Future<void> disconnect() async {
    await repo.disconnect();
  }

  Future<void> send(String data) async {
    try {
      await repo.sendData(data);
      emit(state.copyWith(lastData: "Sent: $data"));
    } catch (e) {
      emit(state.copyWith(error: "Send error: $e"));
    }
  }

  void _listenData() {
    _dataSub?.cancel();
    _dataSub = repo.receivedDataStream().listen((s) {
      emit(state.copyWith(lastData: s));
    });
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
