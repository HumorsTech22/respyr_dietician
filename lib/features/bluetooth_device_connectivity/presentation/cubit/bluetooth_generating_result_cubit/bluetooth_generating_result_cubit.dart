import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit/bluetooth_generating_result_state.dart';

class BluetoothGeneratingResultCubit
    extends Cubit<BluetoothGeneratingResultState> {
  final BluetoothRepository repo;
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;
  final List<double> blowValuesList;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  bool _disposed = false;
  bool _isGeneratingResult = false;
  bool _isProcessing = false;

  final StringBuffer _rawBuffer = StringBuffer();
  String _rawData = "";

  BluetoothGeneratingResultCubit({
    required this.repo,
    required this.maxPressure,
    required this.bestPressure,
    required this.blowDuration,
    required this.blowValuesList,
  }) : super(const BluetoothGeneratingResultState()) {
    init();
  }

  void init() {
    _connSub = repo.connectionStatusStream().listen(handleBluetoothConnection);
    _dataSub = repo.receivedDataStream().listen(onBluetoothDataReceived);

    if (repo.isConnected) {
      handleBluetoothConnection(true);
    }
  }

  Future<void> handleBluetoothConnection(bool connected) async {
    if (_disposed) return;

    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected && !_isGeneratingResult) {
      _isGeneratingResult = true;
      emit(state.copyWith(completedSteps: 1));
      triggerAnalysis();
    } else if (!connected && !state.isDialogShown) {
      showDisconnectedDialog();
    }
  }

  void triggerAnalysis() {
    if (_disposed) return;

    try {
      repo.sendData("/");
      if (kDebugMode) {
        print("📤 Sent '/' to BLE for triggering analysis");
      }
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ Error sending trigger to BLE: $e");
      }
    }
  }

  void onBluetoothDataReceived(String data) {
    if (data.isEmpty || _disposed) return;

    _rawBuffer.write(data);
    _rawData += data;

    if (kDebugMode) {
      print("📥 USB Received Fragment: $data");
      print("🔎 Accumulated Raw Data: $_rawData");
    }

    // When full response ends with '*'
    if (_rawData.contains("*")) {
      final cleaned = _rawBuffer.toString().replaceFirst(
        RegExp(r'^analize'),
        '',
      );

      processFinalData(cleaned.trim());
      _rawBuffer.clear();
      _rawData = "";
    }
  }

  Future<void> processFinalData(String rawData) async {
    if (_isProcessing || _disposed) return;
    _isProcessing = true;

    emit(state.copyWith(completedSteps: 2));
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(completedSteps: 3));
    await Future.delayed(const Duration(seconds: 1));

    try {
      final replaced = rawData
          .replaceAll("Best_pr", bestPressure.toStringAsFixed(0))
          .replaceAll("MAXPR", maxPressure.toStringAsFixed(0))
          .replaceAll("BDur", blowDuration.toString());

      if (kDebugMode) {
        print("🎯 Final Clean Data Ready: $replaced");
      }

      emit(state.copyWith(navigateToResultScreen: true));
    } catch (e) {
      emit(state.copyWith(textError: "Error while processing results: $e"));
    } finally {
      _isProcessing = false; // ready for next packet
    }
  }

  void showDisconnectedDialog() {
    emit(state.copyWith(isDialogShown: true));
  }

  void dialogDismissed() {
    if (_disposed) return;
    emit(state.copyWith(isDialogShown: false));
  }

  void stop() {
    _disposed = true;
    _connSub?.cancel();
    _dataSub?.cancel();
    _connSub = null;
    _dataSub = null;
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
