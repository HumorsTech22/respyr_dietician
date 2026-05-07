import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/ble_logging/ble_logger_http.dart';
import 'package:respyr_dietitian/common/widgets/threshold.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bluetooth_inhale_new_state.dart';

class BluetoothInhaleCubitNew extends Cubit<BluetoothInhaleCubitNewState> {
  final BluetoothRepository repo;
  final BreathingSettings breathingSettings;

  static const bool kDebug = true;
  void d(String msg) {
    if (kDebug) {
      print("[INHALE_CUBIT] $msg");
    }
  }

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  Timer? _finishTimer;
  Timer? _secondTimer;

  bool _disposed = false;
  bool _startSent = false;
  bool _testStarted = false;

  bool _cancelled = false;
  bool _flowStopped = false;

  bool _baseCaptured = false;
  double _base = 0;

  int holdSkipCounter = 0;
  List<double> holdValues = [];

  bool _armed = false;
  static const double _armAt = 10.0;

  double get _minBand => breathingSettings.inhale.minBand.toDouble();
  double get _maxBand => breathingSettings.inhale.maxBand.toDouble();

  Duration get _inhaleNeed =>
      Duration(milliseconds: breathingSettings.inhale.timeMs);

  Duration get _inhaleAccept {
    final need = _inhaleNeed;
    if (need <= const Duration(milliseconds: 500)) return need;
    return need - const Duration(milliseconds: 500);
  }

  static const Duration _failOutOfBand = Duration(seconds: 2);

  bool _everReachedBand = false;

  Timer? _inhaleNeedTicker;
  Duration _inhaleNeedAccumulated = Duration.zero;
  DateTime? _inhaleNeedLastTickAt;

  Timer? _outOfBandTimer;

  static const double _dropToZeroThreshold = 1.0;
  bool _dropFailTriggered = false;

  Duration get _holdNeed {
    final int ms = breathingSettings.hold.timeMs;
    if (ms <= 0) return const Duration(seconds: 8);
    return Duration(milliseconds: ms);
  }

  bool _holdActive = false;
  bool _holdDone = false;
  Timer? _holdTicker;
  DateTime? _holdStartAt;

  static const Duration _holdStartCheckingAfter = Duration(seconds: 1);
  static const double _holdRawTolerance = 3.0;

  int _packetCount = 0;

