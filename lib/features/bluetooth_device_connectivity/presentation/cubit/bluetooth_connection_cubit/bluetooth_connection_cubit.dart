import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';
import '../../../../../core/battery/device_battery_manager.dart';

class BluetoothConnectionCubit extends Cubit<BluetoothConnectionState> {
  final BluetoothRepository repo;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;
  StreamSubscription<List<BluetoothDeviceModel>>? _scanSub;
  StreamSubscription<bool>? _readySub;
  Timer? _scanTimer;

  Completer<void>? _batteryDoneCompleter;
  Timer? _batteryTimeoutTimer;

  bool _isWaitingBattery = false;
  bool _batteryAlreadyReceived = false;

  DateTime? _lastBatteryStopSentAt;

  Future<void>? _batteryFetchTask;
  DateTime? _lastBatteryStartSentAt;
  static const Duration _batteryStartCooldown = Duration(milliseconds: 600);

  static const String _batteryStartCmd = "@";
  static const String _batteryStopCmd = "@";

  BluetoothConnectionCubit(this.repo) : super(const BluetoothConnectionState());

  void safeEmit(BluetoothConnectionState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> init() async {
    _listenConnection();
    _listenData();

    final connectedDeviceId = await repo.getAlreadyConnectedDeviceId();

    if (connectedDeviceId != null) {
      safeEmit(
        state.copyWith(
          isConnected: true,
          connectingDeviceId: connectedDeviceId,
          status: BluetoothConnectionStatus.connected,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      await _fetchBatteryOnce();

      if (!isClosed) await sendCommand("!");
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

    _scanSub = repo.scan(timeout: timeout).listen(
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
            textError: '$e',
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
          textError: e.toString(),
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
        safeEmit(
          state.copyWith(
            isConnected: true,
            status: BluetoothConnectionStatus.connected,
          ),
        );

        _readySub?.cancel();
        _readySub = repo.deviceReadyStream().listen((ready) async {
          if (isClosed || !ready) return;

          await _fetchBatteryOnce();

          if (!isClosed) await sendCommand("!");

          await _readySub?.cancel();
        });
      } else {
        _cancelBatteryWaiters();

        safeEmit(
          state.copyWith(
            isConnected: false,
            connectingDeviceId: null,
            status: BluetoothConnectionStatus.disconnected,
            devices: [],
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (!isClosed) startScan();
      }
    });
  }

  Future<void> _sendBatteryStopOnce() async {
    final now = DateTime.now();
    if (_lastBatteryStopSentAt != null &&
        now.difference(_lastBatteryStopSentAt!) <
            const Duration(milliseconds: 400)) {
      return;
    }

    _lastBatteryStopSentAt = now;

    try {
      await repo.sendData(_batteryStopCmd);
    } catch (_) {}
  }

  Future<void> _fetchBatteryOnce() {
    if (isClosed) return Future.value();

    if ((state.batteryPercentage ?? 0) > 0) {
      return Future.value();
    }

    if (_batteryFetchTask != null) {
      return _batteryFetchTask!;
    }

    _batteryFetchTask = _fetchBatteryOnceInternal().whenComplete(() {
      _batteryFetchTask = null;
    });

    return _batteryFetchTask!;
  }

  Future<void> _fetchBatteryOnceInternal() async {
    if (isClosed || _isWaitingBattery) return;

    final now = DateTime.now();
    if (_lastBatteryStartSentAt != null &&
        now.difference(_lastBatteryStartSentAt!) < _batteryStartCooldown) {
      return;
    }
    _lastBatteryStartSentAt = now;

    _isWaitingBattery = true;
    _batteryAlreadyReceived = false;
    _batteryDoneCompleter = Completer<void>();

    try {
      await repo.sendData(_batteryStartCmd);
    } catch (_) {}

    _batteryTimeoutTimer?.cancel();
    _batteryTimeoutTimer = Timer(const Duration(seconds: 15), () {
      if (_batteryDoneCompleter?.isCompleted == false) {
        _batteryDoneCompleter?.complete();
      }
    });

    await _batteryDoneCompleter?.future;

    _batteryTimeoutTimer?.cancel();
    _batteryTimeoutTimer = null;

    _batteryDoneCompleter = null;
    _isWaitingBattery = false;
  }

  void _cancelBatteryWaiters() {
    _batteryTimeoutTimer?.cancel();
    _batteryTimeoutTimer = null;

    _isWaitingBattery = false;
    _batteryAlreadyReceived = false;

    if (_batteryDoneCompleter?.isCompleted == false) {
      _batteryDoneCompleter?.complete();
    }
    _batteryDoneCompleter = null;

    _batteryFetchTask = null;
  }

  void _listenData() {
    _dataSub?.cancel();

    _dataSub = repo.receivedDataStream().listen(
          (s) async {
        if (isClosed) return;

        final clean = s.trim();

        final errorMatch = RegExp(r'^\{ERROR:(\d{3})\}$').firstMatch(clean);
        if (errorMatch != null) {
          _cancelBatteryWaiters();

          safeEmit(
            state.copyWith(
              deviceErrorMessage:
              "ERROR:${errorMatch.group(1)} - Please check device",
            ),
          );
          return;
        }

        final batteryMatch = RegExp(r'^@(\d+(\.\d+)?)@$').firstMatch(clean);

        if (_isWaitingBattery && batteryMatch != null) {
          final battery = double.tryParse(batteryMatch.group(1)!);

          if (battery != null && !_batteryAlreadyReceived) {
            _batteryAlreadyReceived = true;

            safeEmit(state.copyWith(batteryPercentage: battery));
            await DeviceBatteryManager.setBatteryPercentage(battery);

            await _sendBatteryStopOnce();

            _batteryDoneCompleter?.complete();
          }
          return;
        }

        if (!_isWaitingBattery && batteryMatch != null) return;

        if (clean.startsWith("H")) {
          final deviceId = clean.substring(1).trim();
          safeEmit(
            state.copyWith(
              lastData: clean,
              connectingDeviceId: deviceId,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
          if (!isClosed) await sendCommand("{");
        } else {
          safeEmit(state.copyWith(lastData: clean));
        }
      },
      onError: (e) {
        if (!isClosed) {
          safeEmit(state.copyWith(textError: "Receive error: $e"));
        }
      },
    );
  }

  Future<void> sendCommand(String data) async {
    try {
      await repo.sendData(data);
      safeEmit(state.copyWith(lastData: data));
    } catch (e) {
      safeEmit(state.copyWith(textError: "Send error: $e"));
    }
  }

  void sendAbort() {
    if (state.isConnected) {
      repo.sendData("&");
    }
  }

  @override
  Future<void> close() async {
    _cancelBatteryWaiters();

    await _connSub?.cancel();
    await _dataSub?.cancel();
    await _scanSub?.cancel();
    await _readySub?.cancel();

    _scanTimer?.cancel();
    _batteryTimeoutTimer?.cancel();

    return super.close();
  }
}
