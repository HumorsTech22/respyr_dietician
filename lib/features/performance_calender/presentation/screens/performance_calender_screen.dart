import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';

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
  final String? metric;
  final double? score;

  DayRecord({
    required this.date,
    this.zone,
    this.metric,
    this.score,
  });

  Color get dotColor {
    if (zone == MetabolicZone.optimal) return const Color(0xFF27AE60);
    if (zone == MetabolicZone.moderate) return const Color(0xFFF2C94C);
    if (zone == MetabolicZone.focused) return const Color(0xFFDA5747);
    return Colors.transparent;
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

class DayCell extends StatelessWidget {
  final DayRecord? record;
  final VoidCallback? onTap;

  const DayCell({
    super.key,
    required this.record,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (record == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '${record!.date.day}',
            style: GoogleFonts.poppins(
              color: record!.date.weekday == DateTime.sunday
                  ? const Color(0xFFDA5747)
                  : const Color(0xFF252525),
              fontSize: rh(context: context, px: 10),
              fontWeight: FontWeight.w400,
              letterSpacing: rh(context: context, px: -0.20),
            ),
          ),
          SizedBox(height: rh(context: context, px: 6)),
          if (record!.zone != null)
            Container(
              width: rh(context: context, px: 6),
              height: rh(context: context, px: 6),
              decoration: BoxDecoration(
                color: record!.dotColor,
                shape: BoxShape.circle,
              ),
            )
          else
            SizedBox(height: rh(context: context, px: 6)),
          SizedBox(height: rh(context: context, px: 4)),
          if (record!.score != null)
            Text(
              '${record!.score!.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontSize: rh(context: context, px: 10),
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            SizedBox(height: rh(context: context, px: 12)),
        ],
      ),
    );
  }
}

class MonthSnapScrollPhysics extends ScrollPhysics {
  final List<double> Function() offsetsGetter;

  const MonthSnapScrollPhysics({
    required this.offsetsGetter,
    super.parent,
  });

  @override
  MonthSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MonthSnapScrollPhysics(
      offsetsGetter: offsetsGetter,
      parent: buildParent(ancestor),
    );
  }

  int _nearestIndex(List<double> offsets, double pixels) {
    int best = 0;
    double bestDiff = (pixels - offsets[0]).abs();
    for (int i = 1; i < offsets.length; i++) {
      final diff = (pixels - offsets[i]).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = i;
      }
    }
    return best;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final offsets = offsetsGetter();
    if (offsets.isEmpty) return super.createBallisticSimulation(position, velocity);

    final double current = position.pixels;

    int idx = offsets.lastIndexWhere((o) => o <= current);
    if (idx < 0) idx = 0;

    const double flingThreshold = 250;

    if (velocity > flingThreshold) {
      idx = (idx + 1).clamp(0, offsets.length - 1);
    } else if (velocity < -flingThreshold) {
      idx = (idx - 1).clamp(0, offsets.length - 1);
    } else {
      idx = _nearestIndex(offsets, current);
    }

    final double target = offsets[idx].clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if ((target - current).abs() < 0.5) return null;

    return ScrollSpringSimulation(
      spring,
      current,
      target,
      velocity,
    );
  }
}

class PerformanceCalenderScreen extends StatefulWidget {
  final String dietitianId;
  final String profileId;

  const PerformanceCalenderScreen({
    super.key,
    required this.dietitianId,
    required this.profileId,
  });

  @override
  State<PerformanceCalenderScreen> createState() => _MetabolicScreenState();
}

class _MetabolicScreenState extends State<PerformanceCalenderScreen> {
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;

  late int _visibleMonth;

  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _monthKeys;
  final List<double> _monthOffsets = [];

  bool _loading = true;

  Map<int, Map<int, DailyReading>> _readingsByMonth = {};