  Timer? _exhaleTimer;
  bool _exhaleTimerRunning = false;

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
      screen: "inhale",
      direction: direction,
      eventType: type,
      message: msg,
      payloadText: _cap(payload ?? "", 240),
    );
  }

  String _cap(String s, int n) => (s.length <= n) ? s : s.substring(0, n);

  BluetoothInhaleCubitNew(this.repo, this.breathingSettings)
      : super(const BluetoothInhaleCubitNewState()) {
    d("Cubit init | connected=${repo.isConnected}");
    _bleLog("ui", "Cubit initialized", "connected=${repo.isConnected}");
    _listen();
    emit(state.copyWith(isConnected: repo.isConnected));
    startCounter(from: 5);
  }

  bool get _canSaveAbortTime =>
      state.holdStarted || _holdActive || state.holdFinished;

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

        if (flowRunning && !state.inhaleFailed && !state.inhaleFinished) {
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
      if (state.inhaleFinished && !_holdActive) return;

      final clean = data.trim();
      emit(state.copyWith(receivedData: clean, error: null));

      bool isSlash = clean.contains('/');
      bool isCurly = clean.contains('{') || clean.contains('}');

      if (!isSlash && !isCurly) return;

      String numberString = clean.replaceAll(RegExp(r'[^0-9.]'), '');

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

      final inhaleValue = parsedValue;

      _packetCount++;
      if (_packetCount <= 8 || _packetCount % 25 == 0) {
        d(
          "Packet #$_packetCount | raw={$inhaleValue} | base=$_base | hold=$_holdActive done=$_holdDone inhaleFinished=${state.inhaleFinished}",
        );
        _bleLog(
          "ble_rx",
          "Packet received",
          "packet=$_packetCount raw=$inhaleValue base=$_base",
        );
      }

      if (_holdDone) return;

      if (_holdActive) {
        if (holdSkipCounter <= 10) {
          holdSkipCounter++;
          d("HOLD skip packet | holdSkipCounter=$holdSkipCounter raw=$inhaleValue");
          _bleLog(
            "ble_rx",
            "Hold skip packet",
            "skipCounter=$holdSkipCounter raw=$inhaleValue",
          );
          return;
        }

        holdValues.add(inhaleValue);

        final delta = inhaleValue - _base;

        d(
          "HOLD packet | raw=$inhaleValue | base=$_base | delta=${delta.toStringAsFixed(3)} | count=${holdValues.length}",
        );

        _bleLog(
          "ble_rx",
          "Hold packet received",
          "raw=$inhaleValue base=$_base delta=${delta.toStringAsFixed(3)} count=${holdValues.length}",
        );

        emit(state.copyWith(
          progressSigned: delta,
          progress: delta.abs(),
        ));

        final holdStart = _holdStartAt;
        if (holdStart == null) {
          d("HOLD start time is null");
          _bleLog("error", "Hold start time null");
          return;
        }

        final elapsedHold = DateTime.now().difference(holdStart);
        d("HOLD elapsed=${elapsedHold.inMilliseconds}ms");

        if (elapsedHold < _holdStartCheckingAfter) {
          d(
            "HOLD waiting before checking | threshold=${_holdStartCheckingAfter.inMilliseconds}ms",
          );
          return;
        }

        return;
      }

      if (inhaleValue > _base + 1.5) {
        d("FAIL: Exhale detected during inhale | raw=$inhaleValue base=$_base");
        _bleLog(
          "fail",
          "Exhale detected instead of inhale",
          "raw=$inhaleValue base=$_base",
        );
        unawaited(setCancelOrDisconnectFlag());
        _finishFail("Exhale detected instead of inhale");
        return;
      }

      _cancelExhaleFailTimer();

      final signed = Thresholds.calculateInhalePercentage(
        _base,
        inhaleValue,
        breathingSettings.inhale.threshold.toDouble(),
      );
      final inhaleProgress = signed < 0 ? (-signed) : 0.0;
      final bool startedNow = inhaleProgress >= _armAt;

      emit(state.copyWith(
        progressSigned: signed,
        progress: startedNow ? inhaleProgress : 0,
        inhaleStarted: startedNow ? true : state.inhaleStarted,
        inhaleFinished: state.inhaleFinished,
      ));

      if (!_armed && startedNow) {
        _armed = true;
        d("Inhale armed at ${inhaleProgress.toStringAsFixed(2)}");
        _bleLog("ble", "Inhale armed", inhaleProgress.toStringAsFixed(2));
      }

      if (_armed &&
          !_dropFailTriggered &&
          inhaleProgress <= _dropToZeroThreshold) {
        _dropFailTriggered = true;
        d("FAIL: dropped near zero");
        _bleLog(
          "fail",
          "Inhale dropped near 0",
          inhaleProgress.toStringAsFixed(2),
        );
        _finishFail("Inhale dropped to 0");
        return;
      }

      if (_armed && !state.inhaleFinished) {
        _applyBandRules(inhaleProgress);
      }
    });
  }

  void _startExhaleFailTimerIfNeeded() {
    if (_exhaleTimerRunning) return;
    _exhaleTimerRunning = true;

    _exhaleTimer?.cancel();
    _exhaleTimer = Timer(const Duration(milliseconds: 700), () {
      _exhaleTimerRunning = false;
      if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) {
        return;
      }
      _finishFail("Exhale detected instead of inhale");
    });
  }

  void _cancelExhaleFailTimer() {
    _exhaleTimer?.cancel();
    _exhaleTimer = null;
    _exhaleTimerRunning = false;
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

    final totalMs = from * 1000;
    final now = DateTime.now().millisecondsSinceEpoch;
    final endsAt = now + totalMs;

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
      inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
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
      final remainingMs = endsAt - DateTime.now().millisecondsSinceEpoch;
      final remainingSec = (remainingMs / 1000).ceil().clamp(0, from);
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
  }

  void _applyBandRules(double progressAbs) {
    if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) {
      return;
    }

    final inBand = (progressAbs >= _minBand && progressAbs <= _maxBand);

    if (inBand && !_everReachedBand) {
      _everReachedBand = true;

      final nowMs = DateTime.now().millisecondsSinceEpoch;
      emit(state.copyWith(
        inhaleNeedRunning: true,
        inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
        inhaleNeedStartsAtEpochMs: nowMs,
        inhaleNeedEndsAtEpochMs: 0,
      ));

      _startInhaleNeedTickerIfNeeded();
    }

    if (!_everReachedBand) return;

    if (inBand) {
      _cancelOutOfBandFailTimer();
    } else {
      _startOutOfBandFailTimerIfNeeded("Out of range for 2 seconds");
    }
  }

  void _startInhaleNeedTickerIfNeeded() {
    if (_inhaleNeedTicker != null) return;

    _inhaleNeedLastTickAt = DateTime.now();

    if (!state.inhaleNeedRunning) {
      emit(state.copyWith(inhaleNeedRunning: true));
    }

    _inhaleNeedTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) {
        return;
      }

      final now = DateTime.now();
      final last = _inhaleNeedLastTickAt ?? now;
      _inhaleNeedLastTickAt = now;

      _inhaleNeedAccumulated += now.difference(last);

      final seconds = (_inhaleNeedAccumulated.inMilliseconds / 1000.0)
          .clamp(0.0, _inhaleNeed.inMilliseconds / 1000.0);

      emit(state.copyWith(inBandSeconds: seconds));

      if (_inhaleNeedAccumulated >= _inhaleAccept) {
        _finishInhaleSuccessStartHold();
      }
    });
  }

  void _pauseInhaleNeedTicker({required bool setRunningFalse}) {
    _inhaleNeedTicker?.cancel();
    _inhaleNeedTicker = null;
    _inhaleNeedLastTickAt = null;

    if (setRunningFalse && state.inhaleNeedRunning) {
      emit(state.copyWith(inhaleNeedRunning: false));
    }
  }

  void _startOutOfBandFailTimerIfNeeded(String reason) {
    if (_outOfBandTimer != null) return;
    _outOfBandTimer = Timer(_failOutOfBand, () {
      if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) {
        return;
      }
      _finishFail(reason);
    });
  }

  void _cancelOutOfBandFailTimer() {
    _outOfBandTimer?.cancel();
    _outOfBandTimer = null;
  }

  void _finishInhaleSuccessStartHold() {
    if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) {
      return;
    }

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: true,
      inhaleFailed: false,
      inhaleFailReason: "",
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
      inhaleNeedEndsAtEpochMs: nowMs,
      holdStarted: true,
      holdFinished: false,
      holdSeconds: 0,
    ));

    _bleLog("ble_tx", "SEND '2' (start hold)", "2");
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

      final start = _holdStartAt;
      if (start == null) return;

      final elapsed = DateTime.now().difference(start);
      final sec = (elapsed.inMilliseconds / 1000.0)
          .clamp(0.0, _holdNeed.inMilliseconds / 1000.0);

      emit(state.copyWith(holdSeconds: sec));

      if ((elapsed.inMilliseconds % 1000) < 120) {
        d("HOLD ticking | elapsed=${sec.toStringAsFixed(1)}s | values=${holdValues.length}");
      }

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
          "duration=${_holdNeed.inSeconds}s holdValues=${holdValues}",
        );

        _bleLog(
          "ble",
          "Hold completed",
          "duration=${_holdNeed.inSeconds}s valuesCount=${holdValues.length}",
        );

        final result = checkBreathStatus(
          holdValues,
        );

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
    d("checkBreathStatus called");
    d("Input values count=${values.length}");
    d("Input values=$values");
    d("tolerance=$tolerance");

    if (values.isEmpty) {
      d("checkBreathStatus => values empty => not_ok");
      return {
        "status": "not_ok",
        "direction": null,
      };
    }

    if (values.length < 3) {
      d("checkBreathStatus => too few values => ok");
      return {
        "status": "ok",
        "direction": null,
      };
    }

    final double baseValue = values.first;
    d("Base value=$baseValue");

    bool wentAbove = false;
    bool wentBelow = false;
    bool exhalePeakReached = false;
    bool inhaleValleyReached = false;

    double maxValue = baseValue;
    double minValue = baseValue;

    for (int i = 1; i < values.length; i++) {
      final double currentValue = values[i];
      final double previousValue = values[i - 1];

      if (currentValue > maxValue) maxValue = currentValue;
      if (currentValue < minValue) minValue = currentValue;

      d(
        "index=$i | previous=$previousValue | current=$currentValue | maxValue=$maxValue | minValue=$minValue",
      );

      if (currentValue > baseValue + tolerance) {
        wentAbove = true;
        d("Value moved above base+tolerance");
      }

      if (currentValue < baseValue - tolerance) {
        wentBelow = true;
        d("Value moved below base-tolerance");
      }

      if (wentAbove) {
        if (currentValue < previousValue) {
          exhalePeakReached = true;
          d("Exhale peak reached, value started coming down");
        }

        if (exhalePeakReached &&
            currentValue >= baseValue - tolerance &&
            currentValue <= baseValue + tolerance) {
          d("checkBreathStatus => not_ok | direction=exhaled");
          return {
            "status": "not_ok",
            "direction": "exhaled",
          };
        }
      }

      if (wentBelow) {
        if (currentValue > previousValue) {
          inhaleValleyReached = true;
          d("Inhale valley reached, value started coming up");
        }

        if (inhaleValleyReached &&
            currentValue >= baseValue - tolerance &&
            currentValue <= baseValue + tolerance) {
          d("checkBreathStatus => not_ok | direction=inhaled");
          return {
            "status": "not_ok",
            "direction": "inhaled",
          };
        }
      }
    }

    d("checkBreathStatus => ok");
    return {
      "status": "ok",
      "direction": null,
    };
  }



  String getBreathState(
      double value,
      double baseValue, {
        double allowedFluctuation = 3.0,
      }) {
    final diff = value - baseValue;

    if (diff < -allowedFluctuation) return "inhale";
    if (diff > allowedFluctuation) return "exhale";
    return "stable";
  }

  void _finishFail(String reason) {
    if (_disposed || _cancelled || state.inhaleFailed) return;

    d("FAIL finish | reason=$reason");
    _bleLog("fail", "Finish fail", reason);

    _flowStopped = true;
    _testStarted = false;

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

    _holdTicker?.cancel();
    _holdTicker = null;
    _holdActive = false;
    _holdDone = false;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: false,
      inhaleFailed: true,
      inhaleFailReason: reason,
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
      inhaleNeedEndsAtEpochMs:
      (state.inhaleNeedStartsAtEpochMs == 0) ? 0 : nowMs,
      holdStarted: false,
      holdFinished: false,
    ));

    if (repo.isConnected) {
      _bleLog("ble_tx", "TX abort", "&");
      send("&");
    }
  }

  void _resetAllTracking() {
    _armed = false;
    _everReachedBand = false;

    _inhaleNeedAccumulated = Duration.zero;
    _inhaleNeedLastTickAt = null;

    _dropFailTriggered = false;

    _pauseInhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

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
        if (!state.inhaleFailed) repo.sendData("&");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    } else {
      d("CANCEL: skip '&' (not connected)");
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

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

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

    _pauseInhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

    _holdTicker?.cancel();

    _connSub?.cancel();
    _dataSub?.cancel();
    return super.close();
  }
}