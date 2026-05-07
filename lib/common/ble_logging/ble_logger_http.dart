import 'dart:async';
import 'dart:convert';
import 'dart:collection';

import 'package:http/http.dart' as http;

/// BLE logger using HTTP with BATCH insert.
/// Server endpoints:
///   - /dietitian/api/app/create_session.php
///   - /dietitian/api/app/add_events_batch.php
///   - /dietitian/api/app/end_session.php (optional)
class BleLoggerHttp {
  BleLoggerHttp._();
  static final BleLoggerHttp I = BleLoggerHttp._();

  // ---- Config ----
  static const String _base = "https://humorstech.com";
  static const String _createSessionPath = "/dietitian/api/app/create_session.php";
  static const String _addEventsBatchPath = "/dietitian/api/app/add_events_batch.php";
  static const String _endSessionPath = "/dietitian/api/app/end_session.php";

  // ---- State ----
  String? _sessionId;
  String? _profileId;
  bool _sessionCreated = false;

  int _seq = 0;

  final Queue<Map<String, dynamic>> _queue = Queue();
  Timer? _flushTimer;
  bool _flushing = false;

  // ---- Tuning ----
  final int _maxQueue = 2000;
  final int _flushBatchSize = 50;
  final Duration _flushEvery = const Duration(milliseconds: 800);
  final Duration _httpTimeout = const Duration(seconds: 8);

  /// Call once when your flow starts (connect/calibration start etc.)
  Future<void> createSession({
    required String sessionId,
    required String profileId,
    required String appVersion,
    required String platform,          // "ios" or "android"
    required String osVersion,         // e.g. "18.1", "14"
    required String phoneModel,        // e.g. "iPhone15,2", "SM-G998B"
    String? deviceId,                  // BLE peripheral identifier / MAC / UUID
    String? deviceFirmware,            // firmware version from device (optional)
  }) async {
    // Reset previous session buffers
    _queue.clear();
    _sessionId = sessionId;
    _profileId = profileId;
    _sessionCreated = false;
    _seq = 0;

    _startFlushLoop();

    final body = {
      "session_id": sessionId,
      "profile_id": profileId,
      "app_version": appVersion,
      "platform": platform,
      "os_version": osVersion,
      "phone_model": phoneModel,
      if (deviceId != null) "device_id": deviceId,
      if (deviceFirmware != null) "device_fw": deviceFirmware,
      "started_at": DateTime.now().toUtc().toIso8601String(), // optional: client timestamp
    };

    try {
      final res = await _postJson("$_base$_createSessionPath", body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _sessionCreated = true;

        logEvent(
          screen: "system",
          direction: "sys",
          eventType: "session_created",
          message: "Session created successfully",
          payloadText: res.body,
          allowBeforeSession: true,
        );
      } else {
        logEvent(
          screen: "system",
          direction: "sys",
          eventType: "session_create_failed",
          message: "HTTP error ${res.statusCode}",
          payloadText: res.body,
          allowBeforeSession: true,
        );
      }
    } catch (e, stack) {
      logEvent(
        screen: "system",
        direction: "sys",
        eventType: "session_create_error",
        message: "createSession failed",
        payloadText: e.toString(),
        meta: {
          "error": e.toString(),
          "stack_trace": stack.toString().split('\n').take(5).join('\n'), // limited stack
        },
        allowBeforeSession: true,
      );
    }
  }

  /// Main logging function – call from anywhere in the app
  ///
  /// direction: "rx" | "tx" | "sys" | "ui" | "ble"
  void logEvent({
    required String screen,
    required String direction,
    required String eventType,
    required String message,
    String? payloadText,
    Map<String, dynamic>? meta,
    bool allowBeforeSession = false,
  }) {
    final sid = _sessionId;
    final pid = _profileId;

    if (sid == null || pid == null) return;
    if (!_sessionCreated && !allowBeforeSession) return;

    _seq += 1;
    final tsMs = DateTime.now().millisecondsSinceEpoch;

    final event = <String, dynamic>{
      "session_id": sid,
      "seq": _seq,
      "ts_ms": tsMs,
      "screen": screen,
      "direction": direction,
      "event_type": eventType,
      "payload_text": payloadText ?? "",

      "meta_json": <String, dynamic>{
        "profile_id": pid,
        "message": message,
        if (meta != null) ...meta,
      },
    };

    if (_queue.length >= _maxQueue) {
      _queue.removeFirst(); // drop oldest if queue too large
    }
    _queue.add(event);
  }

