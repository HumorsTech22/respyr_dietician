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
  Timer? _scanTimer;

  BluetoothConnectionCubit(this.repo) : super(const BluetoothConnectionState());

  void init() {
    _listenConnection();
    _listenData();
    startScan();
  }

  void startScan() {
    _scanSub?.cancel();
    emit(
      state.copyWith(
        status: BluetoothConnectionStatus.scanning,
        isScanning: true,
        devices: [],
      ),
    );

    _scanSub = repo.scan().listen(
      (devices) {
        emit(state.copyWith(devices: devices));
      },
      onError: (e) {
        emit(
          state.copyWith(
            status: BluetoothConnectionStatus.error,
            isScanning: false,
            error: '$e',
          ),
        );
      },
    );

    _scanTimer = Timer(const Duration(seconds: 15), () {
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
      await repo.sendData("{");
      emit(
        state.copyWith(
          isConnected: true,
          connectingDeviceId: null,
          status: BluetoothConnectionStatus.connected,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isConnected: false,
          connectingDeviceId: null,
          status: BluetoothConnectionStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> disconnect() async {
    await repo.disconnect();
  }

  Future<void> send(String data) => repo.sendData(data);

  void _listenConnection() {
    _connSub?.cancel();
    _connSub = repo.connectionStatusStream().listen((connected) {
      emit(
        state.copyWith(
          isConnected: connected,
          status:
              connected
                  ? BluetoothConnectionStatus.connected
                  : BluetoothConnectionStatus.disconnected,
        ),
      );
    });
  }

  void _listenData() {
    _dataSub?.cancel();
    _dataSub = repo.receivedDataStream().listen((s) {
      if (s.trim() == '120') {
        disconnect();
      }
      emit(state.copyWith(lastData: s));
    });
  }

  @override
  Future<void> close() {
    _connSub?.cancel();
    _dataSub?.cancel();
    _scanSub?.cancel();
    _scanTimer?.cancel();
    return super.close();
  }
}
