import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit/bluetooth_generating_result_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _init();
  }

  /// Initializes the listeners for Bluetooth data and connection changes.
  void _init() {
    _connSub = repo.connectionStatusStream().listen(_handleBluetoothConnection);
    _dataSub = repo.receivedDataStream().listen(_onBluetoothDataReceived);

    if (repo.isConnected) {
      _handleBluetoothConnection(true);
    }
  }

  /// Handles Bluetooth connection updates.
  Future<void> _handleBluetoothConnection(bool connected) async {
    if (_disposed) return;

    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected && !_isGeneratingResult) {
      _isGeneratingResult = true;
      emit(state.copyWith(completedSteps: 1));
      _triggerAnalysis();
    } else if (!connected && !state.isDialogShown) {
      _showDisconnectedDialog();
    }
  }

  /// Sends the trigger signal to BLE device for result generation.
  void _triggerAnalysis() {
    if (_disposed) return;

    try {
      repo.sendData("/");
      if (kDebugMode) print("📤 Sent '/' to BLE for triggering analysis");
    } catch (e) {
      if (kDebugMode) print("⚠️ Error sending trigger to BLE: $e");
    }
  }

  /// Handles incoming Bluetooth data stream.
  void _onBluetoothDataReceived(String data) {
    if (data.isEmpty || _disposed) return;

    _rawBuffer.write(data);
    _rawData += data;

    if (kDebugMode) {
      print("📥 BLE Received Fragment: $data");
      print("🔎 Accumulated Raw Data: $_rawData");
    }

    // Detect message completion
    if (_rawData.contains("*")) {
      final cleaned = _rawBuffer.toString().replaceFirst(
        RegExp(r'^analize'),
        '',
      );
      _processFinalData(cleaned.trim());
      _rawBuffer.clear();
      _rawData = "";
    }
  }

  /// Processes final BLE data, triggers result generation API, and navigates.
  Future<void> _processFinalData(String rawData) async {
    if (_isProcessing || _disposed) return;
    _isProcessing = true;

    try {
      // Step progression visuals
      emit(state.copyWith(completedSteps: 2));
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(completedSteps: 3));
      await Future.delayed(const Duration(seconds: 1));

      // Replace BLE placeholders with real values
      final replaced = rawData
          .replaceAll("Best_pr", bestPressure.toStringAsFixed(0))
          .replaceAll("MAXPR", maxPressure.toStringAsFixed(0))
          .replaceAll("BDur", blowDuration.toString());

      if (kDebugMode) print("🎯 Final BLE Clean Data Ready: $replaced");
      emit(state.copyWith(navigateToResultScreen: true));
    } catch (e) {
      emit(state.copyWith(textError: "Error while processing results: $e"));
    } finally {
      _isProcessing = false;
    }
  }

  /// Displays disconnected dialog.
  void _showDisconnectedDialog() {
    emit(state.copyWith(isDialogShown: true));
  }

  /// Called when disconnection dialog is dismissed.
  void dialogDismissed() {
    if (_disposed) return;
    emit(state.copyWith(isDialogShown: false));
  }

  /// Sends abort command to BLE device.
  void sendAbort() {
    repo.sendData("&");
  }

  /// Records the cancel/disconnect timestamp locally.
  Future<void> setCancelOrDisconnectFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('cancel_or_disconnect_time', now.toIso8601String());
  }

  /// Cancels all subscriptions safely.
  void _stop() {
    _disposed = true;
    _connSub?.cancel();
    _dataSub?.cancel();
    _connSub = null;
    _dataSub = null;
  }

  @override
  Future<void> close() {
    _stop();
    return super.close();
  }
}
