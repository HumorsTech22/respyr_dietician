import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/generating_result_repository.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';

import 'bluetooth_generating_result_state.dart';
import 'package:respyr_dietitian/common/ble_logging/ble_logger_http.dart';

class BluetoothGeneratingResultCubit extends Cubit<BluetoothGeneratingResultState> {
  final BluetoothRepository repo;
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;
  final List<double> blowValuesList;
  final ClientProfileModel clientProfileModel;
  final double minRange;
  final double maxRange;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final GeneratingResultRepository repository;
  final UserHabitsModel userHabitsModel;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  bool _disposed = false;
  bool _isGeneratingResult = false;
  bool _isProcessing = false;
  bool _initRan = false;

  final StringBuffer _rawBuffer = StringBuffer();

  static const int _timeoutSeconds = 300;
  Timer? _timeoutTimer;
  int _remainingSeconds = _timeoutSeconds;

  bool _firstBleFragmentLogged = false;
  int _bleFragmentCount = 0;

  static const int _maxBufferChars = 50 * 1024;

  BluetoothGeneratingResultCubit({
    required this.repo,
    required this.maxPressure,
    required this.bestPressure,
    required this.blowDuration,
    required this.blowValuesList,
    required this.clientProfileModel,
    required this.repository,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange, required this.userHabitsModel,
  }) : super(const BluetoothGeneratingResultState()) {
    _init();
  }

  String _cap(String s, int n) => (s.length <= n) ? s : s.substring(0, n);

  String _cleanError(Object e) {
    return e.toString().replaceFirst("Exception: ", "").trim();
  }

  void _logEvt(
      String type,
      String msg, {
        String payload = "",
        bool allowBeforeSession = false,
      }) {
    String direction = "ble";
    if (type == "ui") direction = "ui";
    else if (type == "ble_tx") direction = "tx";
    else if (type == "ble_rx") direction = "rx";
    else if (type == "parse") direction = "parse";
    else if (type == "timeout") direction = "timeout";
    else if (type == "error") direction = "error";
    else if (type == "fail") direction = "fail";
    else if (type == "api") direction = "api";

    BleLoggerHttp.I.logEvent(
      screen: "generating_result",
      direction: direction,
      eventType: type,
      message: msg,
      payloadText: _cap(payload, 240),
      allowBeforeSession: allowBeforeSession,
    );
  }

  void _init() {
    if (_initRan) return;
    _initRan = true;

    _connSub?.cancel();
    _dataSub?.cancel();

    _logEvt(
      "ui",
      "init()",
      payload: "connected=${repo.isConnected} profile=${clientProfileModel.profileId}",
      allowBeforeSession: true,
    );

    _connSub = repo.connectionStatusStream().listen(
      _handleBluetoothConnection,
      onError: (e) {
        _logEvt("error", "CONN_STREAM error", payload: e.toString());
      },
    );

    _dataSub = repo.receivedDataStream().listen(
      _onBluetoothDataReceived,
      onError: (e) {
        _logEvt("error", "DATA_STREAM error", payload: e.toString());
      },
    );

    _startTimeoutTimer();

    if (repo.isConnected) {
      _handleBluetoothConnection(true);
    } else {
      emit(state.copyWith(isBluetoothConnected: false));
    }
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _remainingSeconds = _timeoutSeconds;

    emit(
      state.copyWith(
        remainingSeconds: _remainingSeconds,
        isTimedOut: false,
      ),
    );

    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_disposed) {
        t.cancel();
        return;
      }

      _remainingSeconds--;

      if (_remainingSeconds <= 0) {
        _remainingSeconds = 0;
        emit(state.copyWith(remainingSeconds: 0));
        t.cancel();
        _handleTimeout();
        return;
      }

      if (_remainingSeconds == 240 ||
          _remainingSeconds == 180 ||
          _remainingSeconds == 120 ||
          _remainingSeconds == 60) {
        _logEvt("ui", "timeout ticking", payload: "remaining=$_remainingSeconds");
      }

