import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit/bluetooth_generating_result_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

class BluetoothGeneratingResultCubit
    extends Cubit<BluetoothGeneratingResultState> {
  final BluetoothRepository repo;
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;
  final List<double> blowValuesList;
  final ClientProfileModel clientProfileModel;

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
    required this.clientProfileModel,
  }) : super(const BluetoothGeneratingResultState()) {
    _init();
  }

  void _init() {
    _connSub = repo.connectionStatusStream().listen(_handleBluetoothConnection);
    _dataSub = repo.receivedDataStream().listen(_onBluetoothDataReceived);

    if (repo.isConnected) {
      _handleBluetoothConnection(true);
    }
  }

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

  void _triggerAnalysis() {
    if (_disposed) return;

    try {
      repo.sendData("/");
      if (kDebugMode) print("📤 Sent '/' to BLE for triggering analysis");
    } catch (e) {
      if (kDebugMode) print("⚠️ Error sending trigger to BLE: $e");
    }
  }

  void _onBluetoothDataReceived(String data) {
    if (data.isEmpty || _disposed) return;

    _rawBuffer.write(data);
    _rawData += data;

    if (kDebugMode) {
      print("📥 BLE Received Fragment: $data");
      print("🔎 Accumulated Raw Data: $_rawData");
    }

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

  Future<void> _processFinalData(String rawData) async {
    if (_isProcessing || _disposed) return;
    _isProcessing = true;

    try {
      emit(state.copyWith(completedSteps: 2));
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(completedSteps: 3));
      await Future.delayed(const Duration(seconds: 1));

      // ✅ Clean and format the raw BLE data
      String cleaned =
          rawData
              .replaceAll(RegExp(r'\{.*?\}'), '') // remove all {...}
              .replaceAll(
                RegExp(r'analize', caseSensitive: false),
                '',
              ) // remove "analize"
              .replaceAll('*', '') // remove '*'
              .replaceAll('\n', '') // remove newlines
              .replaceAll('\r', '') // remove carriage returns
              .replaceAll(' ', '') // remove spaces
              .trim();

      // ✅ Optional: collapse multiple '$$' into one
      cleaned = cleaned.replaceAll(RegExp(r'\${2,}'), '\$');

      if (kDebugMode) {
        print("🎯 Cleaned BLE Test Data: $cleaned");
      }

      // Continue as before — insert your replacements if needed
      final replaced = cleaned
          .replaceAll("Best_pr", bestPressure.toStringAsFixed(0))
          .replaceAll("MAXPR", maxPressure.toStringAsFixed(0))
          .replaceAll("BDur", blowDuration.toString());

      if (kDebugMode) {
        print("✅ Final Test Data Ready for API: $replaced");
      }

      final apiResponse = await _callProcessRawDataApi(replaced);

      if (apiResponse != null) {
        emit(
          state.copyWith(
            acetone: (apiResponse['acetone'] as num?)?.toDouble(),
            ethanol: (apiResponse['ethanol'] as num?)?.toDouble(),
            hydrogen: (apiResponse['hydrogen'] as num?)?.toDouble(),
            navigateToResultScreen: true,
          ),
        );
      } else {
        emit(state.copyWith(textError: "API response invalid"));
      }
    } catch (e) {
      emit(state.copyWith(textError: "Error while processing results: $e"));
    } finally {
      _isProcessing = false;
    }
  }

  void resetNavigationFlag() {
    emit(state.copyWith(navigateToResultScreen: false));
  }

  /// ✅ API Call Function - with full parameter logging
  Future<Map<String, dynamic>?> _callProcessRawDataApi(String testData) async {
    const String apiUrl =
        "https://humorstech.com/dietitian/api/app/process_raw_data.php";

    try {
      // Convert the blow values list to comma-separated string
      final blowValues = blowValuesList.join(", ");

      // Prepare the request body
      final body = {
        'testdata': testData,
        'subid':
            "${clientProfileModel.dietitianId}\$${clientProfileModel.profileId}",
        'gender': clientProfileModel.gender,
        'age': clientProfileModel.age.toString(),
        'height': clientProfileModel.height.toString(),
        'blow_region': 'south_indian',
        'blow_raw_values': blowValues,
      };

      // ✅ Print all request parameters neatly
      if (kDebugMode) {
        print("--------------------------------------------------");
        print("📡 Sending API Request to: $apiUrl");
        print("📤 POST Parameters:");
        body.forEach((key, value) {
          print("   ➤ $key : $value");
        });
        print("--------------------------------------------------");
      }

      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
      );

      // Log the API response
      if (kDebugMode) {
        print("🌐 API Response Status: ${response.statusCode}");
        print("🌐 API Response Body: ${response.body}");
      }

      // Parse the API response
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded["status"] == "success" && decoded["data"] != null) {
          final data = decoded["data"];
          return {
            "acetone": data["AcetonePpm"],
            "ethanol": data["ethanolPpm"],
            "hydrogen": data["H2Ppm"],
          };
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) print("⚠️ API Error: $e");
      return null;
    }
  }

  void _showDisconnectedDialog() {
    emit(state.copyWith(isDialogShown: true));
  }

  void dialogDismissed() {
    if (_disposed) return;
    emit(state.copyWith(isDialogShown: false));
  }

  void sendAbort() {
    repo.sendData("&");
  }

  Future<void> setCancelOrDisconnectFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('cancel_or_disconnect_time', now.toIso8601String());
  }

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