  /// Call when the BLE flow / session ends
  Future<void> endSession({
    required String reason,           // "completed" | "cancelled" | "timeout" | "disconnect" | "error"
    String? finalStatus,              // "success" | "failed" | "timeout" etc. — will be saved as final_status
    String? finalScreen,              // last screen name
    String? finalReason,              // detailed reason / error message
  }) async {
    final sid = _sessionId;
    final pid = _profileId;

    if (sid == null || pid == null) return;
    if (!_sessionCreated) return;

    try {
      // Log the end event first
      logEvent(
        screen: "flow",
        direction: "ui",
        eventType: "session_end",
        message: "Ending BLE session",
        payloadText: reason,
        meta: {
          "reason": reason,
          if (finalStatus != null) "final_status": finalStatus,
          if (finalScreen != null) "final_screen": finalScreen,
          if (finalReason != null) "final_reason": finalReason,
        },
      );

      // Flush remaining events
      await flushAll();

      // Call end_session endpoint
      final url = "$_base$_endSessionPath";

      final body = {
        "session_id": sid,
        "profile_id": pid,
        "reason": reason,
        if (finalStatus != null) "final_status": finalStatus,
        if (finalScreen != null) "final_screen": finalScreen,
        if (finalReason != null) "final_reason": finalReason,
      };

      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(_httpTimeout);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        logEvent(
          screen: "system",
          direction: "sys",
          eventType: "end_session_failed",
          message: "HTTP ${res.statusCode}",
          payloadText: res.body,
        );
      }
    } catch (e) {
      logEvent(
        screen: "system",
        direction: "sys",
        eventType: "end_session_error",
        message: "endSession failed",
        payloadText: e.toString(),
      );
    } finally {
      // Clear session state
      _sessionId = null;
      _profileId = null;
      _sessionCreated = false;
      _stopFlushLoop();
    }
  }

  /// Flush all pending events (useful before app close or session end)
  Future<void> flushAll() async {
    int guard = 0;
    while (_queue.isNotEmpty && guard < 100) {
      await _flushOnce();
      guard++;
    }
  }

  Future<void> flushNow() async => _flushOnce();

  // ────────────────────────────────────────────────
  // Internal helpers
  // ────────────────────────────────────────────────

  void _startFlushLoop() {
    _flushTimer ??= Timer.periodic(_flushEvery, (_) => _flushOnce());
  }

  void _stopFlushLoop() {
    _flushTimer?.cancel();
    _flushTimer = null;
  }

  Future<void> _flushOnce() async {
    if (_flushing || _queue.isEmpty) return;

    _flushing = true;

    final batch = <Map<String, dynamic>>[];
    while (_queue.isNotEmpty && batch.length < _flushBatchSize) {
      batch.add(_queue.removeFirst());
    }

    try {
      final res = await _postJson(
        "$_base$_addEventsBatchPath",
        {"events": batch},
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        // Re-queue on failure (preserve order)
        for (int i = batch.length - 1; i >= 0; i--) {
          _queue.addFirst(batch[i]);
        }
      }
    } catch (_) {
      // Network error → re-queue
      for (int i = batch.length - 1; i >= 0; i--) {
        _queue.addFirst(batch[i]);
      }
    } finally {
      _flushing = false;
    }
  }

  Future<http.Response> _postJson(String url, Map<String, dynamic> body) {
    return http
        .post(
      Uri.parse(url),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(body),
    )
        .timeout(_httpTimeout);
  }
}