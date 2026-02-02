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

  static const double _minRange = 20.0;
  static const double _maxRange = 80.0;

  static const int _holdTotalMs = 2500;
  static const Duration _outGrace = Duration(seconds: 2);
  static const double _stopProgressThreshold = 0.0;

  Timer? _holdTicker;
  Timer? _outOfRangeTimer;
  DateTime? _lastHoldTickAt;

  int _holdRemainingMs = _holdTotalMs;
  int _inRangeAccumMs = 0;

  static const int _maxBlowPoints = 300;
  final List<double> _blowValues = [];

  // ✅ ensures cancel flow executes once
  bool _finalized = false;

  // ✅ save time only once
  bool _timeSaved = false;

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

    emit(state.copyWith(
      isConnected: repo.isConnected,
      progress: 0,
      holdSecondsLeft: (_holdRemainingMs / 1000).ceil(),
      exhaleStarted: false,
      inRange: false,
      exhaleSuccess: false,
      exhaleFailed: false,
      analysisReady: false,
      blowValues: const [],
      inRangeDurationMs: 0,
      navigateToDashboard: false,
      error: null,
    ));

    _connSub = repo.connectionStatusStream().listen((connected) {
      if (_disposed) return;

      emit(state.copyWith(isConnected: connected));

      // disconnected: stop timers to avoid running work
      if (!connected) {
        _pauseHoldCountdown();
        _cancelOutOfRangeTimer();
        // keep error optional
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
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onData(String data) {
    if (_disposed || _finalized || data.isEmpty) return;

    final clean = data.trim();
    emit(state.copyWith(receivedData: clean, error: null));

    // After success -> wait for "analize"
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

    _blowValues.add(blowVal);
    if (_blowValues.length > _maxBlowPoints) {
      _blowValues.removeRange(0, _blowValues.length - _maxBlowPoints);
    }
    emit(state.copyWith(blowValues: List<double>.unmodifiable(_blowValues)));

    final base = _baseDouble;

    if (blowVal <= base) {
      _handleProgress(0);
      return;
    }

    final progress = Thresholds.calculateBlowPercentage(base, blowVal);
    _handleProgress(progress);
  }

  void _handleProgress(double progress) {
    if (_disposed || _finalized) return;
    if (state.exhaleFailed || state.exhaleSuccess) return;

    final nowInRange = (progress >= _minRange && progress <= _maxRange);

    emit(state.copyWith(
      progress: progress,
      inRange: nowInRange,
      inRangeDurationMs: _inRangeAccumMs,
    ));

    // mistake: stopped exhaling => fail (save time) + send & only if connected
    if (state.exhaleStarted && progress <= _stopProgressThreshold) {
      _fail(reason: "Exhale failed: you stopped exhaling.");
      return;
    }

    if (!state.exhaleStarted && nowInRange) {
      emit(state.copyWith(exhaleStarted: true));
      _resumeHoldCountdown();
      _cancelOutOfRangeTimer();
      return;
    }

    if (!state.exhaleStarted) return;

    if (nowInRange) {
      _cancelOutOfRangeTimer();
      _resumeHoldCountdown();
    } else {
      _pauseHoldCountdown();
      _startOutOfRangeFailTimer();
    }
  }

  void _resumeHoldCountdown() {
    if (_holdRemainingMs <= 0) return;
    if (_holdTicker != null) return;

    _lastHoldTickAt = DateTime.now();

    _holdTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _finalized) return;
      if (state.exhaleFailed || state.exhaleSuccess) return;

      _lastHoldTickAt ??= DateTime.now();
      final now = DateTime.now();
      final dt = now.difference(_lastHoldTickAt!).inMilliseconds;
      _lastHoldTickAt = now;

      _inRangeAccumMs += dt;

      _holdRemainingMs -= dt;
      if (_holdRemainingMs < 0) _holdRemainingMs = 0;

      emit(state.copyWith(
        holdSecondsLeft: (_holdRemainingMs / 1000).ceil().clamp(0, 3),
        inRangeDurationMs: _inRangeAccumMs,
      ));

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

  void _startOutOfRangeFailTimer() {
    if (_outOfRangeTimer != null) return;

    _outOfRangeTimer = Timer(_outGrace, () {
      if (_disposed || _finalized) return;
      if (state.exhaleFailed || state.exhaleSuccess) return;

      final stillOut =
      !(state.progress >= _minRange && state.progress <= _maxRange);

      if (stillOut) {
        _fail(
          reason:
          "Exhale failed: out of ${_minRange.toInt()}–${_maxRange.toInt()}% range for more than 2 seconds.",
        );
      } else {
        _cancelOutOfRangeTimer();
      }
    });
  }

  void _cancelOutOfRangeTimer() {
    _outOfRangeTimer?.cancel();
    _outOfRangeTimer = null;
  }

  void _markSuccess() {
    if (_disposed || _finalized) return;
    if (state.exhaleFailed || state.exhaleSuccess) return;

    _pauseHoldCountdown();
    _cancelOutOfRangeTimer();

    // send "/" only if connected (optional: you can try always, but you asked connected-only)
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
      holdSecondsLeft: 0,
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
    ));
  }

  // ✅ FAIL: always save time, send '&' only if connected
  Future<void> _fail({required String reason}) async {
    if (_disposed || _finalized) return;
    if (state.exhaleFailed || state.exhaleSuccess) return;

    _pauseHoldCountdown();
    _cancelOutOfRangeTimer();

    await _saveCancelTimeOnce();

    if (repo.isConnected) {
      try {
        d("SEND '&' (abort) due to fail");
        repo.sendData("&");
      } catch (_) {}
    } else {
      d("Skip '&' (not connected) on fail");
    }

    emit(state.copyWith(
      exhaleSuccess: false,
      exhaleFailed: true,
      error: reason,
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
      navigateToDashboard: false,
    ));
  }

  // ✅ CANCEL: any stage => save time + navigate dashboard
  // ✅ send '&' only if connected
  Future<void> cancelTest() async {
    if (_disposed || _finalized) return;

    _finalized = true; // prevent any more ticks/data changes

    _pauseHoldCountdown();
    _cancelOutOfRangeTimer();

    await _saveCancelTimeOnce();

    if (repo.isConnected) {
      try {
        d("SEND '&' (abort) from cancel");
        repo.sendData("&");
      } catch (_) {}
    } else {
      d("Skip '&' (not connected) on cancel");
    }

    emit(state.copyWith(
      exhaleSuccess: false,
      exhaleFailed: true,
      error: "Aborted by user.",
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
      navigateToDashboard: true, // ✅ UI will go dashboard
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
    _outOfRangeTimer?.cancel();

    _connSub?.cancel();
    _dataSub?.cancel();

    return super.close();
  }
}
