import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../common/widgets/threshold.dart';
import 'bluetooth_inhale_new_state.dart';

class BluetoothInhaleCubitNew extends Cubit<BluetoothInhaleCubitNewState> {
  final BluetoothRepository repo;

  static const bool kDebug = true;
  void d(String msg) {
    if (kDebug) {
      // ignore: avoid_print
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

  // ✅ Cancel guards
  bool _cancelled = false;

  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');
  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');

  bool _baseCaptured = false;
  double _base = 0;

  bool _armed = false;
  static const double _armAt = 10.0;

  static const double _minBand = 20.0;
  static const double _maxBand = 80.0;

  static const Duration _inhaleNeed = Duration(milliseconds: 2500);
  static const Duration _failOutOfBand = Duration(seconds: 2);

  bool _everReachedBand = false;

  Timer? _inhaleNeedTicker;
  Duration _inhaleNeedAccumulated = Duration.zero;
  DateTime? _inhaleNeedLastTickAt;

  Timer? _outOfBandTimer;

  static const double _dropToZeroThreshold = 1.0;
  bool _dropFailTriggered = false;

  // HOLD
  static const Duration _holdNeed = Duration(seconds: 8);
  static const Duration _holdSettle = Duration(seconds: 2);
  static const double _holdTolerance = 10.0;

  bool _holdActive = false;
  bool _holdDone = false;
  Timer? _holdTicker;
  DateTime? _holdStartAt;

  int _holdSettleUntilMs = 0;
  double? _holdBaselineSigned;

  int _holdIgnoreSamplesRemaining = 0;
  static const int _holdIgnoreCount = 5;
  static const double _holdIgnoreIfAbsAbove = 10.0;

  int _packetCount = 0;

  // inhale-only: exhale continuous >= 2 sec => FAIL
  Timer? _exhaleTimer;
  bool _exhaleTimerRunning = false;

  // HOLD BREATH CHECK
  static const double _holdBaseTolerance = 2.0; // base ± 2
  static const Duration _holdStartCheckingAfter = Duration(seconds: 1);
  bool _holdCheckEnabled = false;

  BluetoothInhaleCubitNew(this.repo) : super(const BluetoothInhaleCubitNewState()) {
    d("Cubit init | connected=${repo.isConnected}");
    _listen();
    emit(state.copyWith(isConnected: repo.isConnected));
    startCounter(from: 5);
  }

  // ✅ Save time ONLY after hold started
  bool get _canSaveAbortTime =>
      state.holdStarted || _holdActive || state.holdFinished;

  void _listen() {
    _connSub = repo.connectionStatusStream().listen((connected) async {
      if (_disposed) return;

      d("Connection status changed -> $connected");
      emit(state.copyWith(isConnected: connected, error: null));

      if (!connected) {
        final bool flowRunning =
            _testStarted ||
                state.startCounterStarted ||
                state.startCounterFinished ||
                state.inhaleStarted ||
                _holdActive ||
                state.holdStarted;

        if (flowRunning && !state.inhaleFailed && !state.inhaleFinished) {
          d("DISCONNECT during test");

          // ✅ NEW RULE: save time ONLY if hold started
          if (_canSaveAbortTime) {
            await setCancelOrDisconnectFlag();
          }

          _finishFail("Device disconnected. Please reconnect and try again.");
        }
      }
    });

    _dataSub = repo.receivedDataStream().listen((data) {
      if (_disposed || _cancelled || data.isEmpty || !_testStarted) return;
      if (!repo.isConnected) return;

      final clean = data.trim();
      emit(state.copyWith(receivedData: clean, error: null));

      final slashMatch = _slashNum.firstMatch(clean);
      final curlyMatch = _curlyNum.firstMatch(clean);

      // capture base: /xxx/
      if (!_baseCaptured && slashMatch != null) {
        _base = double.parse(slashMatch.group(1)!);
        _baseCaptured = true;

        d("Base captured: /$_base/");

        emit(state.copyWith(
          baseValueReceived: true,
          blowExhaleBaseValue: _base,
        ));
        return;
      }

      if (!_baseCaptured || curlyMatch == null) return;

      final inhaleValue = double.parse(curlyMatch.group(1)!);

      _packetCount++;
      if (_packetCount <= 8 || _packetCount % 25 == 0) {
        d("Packet #$_packetCount | raw={$inhaleValue} | base=$_base | hold=$_holdActive done=$_holdDone");
      }

      if (_holdDone) return;

      // =========================
      // HOLD STAGE
      // =========================
      if (_holdActive) {
        final signed = Thresholds.calculateInhalePercentage(_base, inhaleValue);
        final absVal = signed.abs();

        emit(state.copyWith(progressSigned: signed, progress: absVal));

        final nowMs = DateTime.now().millisecondsSinceEpoch;

        // settle first 2 sec
        if (nowMs < _holdSettleUntilMs) return;

        // enable breath check after 1 sec of hold elapsed
        final holdStart = _holdStartAt;
        if (holdStart != null && !_holdCheckEnabled) {
          final elapsedHold = DateTime.now().difference(holdStart);
          if (elapsedHold >= _holdStartCheckingAfter) {
            _holdCheckEnabled = true;
            d("HOLD: breath check ENABLED");
          }
        }

        // detect inhale/exhale in hold using base±2
        if (_holdCheckEnabled) {
          final upper = _base + _holdBaseTolerance;
          final lower = _base - _holdBaseTolerance;

          if (inhaleValue > upper) {
            d("HOLD VIOLATION: EXHALED");
            emit(state.copyWith(holdBreathViolation: "Exhaled in hold phase"));
            _finishFail("Exhaled in hold phase");
            return;
          }

          if (inhaleValue < lower) {
            d("HOLD VIOLATION: INHALED");
            emit(state.copyWith(holdBreathViolation: "Inhaled in hold phase"));
            _finishFail("Inhaled in hold phase");
            return;
          }
        }

        // ignore samples logic
        if (_holdIgnoreSamplesRemaining == 0 && absVal > _holdIgnoreIfAbsAbove) {
          _holdIgnoreSamplesRemaining = _holdIgnoreCount;
          d("HOLD: ignoring next $_holdIgnoreCount samples");
        }

        if (_holdIgnoreSamplesRemaining > 0) {
          _holdIgnoreSamplesRemaining--;
          return;
        }

        _holdBaselineSigned ??= signed;

        final dev = (signed - (_holdBaselineSigned ?? 0)).abs();
        if (dev > _holdTolerance) {
          d("HOLD FAIL: dev=$dev > tol=$_holdTolerance");
          _finishFail("Do not inhale/blow during hold");
        }
        return;
      }

      // =========================
      // INHALE STAGE
      // =========================
      if (inhaleValue > (_base + 3)) {
        _finishFail("Exhale detected during inhale");
        return;
      } else {
        _cancelExhaleFailTimer();
      }

      final signed = Thresholds.calculateInhalePercentage(_base, inhaleValue);
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
      }

      if (_armed && !_dropFailTriggered && inhaleProgress <= _dropToZeroThreshold) {
        _dropFailTriggered = true;
        d("FAIL: dropped near zero");
        _finishFail("Inhale dropped to 0");
        return;
      }

      if (_armed && !state.inhaleFinished) {
        _applyBandRules(inhaleProgress);
      }
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
    if (_disposed || _cancelled || _startSent || !repo.isConnected) return;
    _startSent = true;
    d("SEND '1' start");
    send("1");
    _testStarted = true;
  }

  void _applyBandRules(double progressAbs) {
    if (_disposed || _cancelled || state.inhaleFinished) return;

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
      if (_disposed || _cancelled || state.inhaleFinished) return;

      final now = DateTime.now();
      final last = _inhaleNeedLastTickAt ?? now;
      _inhaleNeedLastTickAt = now;

      _inhaleNeedAccumulated += now.difference(last);

      final seconds = (_inhaleNeedAccumulated.inMilliseconds / 1000.0)
          .clamp(0.0, _inhaleNeed.inMilliseconds / 1000.0);

      emit(state.copyWith(inBandSeconds: seconds));

      if (_inhaleNeedAccumulated >= _inhaleNeed) {
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
      if (_disposed || _cancelled || state.inhaleFinished) return;
      _finishFail(reason);
    });
  }

  void _cancelOutOfBandFailTimer() {
    _outOfBandTimer?.cancel();
    _outOfBandTimer = null;
  }

  void _finishInhaleSuccessStartHold() {
    if (_disposed || _cancelled || state.inhaleFinished) return;

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

    send("2");
    _startHoldTicker();
  }

  void _startHoldTicker() {
    _holdActive = true;
    _holdDone = false;
    _holdCheckEnabled = false;

    _holdStartAt = DateTime.now();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    _holdSettleUntilMs = nowMs + _holdSettle.inMilliseconds;

    _holdBaselineSigned = null;
    _holdIgnoreSamplesRemaining = 0;

    _holdTicker?.cancel();
    _holdTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _cancelled) return;

      final start = _holdStartAt;
      if (start == null) return;

      final elapsed = DateTime.now().difference(start);
      final sec = (elapsed.inMilliseconds / 1000.0)
          .clamp(0.0, _holdNeed.inMilliseconds / 1000.0);

      emit(state.copyWith(holdSeconds: sec));

      if (elapsed >= _holdNeed) {
        _holdTicker?.cancel();
        _holdTicker = null;

        _holdActive = false;
        _holdDone = true;

        emit(state.copyWith(holdFinished: true));
      }
    });
  }

  void _finishFail(String reason) {
    if (_disposed || _cancelled || state.inhaleFailed) return;

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
      inhaleNeedEndsAtEpochMs: (state.inhaleNeedStartsAtEpochMs == 0) ? 0 : nowMs,
      holdStarted: false,
      holdFinished: false,
    ));

    // ✅ Fail: send abort only if connected (unchanged)
    if (repo.isConnected) {
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

    _holdSettleUntilMs = 0;
    _holdBaselineSigned = null;

    _holdIgnoreSamplesRemaining = 0;
    _packetCount = 0;

    _holdCheckEnabled = false;
  }

  void send(String command) {
    if (_disposed || _cancelled) return;
    try {
      repo.sendData(command);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// ✅ CancelTest rule:
  /// - If hold NOT started → DO NOT save time
  /// - If hold started → save time
  /// - Send "&" only if connected
  /// - Navigate to dashboard always
  Future<void> cancelTest() async {
    if (_disposed) return;
    if (_cancelled) return;

    _cancelled = true;
    d("CANCEL TEST called | canSaveTime=$_canSaveAbortTime");

    // stop timers
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

    _testStarted = false;

    // ✅ SAVE TIME ONLY AFTER HOLD STARTED
    if (_canSaveAbortTime) {
      await setCancelOrDisconnectFlag();
    }

    // ✅ send abort only if connected
    if (repo.isConnected) {
      try {
        d("CANCEL: SEND '&'");
        repo.sendData("&");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    } else {
      d("CANCEL: skip '&' (not connected)");
    }

    // ✅ navigate
    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: false,
      inhaleFailed: true,
      inhaleFailReason: "Aborted by user.",
      navigateToDashboard: true,
    ));
  }

  // (kept) - used elsewhere if you call manually
  Future<void> sendAbort() async {
    if (_disposed) return;

    // ✅ NEW: follow rule here too
    if (_canSaveAbortTime) {
      await setCancelOrDisconnectFlag();
    }

    try {
      if (repo.isConnected) {
        d("SEND '&' (abort)");
        repo.sendData("&");
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> setCancelOrDisconnectFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cancel_or_disconnect_time',
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> close() {
    _disposed = true;

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
