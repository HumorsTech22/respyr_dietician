// calender_logic.dart (keep ONLY this DayRecord + DailyReading in whole project)
import 'dart:convert';
import 'package:flutter/material.dart';

enum MetabolicZone { optimal, moderate, focused }

class DailyReading {
  final MetabolicZone zone;
  final String? weight;
  final double? score;

  DailyReading({
    required this.zone,
    this.weight,
    this.score,
  });
}

class DayRecord {
  final DateTime date;
  final MetabolicZone? zone;
  final double? score;
  final String? metric;

  DayRecord({
    required this.date,
    this.zone,
    this.metric,
    this.score,
  });

  Color get dotColor {
    switch (zone) {
      case MetabolicZone.optimal:
        return const Color(0xFF27AE60);
      case MetabolicZone.moderate:
        return const Color(0xFFF2C94C);
      case MetabolicZone.focused:
        return const Color(0xFFDA5747);
      default:
        return Colors.transparent;
    }
  }
}

class CalendarLogic {
  static List<DayRecord?> generateMonthData(
      int year,
      int month,
      Map<int, DailyReading> readings,
      ) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final int leadingEmpty = firstDay.weekday - 1;

    final List<DayRecord?> cells = [];

    for (int i = 0; i < leadingEmpty; i++) {
      cells.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final reading = readings[day];
      cells.add(
        DayRecord(
          date: DateTime(year, month, day),
          zone: reading?.zone,
          metric: reading?.weight,
          score: reading?.score,
        ),
      );
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }
}

/// Use this inside your screen file (same class) where _mapZone exists.
Map<int, Map<int, DailyReading>> buildCalendarReadingsFromApiRows(
    List<dynamic> rows,
    MetabolicZone? Function(String? zoneStr) mapZone,
    ) {
  final out = <int, Map<int, DailyReading>>{};

  for (final item in rows) {
    if (item is! Map) continue;

    final dtStr = item["date_time"]?.toString();
    if (dtStr == null || dtStr.isEmpty) continue;

    final dt = DateTime.tryParse(dtStr.replaceFirst(" ", "T"));
    if (dt == null) continue;

    // test_json can be MAP or STRING
    final testJsonRaw = item["test_json"];
    Map<String, dynamic>? tj;

    if (testJsonRaw is Map<String, dynamic>) {
      tj = testJsonRaw;
    } else if (testJsonRaw is Map) {
      tj = Map<String, dynamic>.from(testJsonRaw);
    } else if (testJsonRaw is String) {
      final s = testJsonRaw.trim();
      if (s.isNotEmpty) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is Map<String, dynamic>) {
            tj = decoded;
          } else if (decoded is Map) {
            tj = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
    }

    if (tj == null) continue;

    // Fat_Use_Pattern_trend
    final fatUseRaw = tj["Fat_Use_Pattern_trend"];
    Map<String, dynamic>? fatMap;

    if (fatUseRaw is Map<String, dynamic>) {
      fatMap = fatUseRaw;
    } else if (fatUseRaw is Map) {
      fatMap = Map<String, dynamic>.from(fatUseRaw);
    }

    if (fatMap == null) continue;

    final zoneStr = fatMap["zone"]?.toString();
    final zone = mapZone(zoneStr);
    if (zone == null) continue;

    final dynamic scoreNum = fatMap["score"];
    double? scoreVal;
    if (scoreNum is num) {
      scoreVal = scoreNum.toDouble();
    } else if (scoreNum is String) {
      scoreVal = double.tryParse(scoreNum);
    }

    out.putIfAbsent(dt.month, () => <int, DailyReading>{});
    out[dt.month]![dt.day] = DailyReading(
      zone: zone,
      weight: '0',
      score: scoreVal,
    );
  }

  return out;
}