import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/processor/bluetooth_blow_processor.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/common/widgets/threshold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bluetooth_exhale_state.dart';

class BluetoothExhaleCubit extends Cubit<BluetoothExhaleState> {
  final BluetoothBlowProcessor processor;
  final BluetoothRepository repo;
  final String baseValue;

  static const bool kDebug = true;
  void d(String msg) {
    if (kDebug) {
      // ignore: avoid_print
      print("[EXHALE_CUBIT] $msg");
    }
  }

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  bool _disposed = false;
  bool _startSent = false;
  bool _exhaleSucceeded = false;

  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');
  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');

  static const double _minRange = 40.0;
  static const double _maxRange = 80.0;

  static const int _holdTotalMs = 3000;
  static const int _holdAcceptMs = 2000;

  static const double _stopProgressThreshold = 0.0;
  static const double _inhaleDrop = 3.0;

  static const int _startTimeoutSec = 30;

  static const double _exhaleDetectDelta = 2.0;

  Timer? _holdTicker;
  DateTime? _lastHoldTickAt;

  int _holdRemainingMs = _holdTotalMs;
  int _inRangeAccumMs = 0;

  final List<double> _blowValues = [];

  bool _finalized = false;
  bool _timeSaved = false;
  bool _failed = false;

  // ✅ ensure '&' abort is sent only once
  bool _abortSent = false;

  // ✅ NEW: timeout timers
  Timer? _startTimeoutTicker;
  Timer? _startTimeoutTimer;
  bool _exhaleDetected = false; // becomes true when blowVal > base + 2

  double get _baseDouble {
    final normal = double.tryParse(baseValue.trim());
    if (normal != null) return normal;

    final m = _slashNum.firstMatch(baseValue.trim());
    if (m != null) return double.tryParse(m.group(1)!) ?? 0.0;

    return 0.0;
  }

  BluetoothExhaleCubit({
    required this.processor,
    required this.repo,
    required this.baseValue,
  }) : super(const BluetoothExhaleState()) {
    _init();
  }

  void _init() {
    processor.reset();
    processor.processBlowData(
      baseValue,
          (val) => Thresholds.calculateThresholdPercentage(val),
          (baseVal, blowVal) => Thresholds.calculateBlowPercentage1(baseVal, blowVal),
    );

    _holdRemainingMs = _holdTotalMs;
    _inRangeAccumMs = 0;
    _blowValues.clear();

    _disposed = false;
    _finalized = false;
    _timeSaved = false;
    _exhaleSucceeded = false;
    _startSent = false;
    _failed = false;
    _abortSent = false;

    _cancelStartTimeoutTimers();
    _exhaleDetected = false;

    emit(state.copyWith(
      isConnected: repo.isConnected,
      progress: 0,
      holdSecondsLeft: (_holdRemainingMs / 1000).ceil().clamp(1, 4),
      exhaleStarted: false,
      inRange: false,
      exhaleSuccess: false,
      exhaleFailed: false,
      analysisReady: false,
      blowValues: const [],
      inRangeDurationMs: 0,
      navigateToDashboard: false,
      cancelTest: false,
      error: null,

      // ✅ new fields
      startTimeoutRunning: false,
      startTimeoutLeftSec: _startTimeoutSec,
    ));

    _connSub = repo.connectionStatusStream().listen((connected) {
      if (_disposed) return;

      emit(state.copyWith(isConnected: connected));

      if (!connected) {
        _pauseHoldCountdown();
        _cancelStartTimeoutTimers();
        emit(state.copyWith(error: "Device disconnected. Please reconnect."));
        return;
      }

      _sendStartExhaleOnce();
    });

    _dataSub = repo.receivedDataStream().listen(_onData);

    _sendStartExhaleOnce();
  }

