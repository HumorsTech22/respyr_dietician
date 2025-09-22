import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/generating_results/generating_result_state.dart';

class GeneratingResultCubit extends Cubit<GeneratingResultState> {
  final UsbCommunicationService usbService;
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  bool _disposed = false;
  bool _isGeneratingResult = false;
  bool _isProcessing = false;

  final StringBuffer _rawBuffer = StringBuffer();
  String _rawData = "";

  GeneratingResultCubit({
    required this.usbService,
    required this.maxPressure,
    required this.bestPressure,
    required this.blowDuration,
  }) : super(const GeneratingResultState()) {
    init();
  }

  void init() {
    _connSub = usbService.connectionStatusStream.listen(_handleConnection);
    _dataSub = usbService.dataStream.listen(_onDataReceived);

    if (usbService.isConnected) _handleConnection(true);
  }

  void _handleConnection(bool connected) {
    if (_disposed) return;

    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected && !_isGeneratingResult) {
      _isGeneratingResult = true;
      emit(state.copyWith(completedSteps: 1));
    } else if (!connected && !state.isDialogShown) {
      showDisconnectedDialog();
    }
  }

  void _onDataReceived(String data) {
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
        RegExp(r'^analizeanalize'),
        '',
      );

      _processFinalData(cleaned.trim());
      _rawBuffer.clear();
      _rawData = "";
    }
  }

  void _processFinalData(String rawData) async {
    if (_isProcessing || _disposed) return;
    _isProcessing = true;

    // Replace placeholders
    String replaced = rawData
        .replaceAll("Best_pr", bestPressure.toStringAsFixed(0))
        .replaceAll("MAXPR", maxPressure.toStringAsFixed(0))
        .replaceAll("BDur", blowDuration.toString());

    if (kDebugMode) {
      print("✅ Final Processed Data: $replaced");
    }

    // Step 2
    emit(state.copyWith(completedSteps: 2));
    await Future.delayed(const Duration(seconds: 1));

    // Step 3
    emit(state.copyWith(completedSteps: 3));
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Call API here with `replaced`

    emit(state.copyWith(navigateToResultScreen: true));
  }

  void showDisconnectedDialog() => emit(state.copyWith(isDialogShown: true));

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
