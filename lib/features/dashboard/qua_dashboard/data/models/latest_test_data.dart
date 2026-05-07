import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/respyr_unified_response.dart';

class LatestTestData extends Equatable {
  final String testId;
  final String dietitianId;
  final String profileId;
  final String dietPlanId;

  final double? absorptiveMetabolismScore;
  final double? fermentativeMetabolismScore;
  final double? fatMetabolismScore;
  final double? glucoseMetabolismScore;
  final double? hepaticStressMetabolismScore;
  final double? detoxificationMetabolismScore;
  final double? fatLossMetabolismScore;

  final double? acetonePpm;
  final double? h2Ppm;
  final double? ethanolPpm;

  final String dateTime;
  final RespyrUnifiedResponse? testJsonData;
  final String rawTestJson;
  final double? minRange;
  final double? maxRange;

  const LatestTestData({
    required this.testId,
    required this.dietitianId,
    required this.profileId,
    required this.dietPlanId,
    required this.absorptiveMetabolismScore,
    required this.fermentativeMetabolismScore,
    required this.fatMetabolismScore,
    required this.glucoseMetabolismScore,
    required this.hepaticStressMetabolismScore,
    required this.detoxificationMetabolismScore,
    required this.fatLossMetabolismScore,
    required this.acetonePpm,
    required this.h2Ppm,
    required this.ethanolPpm,
    required this.dateTime,
    required this.testJsonData,
    required this.rawTestJson,
    required this.minRange,
    required this.maxRange,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  static Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return null;
  }

  static RespyrUnifiedResponse? _parseRespyrData(dynamic json, String fallbackDateTime) {
    final m = _asMap(json);
    if (m == null || m.isEmpty) return null;

    final patched = Map<String, dynamic>.from(m);
    if ((patched['date_time'] ?? '').toString().trim().isEmpty) {
      patched['date_time'] = fallbackDateTime;
    }

    return RespyrUnifiedResponse.fromJson(patched);
  }

  static RespyrUnifiedResponse? _parseTestJson(dynamic testJsonRaw, String fallbackDateTime) {
    if (testJsonRaw == null) return null;

    final asMap = _asMap(testJsonRaw);
    if (asMap != null && asMap.isNotEmpty) {
      final patched = Map<String, dynamic>.from(asMap);
      if ((patched['date_time'] ?? '').toString().trim().isEmpty) {
        patched['date_time'] = fallbackDateTime;
      }
      return RespyrUnifiedResponse.fromJson(patched);
    }

    final s = testJsonRaw.toString().trim();
    if (s.isEmpty) return null;

    try {
      final decoded = jsonDecode(s);
      final map = _asMap(decoded);
      if (map == null || map.isEmpty) return null;

      final patched = Map<String, dynamic>.from(map);
      if ((patched['date_time'] ?? '').toString().trim().isEmpty) {
        patched['date_time'] = fallbackDateTime;
      }

      return RespyrUnifiedResponse.fromJson(patched);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("test_json parse failed: $e");
      }
      return null;
    }
  }

  factory LatestTestData.fromJson(Map<String, dynamic> json) {
    final dateTime = (json['date_time'] ?? '').toString();

    final respyrResponse = _parseRespyrData(json['respyr_response'], dateTime);
    final testJsonData = respyrResponse ?? _parseTestJson(json['test_json'], dateTime);

    final rawTestJson = (json['test_json'] ?? '').toString().trim();

    return LatestTestData(
      testId: (json['test_id'] ?? '').toString(),
      dietitianId: (json['dietitian_id'] ?? '').toString(),
      profileId: (json['profile_id'] ?? '').toString(),
      dietPlanId: (json['diet_plan_id'] ?? '').toString(),
      absorptiveMetabolismScore: _toDouble(json['absorptive_metabolism_score']),
      fermentativeMetabolismScore: _toDouble(json['fermentative_metabolism_score']),
      fatMetabolismScore: _toDouble(json['fat_metabolism_score']),
      glucoseMetabolismScore: _toDouble(json['glucose_metabolism_score']),
      hepaticStressMetabolismScore: _toDouble(json['hepatic_stress_metabolism_score']),
      detoxificationMetabolismScore: _toDouble(json['detoxification_metabolism_score']),
      fatLossMetabolismScore: _toDouble(json['fat_loss_metabolism_score']),
      acetonePpm: _toDouble(json['acetone_ppm']),
      h2Ppm: _toDouble(json['h2_ppm']),
      ethanolPpm: _toDouble(json['ethanol_ppm']),
      dateTime: dateTime,
      testJsonData: testJsonData,
      rawTestJson: rawTestJson,
      minRange: _toDouble(json['min_range']),
      maxRange: _toDouble(json['max_range']),
    );
  }

  @override
  List<Object?> get props => [
    testId,
    dietitianId,
    profileId,
    dietPlanId,
    absorptiveMetabolismScore,
    fermentativeMetabolismScore,
    fatMetabolismScore,
    glucoseMetabolismScore,
    hepaticStressMetabolismScore,
    detoxificationMetabolismScore,
    fatLossMetabolismScore,
    acetonePpm,
    h2Ppm,
    ethanolPpm,
    dateTime,
    testJsonData,
    rawTestJson,
    minRange,
    maxRange,
  ];
}