  void _sendStartExhaleOnce() {
    if (_disposed || _startSent || _finalized) return;

    if (!repo.isConnected) {
      d("cannot send 3, not connected");
      return;
    }

    try {
      d("SEND '3'");
      repo.sendData("3");
      _startSent = true;

      // ✅ start 30 sec timer after sending '3'
      _startStartTimeoutTimers();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _startStartTimeoutTimers() {
    _cancelStartTimeoutTimers();

    emit(state.copyWith(
      startTimeoutRunning: true,
      startTimeoutLeftSec: _startTimeoutSec,
    ));

    // tick down for UI
    int left = _startTimeoutSec;
    _startTimeoutTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || _finalized || _failed) return;
      if (_exhaleDetected || state.exhaleStarted || state.exhaleSuccess || state.exhaleFailed) return;

      left = (left - 1).clamp(0, _startTimeoutSec);
      emit(state.copyWith(startTimeoutLeftSec: left));

      if (left <= 0) {
        _startTimeoutTicker?.cancel();
        _startTimeoutTicker = null;
      }
    });

    // hard timeout
    _startTimeoutTimer = Timer(const Duration(seconds: _startTimeoutSec), () {
      if (_disposed || _finalized || _failed) return;
      if (_exhaleDetected || state.exhaleStarted || state.exhaleSuccess || state.exhaleFailed) return;

      _failed = true;
      _fail(reason: "Timeout: No exhale detected within $_startTimeoutSec seconds.");
    });
  }

  void _cancelStartTimeoutTimers() {
    _startTimeoutTicker?.cancel();
    _startTimeoutTicker = null;

    _startTimeoutTimer?.cancel();
    _startTimeoutTimer = null;

    // keep state clean
    if (state.startTimeoutRunning) {
      emit(state.copyWith(
        startTimeoutRunning: false,
        startTimeoutLeftSec: _startTimeoutSec,
      ));
    }
  }

  void _sendAbortOnce({required String why}) {
    if (_abortSent) {
      d("Skip '&' (already sent) | $why");
      return;
    }
    _abortSent = true;

    if (!repo.isConnected) {
      d("Skip '&' (not connected) | $why");
      return;
    }

    try {
      d("SEND '&' | $why");
      repo.sendData("&");
    } catch (_) {
      d("Error sending '&' | $why");
    }
  }

  void _onData(String data) {
    if (_disposed || _finalized || data.isEmpty) return;
    if (_failed) return;

    final clean = data.trim();
    emit(state.copyWith(receivedData: clean, error: null));

    if (_exhaleSucceeded) {
      if (clean.toLowerCase() == "analize") {
        emit(state.copyWith(analysisReady: true));
      }
      return;
    }

    final m = _curlyNum.firstMatch(clean);
    if (m == null) return;

    final blowVal = double.tryParse(m.group(1) ?? "");
    if (blowVal == null) return;

    final base = _baseDouble;

    // ✅ exhale detection for timeout cancel: blowVal > base + 2
    if (!_exhaleDetected && blowVal > (base + _exhaleDetectDelta)) {
      _exhaleDetected = true;
      d("Exhale detected (raw): $blowVal > ${base + _exhaleDetectDelta}");
      _cancelStartTimeoutTimers();
    }

    // ✅ FAIL #1: inhale detected (anytime)
    if (blowVal < (base - _inhaleDrop)) {
      _failed = true;
      _fail(reason: "Oops! You inhaled instead of exhaling.");
      return;
    }

    // ✅ NO LIMIT: store all values
    _blowValues.add(blowVal);
    emit(state.copyWith(blowValues: List<double>.unmodifiable(_blowValues)));

    double progress = 0;
    if (blowVal > base) {
      progress = Thresholds.calculateBlowPercentage1(base, blowVal);
    }

    _handleProgress(progress);
  }

  void _handleProgress(double progress) {
    if (_disposed || _finalized) return;
    if (_failed) return;
    if (state.exhaleFailed || state.exhaleSuccess) return;

    final nowInRange = (progress >= _minRange && progress <= _maxRange);

    emit(state.copyWith(
      progress: progress,
      inRange: nowInRange,
      inRangeDurationMs: _inRangeAccumMs,
    ));

    if (!state.exhaleStarted && nowInRange) {
      emit(state.copyWith(exhaleStarted: true));
      _cancelStartTimeoutTimers(); // ✅ also cancel when flow starts
      _resumeHoldCountdown();
      return;
    }

    // ✅ FAIL #2: after exhale started, progress drops to 0
    if (state.exhaleStarted && progress <= _stopProgressThreshold) {
      _failed = true;
      _fail(reason: "Exhale failed: you stopped exhaling.");
      return;
    }

    if (!state.exhaleStarted) return;

    if (nowInRange) {
      _resumeHoldCountdown();
    } else {
      _pauseHoldCountdown();
    }
  }

  void _resumeHoldCountdown() {
    if (_inRangeAccumMs >= _holdAcceptMs) return;
    if (_holdTicker != null) return;

    _lastHoldTickAt = DateTime.now();

    _holdTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _finalized) return;
      if (_failed) return;
      if (state.exhaleFailed || state.exhaleSuccess) return;

      _lastHoldTickAt ??= DateTime.now();
      final now = DateTime.now();
      final dt = now.difference(_lastHoldTickAt!).inMilliseconds;
      _lastHoldTickAt = now;

      _inRangeAccumMs += dt;

      _holdRemainingMs -= dt;
      if (_holdRemainingMs < 0) _holdRemainingMs = 0;

      final secondsLeft = (_holdRemainingMs / 1000).ceil().clamp(1, 4);

      emit(state.copyWith(
        holdSecondsLeft: secondsLeft,
        inRangeDurationMs: _inRangeAccumMs,
      ));

      // ✅ ACCEPT if held >= 2.5 sec
      if (_inRangeAccumMs >= _holdAcceptMs) {
        _holdTicker?.cancel();
        _holdTicker = null;
        _holdRemainingMs = 0;
        _markSuccess();
        return;
      }

      if (_holdRemainingMs <= 0) {
        _holdTicker?.cancel();
        _holdTicker = null;
        _markSuccess();
      }
    });
  }

  void _pauseHoldCountdown() {
    _holdTicker?.cancel();
    _holdTicker = null;
    _lastHoldTickAt = null;
  }

  void _markSuccess() {
    if (_disposed || _finalized) return;
    if (_failed) return;
    if (state.exhaleFailed || state.exhaleSuccess) return;

    _pauseHoldCountdown();
    _cancelStartTimeoutTimers();

    if (repo.isConnected) {
      try {
        d("SEND '/' (success)");
        repo.sendData("/");
      } catch (_) {}
    }

    _exhaleSucceeded = true;

    emit(state.copyWith(
      exhaleSuccess: true,
      exhaleFailed: false,
      error: null,
      holdSecondsLeft: 1,
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
    ));
  }

  Future<void> _fail({required String reason}) async {
    if (_disposed || _finalized) return;
    if (state.exhaleFailed || state.exhaleSuccess) return;

    _pauseHoldCountdown();
    _cancelStartTimeoutTimers();

    await _saveCancelTimeOnce();
    _sendAbortOnce(why: "fail");

    emit(state.copyWith(
      exhaleSuccess: false,
      exhaleFailed: true,
      error: reason,
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
      navigateToDashboard: false,
      startTimeoutRunning: false,
    ));
  }

  Future<void> cancelTest() async {
    if (_disposed || _finalized) return;

    _finalized = true;
    _failed = true;

    emit(state.copyWith(cancelTest: true));

    _pauseHoldCountdown();
    _cancelStartTimeoutTimers();

    _sendAbortOnce(why: "cancelTest");

    await _saveCancelTimeOnce();

    emit(state.copyWith(
      exhaleSuccess: false,
      exhaleFailed: true,
      error: "Aborted by user.",
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
      navigateToDashboard: true,
      cancelTest: true,
      startTimeoutRunning: false,
    ));
  }

  Future<void> _saveCancelTimeOnce() async {
    if (_timeSaved) return;
    _timeSaved = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cancel_or_disconnect_time',
      DateTime.now().toIso8601String(),
    );

    d("Saved cancel_or_disconnect_time ✅");
  }

  @override
  Future<void> close() {
    _disposed = true;

    _holdTicker?.cancel();
    _cancelStartTimeoutTimers();

    _connSub?.cancel();
    _dataSub?.cancel();

    return super.close();
  }
}
