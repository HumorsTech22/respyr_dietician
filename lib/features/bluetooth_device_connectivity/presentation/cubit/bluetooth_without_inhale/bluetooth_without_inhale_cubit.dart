import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/ble_logging/ble_logger_http.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bluetooth_inhale_cubit_new/bluetooth_inhale_new_state.dart';

class BluetoothWithoutInhaleCubit extends Cubit<BluetoothInhaleCubitNewState> {
  final BluetoothRepository repo;
  final BreathingSettings breathingSettings;

  static const bool kDebug = true;

  void d(String msg) {
    if (kDebug) {
      print("[WITHOUT_INHALE_CUBIT] $msg");
    }
  }

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  Timer? _finishTimer;
  Timer? _secondTimer;

  Timer? _inhaleTimer;
  DateTime? _inhaleStartAt;

  Timer? _holdTicker;
  DateTime? _holdStartAt;

  bool _disposed = false;
  bool _startSent = false;
  bool _testStarted = false;

  bool _cancelled = false;
  bool _flowStopped = false;

  bool _baseCaptured = false;
  double _base = 0;

  int holdSkipCounter = 0;
  List<double> holdValues = [];

  bool _holdActive = false;
  bool _holdDone = false;

  int _packetCount = 0;

  static const Duration _fixedInhaleDuration = Duration(seconds: 5);

  Duration get _holdNeed {
    final int ms = breathingSettings.hold.timeMs;
    if (ms <= 0) return const Duration(seconds: 8);
    return Duration(milliseconds: ms);
  }

  bool get _canSaveAbortTime =>
      state.holdStarted || _holdActive || state.holdFinished;

  void _bleLog(String type, String msg, [String? payload]) {
    String direction = "ble";
    if (type == "ui") direction = "ui";
    else if (type == "ble_tx") direction = "tx";
    else if (type == "ble_rx") direction = "rx";
    else if (type == "parse") direction = "parse";
    else if (type == "timeout") direction = "timeout";
    else if (type == "error") direction = "error";
    else if (type == "fail") direction = "fail";

    BleLoggerHttp.I.logEvent(
      screen: "without_inhale",
      direction: direction,
      eventType: type,
      message: msg,
      payloadText: _cap(payload ?? "", 240),
    );
  }

  String _cap(String s, int n) => (s.length <= n) ? s : s.substring(0, n);

  BluetoothWithoutInhaleCubit(this.repo, this.breathingSettings)
      : super(const BluetoothInhaleCubitNewState()) {
    d("Cubit init | connected=${repo.isConnected}");
    _bleLog("ui", "Cubit initialized", "connected=${repo.isConnected}");
    _listen();
    emit(state.copyWith(isConnected: repo.isConnected));
    startCounter(from: 5);
  }

  void _listen() {
    _connSub = repo.connectionStatusStream().listen((connected) async {
      if (_disposed) return;

      d("Connection status changed -> $connected");
      _bleLog("ble", "Connection status changed", "connected=$connected");

      emit(state.copyWith(isConnected: connected, error: null));

      if (!connected) {
        final bool flowRunning = _testStarted ||
            state.startCounterStarted ||
            state.startCounterFinished ||
            state.inhaleStarted ||
            _holdActive ||
            state.holdStarted;

        if (flowRunning && !state.inhaleFailed && !state.holdFinished) {
          d("DISCONNECT during test");

          if (_canSaveAbortTime) {
            await setCancelOrDisconnectFlag();
          }

          _finishFail("Device disconnected. Please reconnect and try again.");
        }
      }
    });

    _dataSub = repo.receivedDataStream().listen((data) {
      if (_disposed || _cancelled || _flowStopped) return;
      if (data.isEmpty || !_testStarted) return;
      if (!repo.isConnected) return;
      if (state.inhaleFailed) return;

      final clean = data.trim();
      emit(state.copyWith(receivedData: clean, error: null));

      final bool isSlash = clean.contains('/');
      final bool isCurly = clean.contains('{') || clean.contains('}');

      if (!isSlash && !isCurly) return;

      final String numberString = clean.replaceAll(RegExp(r'[^0-9.]'), '');

      if (numberString.isEmpty) return;

      double parsedValue = 0.0;
      try {
        parsedValue = double.parse(numberString);
      } catch (e) {
        d("Parse error for clean=$clean");
        _bleLog("error", "Parse failed", clean);
        return;
      }

      if (parsedValue < 700 || parsedValue > 1150) return;

      if (!_baseCaptured) {
        _base = parsedValue;
        _baseCaptured = true;

        d("Base captured: /$_base/");
        _bleLog("ble", "Base captured", "/$_base/");

        emit(state.copyWith(
          baseValueReceived: true,
          blowExhaleBaseValue: _base,
        ));
        return;
      }

      final double currentValue = parsedValue;

      _packetCount++;
      if (_packetCount <= 8 || _packetCount % 25 == 0) {
        d(
          "Packet #$_packetCount | raw={$currentValue} | base=$_base | hold=$_holdActive done=$_holdDone",
        );
        _bleLog(
          "ble_rx",
          "Packet received",
          "packet=$_packetCount raw=$currentValue base=$_base",
        );
      }

      if (_holdDone) return;

      if (_holdActive) {
        if (holdSkipCounter <= 10) {
          holdSkipCounter++;
          d("HOLD skip packet | holdSkipCounter=$holdSkipCounter raw=$currentValue");
          _bleLog(
            "ble_rx",
            "Hold skip packet",
            "skipCounter=$holdSkipCounter raw=$currentValue",
          );
          return;
        }

        holdValues.add(currentValue);

        final double delta = currentValue - _base;

        d(
          "HOLD packet | raw=$currentValue | base=$_base | delta=${delta.toStringAsFixed(3)} | count=${holdValues.length}",
        );

        _bleLog(
          "ble_rx",
          "Hold packet received",
          "raw=$currentValue base=$_base delta=${delta.toStringAsFixed(3)} count=${holdValues.length}",
        );

        emit(state.copyWith(
          progressSigned: delta,
          progress: delta.abs(),
        ));
      }
    });
  }