      emit(state.copyWith(remainingSeconds: _remainingSeconds));
    });
  }

  void _handleTimeout() {
    if (_disposed) return;

    _logEvt("fail", "TIMEOUT", payload: "5 minutes exceeded");

    sendAbort();

    emit(
      state.copyWith(
        isTimedOut: true,
        textError: "Timeout: 5 minutes exceeded",
      ),
    );

    _stopStreamsOnly();
  }

  void _stopTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  Future<void> _handleBluetoothConnection(bool connected) async {
    if (_disposed) return;

    emit(state.copyWith(isBluetoothConnected: connected));
    _logEvt("ble", "CONN_STREAM", payload: "connected=$connected");

    if (connected) {
      if (!_isGeneratingResult && !state.isTimedOut) {
        _isGeneratingResult = true;
        emit(state.copyWith(completedSteps: 1));
        _triggerAnalysis();
      }
    } else {
      if (!state.isDialogShown && !state.isTimedOut) {
        _showDisconnectedDialog();
      }
    }
  }

  Future<void> fetchDietitianResult({
    required double acetone,
    required double ethanol,
    required double hydrogen,
    required bool diabetic,
    required String goal,
    required String dietitianId,
    required String profileId,
    required String dietPlanId,
    required double minRange,
    required double maxRange,
    required ClientProfileModel client,
    required String deviceId,
    required String age,
    required String activity
  }) async {
    final sw = Stopwatch()..start();

    _logEvt(
      "z",
      "fetchResultsNew start",
      payload:
      "profile=$profileId dietitian=$dietitianId dietPlan=$dietPlanId deviceId=$deviceId",
    );

    try {
      final result = await repository.fetchResultsNew(
        acetone: acetone,

        ethanol: ethanol,
        hydrogen: hydrogen,
        diabetic: diabetic,
        goal: goal,
        dietitianId: dietitianId,
        profileId: profileId,
        dietPlanId: dietPlanId,
        minRange: minRange,
        maxRange: maxRange,
        client: client,
        deviceId: deviceId, age: age, activity: activity,

      );

      if (_disposed) return;

      _logEvt(
        "api",
        "fetchResultsNew success",
        payload: "ms=${sw.elapsedMilliseconds}",
      );

      emit(
        state.copyWith(
          dietitianResult: result,
          textError: null,
          hasInternet: true,
        ),
      );
    } catch (e) {
      if (_disposed) return;

      final errorMessage = _cleanError(e);

      print("Error :$errorMessage");

      final lower = errorMessage.toLowerCase();
      final hasInternet = !(lower.contains("no internet") ||
          lower.contains("timed out") ||
          lower.contains("network error") ||
          lower.contains("socketexception"));

      _logEvt(
        "error",
        "fetchResultsNew fail",
        payload: "ms=${sw.elapsedMilliseconds} err=$errorMessage",
      );

      emit(
        state.copyWith(
          textError: e.toString(),
          hasInternet: hasInternet,
          navigateToResultScreen: false,
        ),
      );
    }
  }

  void _triggerAnalysis() {
    if (_disposed || state.isTimedOut) return;

    try {
      repo.sendData("/");
      _logEvt("ble_tx", "TX trigger analysis", payload: "/");

      if (kDebugMode) {
        print("📤 Sent '/' to BLE for triggering analysis");
      }
    } catch (e) {
      _logEvt("error", "TX trigger analysis error", payload: e.toString());
      if (kDebugMode) {
        print("⚠️ Error sending trigger to BLE: $e");
      }
    }
  }

  void _onBluetoothDataReceived(String data) {
    if (_disposed || state.isTimedOut) return;
    if (data.isEmpty) return;

    _bleFragmentCount++;
    final frag = data.trim();

    if (!_firstBleFragmentLogged) {
      _firstBleFragmentLogged = true;
      _logEvt("ble_rx", "First BLE fragment", payload: frag);
    } else if (_bleFragmentCount <= 8 || _bleFragmentCount % 25 == 0) {
      _logEvt("ble_rx", "BLE fragment", payload: frag);
    }

    _rawBuffer.write(data);

    if (_rawBuffer.length > _maxBufferChars) {
      _logEvt(
        "fail",
        "BLE buffer overflow",
        payload: "len=${_rawBuffer.length} (no '*')",
      );
      _rawBuffer.clear();
      emit(state.copyWith(textError: "Device data overflow. Please restart test."));
      sendAbort();
      _stopStreamsOnly();
      return;
    }

    if (kDebugMode) {
      print("📥 BLE Fragment: $data");
      print("🔎 RawBuffer: ${_rawBuffer.toString()}");
    }

    final full = _rawBuffer.toString();

    if (!full.contains("*")) return;

    _logEvt("ble", "Payload end marker '*'", payload: "buffer_len=${full.length}");

    final cleaned =
    full.replaceFirst(RegExp(r'^\s*analize', caseSensitive: false), '');

    _rawBuffer.clear();

    _processFinalData(cleaned.trim());
  }

  Future<void> _processFinalData(String rawData) async {
    if (_isProcessing || _disposed || state.isTimedOut) return;
    _isProcessing = true;

    _logEvt("ui", "_processFinalData start", payload: "raw_len=${rawData.length}");

    try {
      emit(state.copyWith(completedSteps: 2));
      await Future.delayed(const Duration(seconds: 1));
      if (_disposed || state.isTimedOut) return;

      emit(state.copyWith(completedSteps: 3));
      await Future.delayed(const Duration(seconds: 1));
      if (_disposed || state.isTimedOut) return;

      String cleaned = rawData
          .replaceAll(RegExp(r'\{.*?\}'), '')
          .replaceAll(RegExp(r'analize', caseSensitive: false), '')
          .replaceAll('*', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '')
          .trim();

      cleaned = cleaned.replaceAll(RegExp(r'\${2,}'), '\$');

      if (kDebugMode) {
        print("🎯 Cleaned BLE Test Data: $cleaned");
      }

      final replaced = cleaned
          .replaceAll("Best_pr", bestPressure.toStringAsFixed(0))
          .replaceAll("MAXPR", maxPressure.toStringAsFixed(0))
          .replaceAll("BDur", blowDuration.toString());

      _logEvt("ble", "Final testdata ready", payload: _cap(replaced, 200));

      if (kDebugMode) {
        print("✅ Final Test Data Ready for API: $replaced");
      }

      emit(state.copyWith(dataReceivedFromDevice: true, textError: null));

      final apiResponse = await _callProcessRawDataApi(replaced);
      if (_disposed || state.isTimedOut) return;

      if (apiResponse == null) {
        _logEvt("fail", "process_raw_data invalid response");
        emit(
          state.copyWith(
            textError: "API response invalid",
            navigateToResultScreen: false,
          ),
        );
        return;
      }

      final acetone = (apiResponse['acetone'] as num?)?.toDouble() ?? 0;
      final ethanol = (apiResponse['ethanol'] as num?)?.toDouble() ?? 0;
      final hydrogen = (apiResponse['hydrogen'] as num?)?.toDouble() ?? 0;
      final String deviceId = apiResponse['deviceId']?.toString() ?? "";

      _logEvt(
        "api",
        "process_raw_data parsed",
        payload: "acet=$acetone eth=$ethanol h2=$hydrogen deviceId=$deviceId",
      );

      emit(
        state.copyWith(
          acetone: acetone,
          ethanol: ethanol,
          hydrogen: hydrogen,
          textError: null,
          hasInternet: true,
        ),
      );

      await fetchDietitianResult(
        acetone: acetone,
        ethanol: ethanol,
        hydrogen: hydrogen,
        diabetic: dietPlanStrategyModel.isDiabetic,
        goal: userHabitsModel.goal.toLowerCase().replaceAll(" ", "_"),
        dietitianId: clientProfileModel.dietitianId,
        profileId: clientProfileModel.profileId,
        dietPlanId: dietPlanStrategyModel.id.toString(),
        minRange: minRange,
        maxRange: maxRange,
        client: clientProfileModel,
        deviceId: clientProfileModel.profileId,
        age: clientProfileModel.age,
        activity:  userHabitsModel.activity.toLowerCase().replaceAll(" ", "_"),
      );

      if (_disposed || state.isTimedOut) return;

      if (state.dietitianResult == null || (state.textError?.isNotEmpty ?? false)) {
        _logEvt("fail", "result fetch failed, navigation blocked");
        return;
      }

      _stopTimeoutTimer();

      _logEvt("ui", "navigateToResultScreen=true");

      emit(
        state.copyWith(
          navigateToResultScreen: true,
          textError: null,
        ),
      );
    } catch (e) {
      if (_disposed) return;
      final errorMessage = _cleanError(e);
      _logEvt("error", "process flow error", payload: errorMessage);
      emit(
        state.copyWith(
          textError: "Error while processing results: $errorMessage",
          navigateToResultScreen: false,
        ),
      );
    } finally {
      _isProcessing = false;
    }
  }

  void resetNavigationFlag() {
    if (_disposed) return;
    emit(state.copyWith(navigateToResultScreen: false));
  }


  String cleanBleName(String name) {
    return name
        .trim()
        .toUpperCase()
        .replaceAll("RESPYR_", "")
        .replaceAll("RESPYR", "")
        .replaceAll("_", "")
        .replaceAll("-", "");
  }



  Future<Map<String, dynamic>?> _callProcessRawDataApi(String testData) async {
    const String apiUrl =
        "https://humorstech.com/dietitian/api/app/process_raw_data.php";
    final sw = Stopwatch()..start();

    try {
      final blowValues = blowValuesList.join(", ");

      final body = {
        'testdata': testData,
        'subid': "${clientProfileModel.dietitianId}\$${clientProfileModel.profileId}",
        'gender': clientProfileModel.gender,
        'age': clientProfileModel.age.toString(),
        'height': clientProfileModel.height.toString(),
        'blow_region': 'south_indian',
        'blow_raw_values': blowValues,
        'diet_plan_id': dietPlanStrategyModel.id.toString(),
        'ble_name': cleanBleName(repo.connectedDeviceName),
      };

      _logEvt(
        "api",
        "process_raw_data start",
        payload:
        "subid=${body['subid']} age=${body['age']} gender=${body['gender']} height=${body['height']} blow_values_count=${blowValuesList.length} diet_plan_id=${body['diet_plan_id']}",
      );

      if (kDebugMode) {
        print("--------------------------------------------------");
        print("📡 Sending API Request to: $apiUrl");
        print("📤 POST Parameters:");
        body.forEach((key, value) {
          debugPrint("   ➤ $key : $value");
        });
        print("--------------------------------------------------");
      }

      http.Response? response;
      Object? lastError;

      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          _logEvt("api", "process_raw_data attempt", payload: "attempt=$attempt");

          response = await http
              .post(
            Uri.parse(apiUrl),
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: body,
          )
              .timeout(const Duration(seconds: 45));

          if (response.statusCode == 200) {
            break;
          }

          // retry only for server issues
          if (response.statusCode >= 500 && attempt < 3) {
            _logEvt(
              "fail",
              "process_raw_data server retry",
              payload: "attempt=$attempt status=${response.statusCode}",
            );
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }

          break;
        } on SocketException catch (e) {
          lastError = e;
          if (attempt < 3) {
            _logEvt(
              "error",
              "process_raw_data socket retry",
              payload: "attempt=$attempt",
            );
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }
        } on TimeoutException catch (e) {
          lastError = e;
          if (attempt < 3) {
            _logEvt(
              "error",
              "process_raw_data timeout retry",
              payload: "attempt=$attempt",
            );
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }
        }
      }

      if (response == null) {
        if (lastError is SocketException) {
          emit(
            state.copyWith(
              hasInternet: false,
              textError: "No internet connection. Please check your network.",
            ),
          );
        } else if (lastError is TimeoutException) {
          emit(
            state.copyWith(
              hasInternet: false,
              textError: "Internet is slow. Request timed out, please try again.",
            ),
          );
        } else {
          emit(
            state.copyWith(
              textError: "Unable to connect to server. Please try again.",
            ),
          );
        }

        _logEvt(
          "error",
          "process_raw_data failed after retries",
          payload: "ms=${sw.elapsedMilliseconds}",
        );
        return null;
      }

      _logEvt(
        "api",
        "process_raw_data response",
        payload: "status=${response.statusCode} ms=${sw.elapsedMilliseconds}",
      );

      if (kDebugMode) {
        print("🌐 API Response Status: ${response.statusCode}");
        print("🌐 API Response Body: ${response.body}");
      }

      if (response.statusCode != 200) {
        _logEvt(
          "fail",
          "process_raw_data non-200",
          payload: _cap(response.body, 200),
        );

        emit(
          state.copyWith(
            hasInternet: response.statusCode >= 500 ? true : false,
            textError: response.statusCode >= 500
                ? "Server is busy. Please try again."
                : "Request failed: ${response.statusCode}",
          ),
        );
        return null;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        _logEvt("fail", "process_raw_data decode not map");
        emit(
          state.copyWith(
            hasInternet: true,
            textError: "Invalid response from server.",
          ),
        );
        return null;
      }

      if ((decoded["status"] ?? "").toString().toLowerCase() != "success") {
        _logEvt(
          "fail",
          "process_raw_data status!=success",
          payload: _cap(response.body, 200),
        );
        emit(
          state.copyWith(
            hasInternet: true,
            textError: decoded["message"]?.toString() ?? "Processing failed.",
          ),
        );
        return null;
      }

      final data = decoded["data"];


      double acetone = 0, ethanol = 0, hydrogen = 0;
      String deviceId = "";

      if (data is Map<String, dynamic>) {
        acetone = (data["AcetonePpm"] as num?)?.toDouble() ?? 0;
        ethanol = (data["ethanolPpm"] as num?)?.toDouble() ?? 0;
        hydrogen = (data["H2Ppm"] as num?)?.toDouble() ?? 0;
        deviceId = data["hwid"]?.toString() ?? "";
      } else if (data is List && data.isNotEmpty) {
        final first = data.first;

        if (first is Map<String, dynamic>) {
          deviceId = first["hwid"]?.toString() ?? "";
          acetone = (first["AcetonePpm"] as num?)?.toDouble() ?? acetone;
          ethanol = (first["ethanolPpm"] as num?)?.toDouble() ?? ethanol;
          hydrogen = (first["H2Ppm"] as num?)?.toDouble() ?? hydrogen;
        }
      }


      acetone = (decoded["AcetonePpm"] as num?)?.toDouble() ?? acetone;
      ethanol = (decoded["ethanolPpm"] as num?)?.toDouble() ?? ethanol;
      hydrogen = (decoded["H2Ppm"] as num?)?.toDouble() ?? hydrogen;

      emit(
        state.copyWith(
          hasInternet: true,
          textError: null,
        ),
      );

      return {
        "acetone": acetone,
        "ethanol": ethanol,
        "hydrogen": hydrogen,
        "deviceId": deviceId,
      };
    } on FormatException {
      _logEvt(
        "error",
        "process_raw_data exception",
        payload: "ms=${sw.elapsedMilliseconds} err=Invalid response from server",
      );
      emit(
        state.copyWith(
          hasInternet: true,
          textError: "Invalid response from server.",
        ),
      );
      return null;
    } catch (e) {
      final errorMessage = _cleanError(e);
      _logEvt(
        "error",
        "process_raw_data exception",
        payload: "ms=${sw.elapsedMilliseconds} err=$errorMessage",
      );
      if (kDebugMode) {
        print("⚠️ API Error: $e");
      }
      emit(
        state.copyWith(
          textError: errorMessage,
        ),
      );
      return null;
    }
  }
  void _showDisconnectedDialog() {
    if (_disposed) return;
    _logEvt("ui", "showDisconnectedDialog()");
    emit(state.copyWith(isDialogShown: true));
  }

  void dialogDismissed() {
    if (_disposed) return;
    _logEvt("ui", "dialogDismissed()");
    emit(state.copyWith(isDialogShown: false));
  }

  void sendAbort() {
    try {
      if (repo.isConnected) {
        _logEvt("ble_tx", "TX abort", payload: "&");
        repo.sendData("&");
      }
    } catch (_) {}
  }

  void _stopStreamsOnly() {
    _connSub?.cancel();
    _dataSub?.cancel();
    _connSub = null;
    _dataSub = null;
  }

  void _stopAll() {
    _disposed = true;
    _stopTimeoutTimer();
    _stopStreamsOnly();
  }

  @override
  Future<void> close() {
    _logEvt("ui", "close()");
    _stopAll();
    return super.close();
  }
}