  @override
  void initState() {
    super.initState();
    _visibleMonth = currentMonth;
    _monthKeys = List.generate(currentMonth, (_) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCalendarData();
      _cacheMonthOffsets();
      _jumpToMonth(currentMonth);
    });
  }

  Future<void> _loadCalendarData() async {
    setState(() => _loading = true);

    final res = await http.post(
      Uri.parse("https://humorstech.com/dietitian/api/app/get_recent_test_data.php"),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "dietitian_id": widget.dietitianId,
        "profile_id": widget.profileId,
      }),
    );

    final decoded = jsonDecode(res.body);
    _readingsByMonth = _buildCalendarReadings(
      (decoded is Map && decoded["data"] is List) ? decoded["data"] as List : <dynamic>[],
    );

    setState(() => _loading = false);
  }

  MetabolicZone? _mapZone(String? z) {
    if (z == null) return null;
    switch (z.toLowerCase()) {
      case "optimal":
        return MetabolicZone.optimal;
      case "moderate":
        return MetabolicZone.moderate;
      case "focus":
        return MetabolicZone.focused;
      default:
        return null;
    }
  }

  Map<int, Map<int, DailyReading>> _buildCalendarReadings(List<dynamic> rows) {
    final out = <int, Map<int, DailyReading>>{};

    for (final item in rows) {
      if (item is! Map) continue;

      final dtStr = item["date_time"]?.toString();
      if (dtStr == null || dtStr.isEmpty) continue;

      final dt = DateTime.tryParse(dtStr.replaceFirst(" ", "T"));
      if (dt == null) continue;

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

      final fatUseRaw = tj["Fat_Use_Pattern_trend"];
      Map<String, dynamic>? fatMap;

      if (fatUseRaw is Map<String, dynamic>) {
        fatMap = fatUseRaw;
      } else if (fatUseRaw is Map) {
        fatMap = Map<String, dynamic>.from(fatUseRaw);
      }

      if (fatMap == null) continue;

      final zone = _mapZone(fatMap["zone"]?.toString());
      if (zone == null) continue;

      double? scoreVal;
      if (fatMap["score"] is num) scoreVal = (fatMap["score"] as num).toDouble();
      if (fatMap["score"] is String) scoreVal = double.tryParse(fatMap["score"] as String);

      out.putIfAbsent(dt.month, () => <int, DailyReading>{});
      out[dt.month]![dt.day] = DailyReading(
        zone: zone,
        weight: '0',
        score: scoreVal,
      );
    }

    return out;
  }

  Map<int, DailyReading> _fetchDataForMonth(int year, int month) {
    return _readingsByMonth[month] ?? {};
  }

  void _cacheMonthOffsets() {
    _monthOffsets.clear();

    for (int i = 0; i < _monthKeys.length; i++) {
      final ctx = _monthKeys[i].currentContext;
      if (ctx == null) {
        _monthOffsets.add(0);
        continue;
      }

      final renderObject = ctx.findRenderObject();
      if (renderObject == null) {
        _monthOffsets.add(0);
        continue;
      }

      final viewport = RenderAbstractViewport.of(renderObject);
      final revealed = viewport.getOffsetToReveal(renderObject, 0.0);
      _monthOffsets.add(revealed.offset);
    }
  }

  void _jumpToMonth(int monthNumber) {
    if (_monthOffsets.isEmpty) return;
    _scrollController.jumpTo(
      _monthOffsets[(monthNumber - 1).clamp(0, _monthOffsets.length - 1)],
    );
  }

  int _nearestMonthFromOffset(double offset) {
    if (_monthOffsets.isEmpty) return 1;
    int best = 0;
    double bestDiff = (offset - _monthOffsets[0]).abs();
    for (int i = 1; i < _monthOffsets.length; i++) {
      final diff = (offset - _monthOffsets[i]).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = i;
      }
    }
    return best + 1;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        title: Text(
          "Calender",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 15),
            fontWeight: FontWeight.w400,
            letterSpacing: rh(context: context, px: -0.30),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollEndNotification) {
            _cacheMonthOffsets();
            if (_nearestMonthFromOffset(_scrollController.offset) != _visibleMonth) {
              setState(() => _visibleMonth = _nearestMonthFromOffset(_scrollController.offset));
            }
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: MonthSnapScrollPhysics(
            offsetsGetter: () => _monthOffsets,
            parent: const BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            rh(context: context, px: 20),
            rh(context: context, px: 10),
            rh(context: context, px: 20),
            rh(context: context, px: 100),
          ),
          cacheExtent: rh(context: context, px: 1200),
          itemCount: currentMonth,
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: Padding(
                key: _monthKeys[index],
                padding: EdgeInsets.only(bottom: rh(context: context, px: 40)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM yyyy').format(DateTime(currentYear, index + 1)),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 34),
                        fontWeight: FontWeight.w400,
                        letterSpacing: rh(context: context, px: -2.04),
                      ),
                    ),
                    SizedBox(height: rh(context: context, px: 15)),
                    Text(
                      '${_fetchDataForMonth(currentYear, index + 1).length} Tests Recorded',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 12),
                        fontWeight: FontWeight.w400,
                        height: rh(context: context, px: 1.10),
                        letterSpacing: rh(context: context, px: -0.24),
                      ),
                    ),
                    SizedBox(height: rh(context: context, px: 20)),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rh(context: context, px: 16)),
                      ),
                      padding: EdgeInsets.all(rh(context: context, px: 16)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                .map(
                                  (day) => Text(
                                day,
                                style: GoogleFonts.poppins(
                                  color: day == "Sun"
                                      ? const Color(0xFFDA5747)
                                      : const Color(0xFF252525),
                                  fontSize: rh(context: context, px: 10),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: rh(context: context, px: -0.20),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                          SizedBox(height: rh(context: context, px: 12)),
                          Divider(color: Colors.grey.shade200, height: rh(context: context, px: 1)),
                          SizedBox(height: rh(context: context, px: 12)),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 0.65,
                              mainAxisSpacing: rh(context: context, px: 16),
                            ),
                            itemCount: CalendarLogic.generateMonthData(
                              currentYear,
                              index + 1,
                              _fetchDataForMonth(currentYear, index + 1),
                            ).length,
                            itemBuilder: (context, i) {
                              final list = CalendarLogic.generateMonthData(
                                currentYear,
                                index + 1,
                                _fetchDataForMonth(currentYear, index + 1),
                              );
                              return DayCell(
                                record: list[i],
                                onTap: () {
                                  if (list[i] != null && list[i]!.zone != null) {
                                    debugPrint('Date: ${list[i]!.date}');
                                    debugPrint('Score: ${list[i]!.score}');
                                    debugPrint('Zone: ${list[i]!.zone}');
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}