  void startCounter({int from = 5}) {
    if (_disposed) return;

    d("startCounter(from=$from)");

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _startSent = false;
    _testStarted = false;

    _baseCaptured = false;
    _base = 0;

    _cancelled = false;
    _flowStopped = false;

    _resetAllTracking();

    final int totalMs = from * 1000;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int endsAt = now + totalMs;

    emit(state.copyWith(
      navigateToDashboard: false,
      startCounter: from,
      startCounterMillis: totalMs,
      startCounterTotalMillis: totalMs,
      startCounterEndsAtEpochMs: endsAt,
      startCounterStarted: true,
      startCounterFinished: false,
      inhaleStarted: false,
      inhaleFinished: false,
      inhaleSuccess: false,
      inhaleFailed: false,
      inhaleFailReason: "",
      inBandSeconds: 0,
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _fixedInhaleDuration.inMilliseconds,
      inhaleNeedStartsAtEpochMs: 0,
      inhaleNeedEndsAtEpochMs: 0,
      holdStarted: false,
      holdFinished: false,
      holdSeconds: 0,
      progress: 0,
      progressSigned: 0,
      baseValueReceived: false,
      blowExhaleBaseValue: 0,
      holdBreathViolation: "",
      error: null,
    ));

    _secondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || _cancelled) return;
      final int remainingMs =
          endsAt - DateTime.now().millisecondsSinceEpoch;
      final int remainingSec = (remainingMs / 1000).ceil().clamp(0, from);
      emit(state.copyWith(startCounter: remainingSec));
    });

    _finishTimer = Timer(Duration(milliseconds: totalMs), () {
      if (_disposed || _cancelled) return;

      _secondTimer?.cancel();
      _secondTimer = null;

      emit(state.copyWith(
        startCounter: 0,
        startCounterMillis: 0,
        startCounterStarted: false,
        startCounterFinished: true,
      ));

      _sendStart();
    });
  }

  void _sendStart() {
    if (_disposed ||
        _cancelled ||
        _flowStopped ||
        _startSent ||
        !repo.isConnected) {
      return;
    }

    _startSent = true;
    d("SEND '1' start");
    _bleLog("ble_tx", "SEND start", "1");
    send("1");
    _testStarted = true;

    _startFixedInhalePhase();
  }

  void _startFixedInhalePhase() {
    _inhaleTimer?.cancel();
    _inhaleStartAt = DateTime.now();

    final int nowMs = _inhaleStartAt!.millisecondsSinceEpoch;

    emit(state.copyWith(
      inhaleStarted: true,
      inhaleFinished: false,
      inhaleSuccess: false,
      inhaleNeedRunning: true,
      inhaleNeedTotalMillis: _fixedInhaleDuration.inMilliseconds,
      inhaleNeedStartsAtEpochMs: nowMs,
      inhaleNeedEndsAtEpochMs: 0,
      inBandSeconds: 0,
      progress: 0,
      progressSigned: 0,
    ));

    _inhaleTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _cancelled || _flowStopped || state.inhaleFailed) {
        return;
      }

      final DateTime? start = _inhaleStartAt;
      if (start == null) return;

      final Duration elapsed = DateTime.now().difference(start);
      final int clampedMs =
      elapsed.inMilliseconds.clamp(0, _fixedInhaleDuration.inMilliseconds);

      final double seconds = clampedMs / 1000.0;

      emit(state.copyWith(
        inBandSeconds: seconds,
        progress: 0,
        progressSigned: 0,
      ));

      if (elapsed >= _fixedInhaleDuration) {
        _inhaleTimer?.cancel();
        _inhaleTimer = null;

        if (!_baseCaptured) {
          _finishFail("Base value not received.");
          return;
        }

        _finishInhaleSuccessStartHold();
      }
    });
  }

  void _finishInhaleSuccessStartHold() {
    if (_disposed || _cancelled || _flowStopped || state.inhaleFailed) {
      return;
    }

    _inhaleTimer?.cancel();
    _inhaleTimer = null;

    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: true,
      inhaleFailed: false,
      inhaleFailReason: "",
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _fixedInhaleDuration.inMilliseconds,
      inhaleNeedEndsAtEpochMs: nowMs,
      holdStarted: true,
      holdFinished: false,
      holdSeconds: 0,
      progress: 0,
      progressSigned: 0,
    ));

    d("SEND '2' start hold");
    _bleLog("ble_tx", "SEND hold", "2");
    send("2");

    _startHoldTicker();
  }

  void _startHoldTicker() {
    _holdActive = true;
    _holdDone = false;
    _holdStartAt = DateTime.now();

    holdValues = [];
    holdSkipCounter = 0;

    d("HOLD started | duration=${_holdNeed.inSeconds}s | base=$_base");
    _bleLog("ble", "Hold started", "duration=${_holdNeed.inSeconds}s base=$_base");

    _holdTicker?.cancel();
    _holdTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _cancelled || _flowStopped) return;

      final DateTime? start = _holdStartAt;
      if (start == null) return;

      final Duration elapsed = DateTime.now().difference(start);
      final double sec = (elapsed.inMilliseconds / 1000.0)
          .clamp(0.0, _holdNeed.inMilliseconds / 1000.0);

      emit(state.copyWith(holdSeconds: sec));

      if (elapsed >= _holdNeed) {
        _holdTicker?.cancel();
        _holdTicker = null;

        _holdActive = false;
        _holdDone = true;

        d("HOLD completed after ${_holdNeed.inSeconds}s");
        d("HOLD values count=${holdValues.length}");
        d("HOLD values=$holdValues");

        _bleLog(
          "ble",
          "Hold completed",
          "duration=${_holdNeed.inSeconds}s valuesCount=${holdValues.length}",
        );

        final Map<String, String?> result = checkBreathStatus(holdValues);

        d("HOLD result => status=${result["status"]} direction=${result["direction"]}");
        _bleLog(
          "parse",
          "Hold fluctuation checked",
          "status=${result["status"]} direction=${result["direction"]}",
        );

        if (result["status"] == "ok") {
          final double finalHoldValue =
          holdValues.isNotEmpty ? holdValues.last : _base;

          d("HOLD PASS | finalHoldValue=$finalHoldValue");
          _bleLog("ble", "Hold passed", "finalHoldValue=$finalHoldValue");

          emit(state.copyWith(
            blowExhaleBaseValue: finalHoldValue,
            holdFinished: true,
          ));
        } else {
          if (result["direction"] == "exhaled") {
            d("HOLD FAIL | Exhale detected during hold");
            _bleLog("fail", "Exhale detected during hold", "base=$_base");
            emit(state.copyWith(
              holdBreathViolation: "Exhale detected during hold",
            ));
            unawaited(setCancelOrDisconnectFlag());
            _finishFail("Exhale detected during hold");
            return;
          }

          if (result["direction"] == "inhaled") {
            d("HOLD FAIL | Inhale detected during hold");
            _bleLog("fail", "Inhale detected during hold", "base=$_base");
            emit(state.copyWith(
              holdBreathViolation: "Inhale detected during hold",
            ));
            unawaited(setCancelOrDisconnectFlag());
            _finishFail("Inhale detected during hold");
            return;
          }

          d("HOLD FAIL | Unknown fluctuation");
          _bleLog("fail", "Unknown fluctuation during hold", "base=$_base");
          unawaited(setCancelOrDisconnectFlag());
          _finishFail("Breath fluctuation detected during hold");
        }
      }
    });
  }

  Map<String, String?> checkBreathStatus(
      List<double> values, {
        double tolerance = 1.5,
      }) {
    if (values.isEmpty) {
      return {
        "status": "not_ok",
        "direction": null,
      };
    }

    if (values.length < 3) {
      return {
        "status": "ok",
        "direction": null,
      };
    }

    final double baseValue = values.first;

    bool wentAbove = false;
    bool wentBelow = false;
    bool exhalePeakReached = false;
    bool inhaleValleyReached = false;

    for (int i = 1; i < values.length; i++) {
      final double currentValue = values[i];
      final double previousValue = values[i - 1];

      if (currentValue > baseValue + tolerance) {
        wentAbove = true;
      }

      if (currentValue < baseValue - tolerance) {
        wentBelow = true;
      }

      if (wentAbove) {
        if (currentValue < previousValue) {
          exhalePeakReached = true;
        }

        if (exhalePeakReached &&
            currentValue >= baseValue - tolerance &&
            currentValue <= baseValue + tolerance) {
          return {
            "status": "not_ok",
            "direction": "exhaled",
          };
        }
      }

      if (wentBelow) {
        if (currentValue > previousValue) {
          inhaleValleyReached = true;
        }

        if (inhaleValleyReached &&
            currentValue >= baseValue - tolerance &&
            currentValue <= baseValue + tolerance) {
          return {
            "status": "not_ok",
            "direction": "inhaled",
          };
        }
      }
    }

    return {
      "status": "ok",
      "direction": null,
    };
  }

  void _finishFail(String reason) {
    if (_disposed || _cancelled || state.inhaleFailed) return;

    d("FAIL finish | reason=$reason");
    _bleLog("fail", "Finish fail", reason);

    _flowStopped = true;
    _testStarted = false;

    _inhaleTimer?.cancel();
    _inhaleTimer = null;

    _holdTicker?.cancel();
    _holdTicker = null;
    _holdActive = false;
    _holdDone = false;

    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: false,
      inhaleFailed: true,
      inhaleFailReason: reason,
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _fixedInhaleDuration.inMilliseconds,
      inhaleNeedEndsAtEpochMs:
      state.inhaleNeedStartsAtEpochMs == 0 ? 0 : nowMs,
      holdStarted: false,
      holdFinished: false,
      progress: 0,
      progressSigned: 0,
    ));

    if (repo.isConnected) {
      _bleLog("ble_tx", "TX abort", "&");
      send("&");
    }
  }

  void _resetAllTracking() {
    _inhaleTimer?.cancel();
    _inhaleTimer = null;
    _inhaleStartAt = null;

    _holdTicker?.cancel();
    _holdTicker = null;

    _holdActive = false;
    _holdDone = false;
    _holdStartAt = null;

    _packetCount = 0;
    holdValues = [];
    holdSkipCounter = 0;

    d("Tracking reset | holdValues cleared | holdSkipCounter reset");
  }

  void send(String command) {
    if (_disposed || _cancelled) return;
    try {
      d("TX command=$command");
      _bleLog("ble_tx", "TX", command);
      repo.sendData(command);
    } catch (e) {
      d("TX error=$e");
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> cancelTest() async {
    if (_canSaveAbortTime) {
      await setCancelOrDisconnectFlag();
    }

    if (repo.isConnected) {
      try {
        if (!state.inhaleFailed) {
          repo.sendData("&");
        }
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    if (_disposed) return;
    if (_cancelled) return;

    _cancelled = true;
    _flowStopped = true;
    _testStarted = false;

    d("CANCEL TEST called | canSaveTime=$_canSaveAbortTime");
    _bleLog("ui", "Cancel test", "canSaveTime=$_canSaveAbortTime");

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _inhaleTimer?.cancel();
    _inhaleTimer = null;

    _holdTicker?.cancel();
    _holdTicker = null;
    _holdActive = false;
    _holdDone = false;

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: false,
      inhaleFailed: true,
      inhaleFailReason: "Aborted by user.",
      navigateToDashboard: true,
      progress: 0,
      progressSigned: 0,
    ));
  }



  Future<void> sendAbort() async {
    if (_disposed) return;

    if (_canSaveAbortTime) {
      await setCancelOrDisconnectFlag();
    }

    try {
      if (repo.isConnected) {
        d("SEND '&' (abort)");
        _bleLog("ble_tx", "TX abort", "&");
        repo.sendData("&");
      }
    } catch (e) {
      d("Abort send error=$e");
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> setCancelOrDisconnectFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cancel_or_disconnect_time',
      DateTime.now().toIso8601String(),
    );
    d("Saved cancel_or_disconnect_time");
  }

  @override
  Future<void> close() {
    _disposed = true;

    d("Cubit close called");
    _bleLog("ui", "Cubit close");

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _inhaleTimer?.cancel();
    _holdTicker?.cancel();

    _connSub?.cancel();
    _dataSub?.cancel();

    return super.close();
  }
}