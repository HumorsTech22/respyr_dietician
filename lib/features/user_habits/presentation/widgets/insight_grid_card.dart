// lib/features/user_habits/presentation/widgets/insight_grid_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/weekly_habit_tracking_model.dart';
import 'package:respyr_dietitian/features/user_habits/presentation/helper/habits_color_helper.dart';

import '../../../../core/size/get_height.dart' show rh;

/// Card display modes
enum HabitCardMode {
  weeklyGrid,    // 2-col grid, weekly 7 dots
  weeklyList,    // full-width row, weekly 7 dots
  totalList,     // full-width, all-time dots in 18-col grid
}

class InsightGridCard extends StatelessWidget {
  final HabitItem habit;
  final HabitCardMode mode;
  final int index;

  const InsightGridCard({
    super.key,
    required this.habit,
    required this.index,
    this.mode = HabitCardMode.weeklyGrid,
  });

  @override
  Widget build(BuildContext context) {
    final darkColor = HabitsColorHelper().getHabitColorDark(index);
    final bgColor = HabitsColorHelper().getHabitColorBg(index);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: rh(context: context, px: 20),
        vertical: rh(context: context, px: 17),
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE1E6ED)),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: _buildLayoutForMode(context, darkColor, bgColor),
    );
  }

  /// Routes to the right layout based on mode
  Widget _buildLayoutForMode(
      BuildContext context, Color darkColor, Color bgColor) {
    switch (mode) {
      case HabitCardMode.weeklyGrid:
        return _WeeklyGridLayout(
          habit: habit,
          darkColor: darkColor,
          bgColor: bgColor,
        );
      case HabitCardMode.weeklyList:
        return _WeeklyListLayout(
          habit: habit,
          darkColor: darkColor,
          bgColor: bgColor,
        );
      case HabitCardMode.totalList:
        return _TotalListLayout(
          habit: habit,
          darkColor: darkColor,
          bgColor: bgColor,
        );
    }
  }
}

// ====================================================================
// LAYOUT 1: Weekly Grid (2-col grid card)
// ====================================================================

class _WeeklyGridLayout extends StatelessWidget {
  final HabitItem habit;
  final Color darkColor;
  final Color bgColor;

  const _WeeklyGridLayout({
    required this.habit,
    required this.darkColor,
    required this.bgColor,
  });

  String get _frequencyLabel {
    if (habit.frequencyType == 'daily') return '7 Days';
    if (habit.frequencyType == 'weekly') return 'Weekly';
    return habit.frequencyType;
  }

  String get _percentText {
    final rate = habit.weekSummary?.completionRate ?? 0.0;
    if (rate == rate.truncateToDouble()) return rate.toInt().toString();
    return rate.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardTitle(text: habit.habitName),
        SizedBox(height: rh(context: context, px: 11)),
        _CardSubtitle(text: _frequencyLabel, color: darkColor),
        SizedBox(height: rh(context: context, px: 12)),
        _WeeklyDots(
          tracking: habit.tracking,
          borderColor: darkColor,
          bgColor: bgColor,
        ),
        SizedBox(height: rh(context: context, px: 15)),
        const _CardLabel(),
        SizedBox(height: rh(context: context, px: 20)),
        _CardPercentage(value: _percentText, suffix: '%'),
      ],
    );
  }
}

// ====================================================================
// LAYOUT 2: Weekly List (full-width row, side-by-side)
// ====================================================================

class _WeeklyListLayout extends StatelessWidget {
  final HabitItem habit;
  final Color darkColor;
  final Color bgColor;

  const _WeeklyListLayout({
    required this.habit,
    required this.darkColor,
    required this.bgColor,
  });

  String get _frequencyLabel {
    if (habit.frequencyType == 'daily') return '7 Days';
    if (habit.frequencyType == 'weekly') return 'Weekly';
    return habit.frequencyType;
  }

  String get _percentText {
    final rate = habit.weekSummary?.completionRate ?? 0.0;
    if (rate == rate.truncateToDouble()) return rate.toInt().toString();
    return rate.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(text: habit.habitName),
              SizedBox(height: rh(context: context, px: 5)),
              _CardSubtitle(text: _frequencyLabel, color: darkColor),
              SizedBox(height: rh(context: context, px: 12)),
              _WeeklyDots(
                tracking: habit.tracking,
                borderColor: darkColor,
                bgColor: bgColor,
              ),
              SizedBox(height: rh(context: context, px: 8)),
              const _CardLabel(),
            ],
          ),
        ),
        SizedBox(width: rh(context: context, px: 12)),
        _CardPercentage(value: _percentText, suffix: '%'),
      ],
    );
  }
}

// ====================================================================
// LAYOUT 3: Total List (full-width, 18-col all-time grid)
// ====================================================================

class _TotalListLayout extends StatelessWidget {
  final HabitItem habit;
  final Color darkColor;
  final Color bgColor;

  const _TotalListLayout({
    required this.habit,
    required this.darkColor,
    required this.bgColor,
  });

  String get _frequencyLabel {
    if (habit.frequencyType == 'daily') return '7 Days';
    if (habit.frequencyType == 'weekly') return 'Weekly';
    return habit.frequencyType;
  }

  String get _percentText {
    final rate = habit.allTimeSummary?.completionRate ?? 0.0;
    if (rate == rate.truncateToDouble()) return rate.toInt().toString();
    return rate.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardTitle(text: habit.habitName),
                  SizedBox(height: rh(context: context, px: 5)),
                  _CardSubtitle(text: _frequencyLabel, color: darkColor),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardLabel(),
                SizedBox(height: rh(context: context, px: 20)),
                _CardPercentage(value: _percentText, suffix: '%'),
              ],
            ),
          ],
        ),
        SizedBox(height: rh(context: context, px: 14)),
        _AllTimeDotsGrid(
          allTime: habit.allTimeTracking,
          borderColor: darkColor,
          bgColor: bgColor,
        ),
      ],
    );
  }
}

// ====================================================================
// SHARED PIECES — reusable building blocks
// ====================================================================

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        color: const Color(0xFF252525),
        fontSize: rh(context: context, px: 15),
        fontWeight: FontWeight.w600,
        height: 1.10,
        letterSpacing: rh(context: context, px: -0.30),
      ),
    );
  }
}

class _CardSubtitle extends StatelessWidget {
  final String text;
  final Color color;
  const _CardSubtitle({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        color: color,
        fontSize: rh(context: context, px: 10),
        fontWeight: FontWeight.w400,
        letterSpacing: rh(context: context, px: -0.20),
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      "Completion Rate",
      style: GoogleFonts.poppins(
        color: const Color(0xFF535359),
        fontSize: rh(context: context, px: 10),
        fontWeight: FontWeight.w600,
        height: 1.10,
        letterSpacing: rh(context: context, px: -0.20),
      ),
    );
  }
}

class _CardPercentage extends StatelessWidget {
  final String value;
  final String suffix;
  const _CardPercentage({required this.value, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 40),
            fontWeight: FontWeight.w400,
            letterSpacing: rh(context: context, px: -0.80),
            height: 1.0,
          ),
        ),
        SizedBox(width: rh(context: context, px: 2)),
        Padding(
          padding: EdgeInsets.only(bottom: rh(context: context, px: 6)),
          child: Text(
            suffix,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 10),
              fontWeight: FontWeight.w400,
              letterSpacing: rh(context: context, px: -0.20),
            ),
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// DOT WIDGETS — used by layouts above
// ====================================================================

/// Generic single dot
class _Dot extends StatelessWidget {
  final double size;
  final Color fill;
  final Color border;
  final double strokeWidth;

  const _Dot({
    required this.size,
    required this.fill,
    required this.border,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: fill,
        shape: OvalBorder(
          side: BorderSide(width: strokeWidth, color: border),
        ),
      ),
    );
  }
}

/// Weekly: 7 dots — completed (solid), pending (outline), future (grey)
class _WeeklyDots extends StatelessWidget {
  final List<DailyTracking> tracking;
  final Color borderColor;
  final Color bgColor;

  const _WeeklyDots({
    required this.tracking,
    required this.borderColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = rh(context: context, px: 12);
    final stroke = rh(context: context, px: 1);
    const futureColor = Color(0xFFE1E6ED);

    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
        separatorBuilder: (context, _) =>
            SizedBox(width: rh(context: context, px: 5)),
        itemBuilder: (context, dotIndex) {
          if (dotIndex >= tracking.length) {
            return _Dot(
              size: size,
              fill: Colors.transparent,
              border: borderColor,
              strokeWidth: stroke,
            );
          }
          final day = tracking[dotIndex];
          if (day.isCompleted) {
            return _Dot(
              size: size,
              fill: borderColor,
              border: borderColor,
              strokeWidth: stroke,
            );
          } else if (day.isFuture) {
            return _Dot(
              size: size,
              fill: futureColor,
              border: futureColor,
              strokeWidth: stroke,
            );
          } else {
            return _Dot(
              size: size,
              fill: bgColor,
              border: borderColor,
              strokeWidth: stroke,
            );
          }
        },
      ),
    );
  }
}

/// All-time: 18-col grid, up to 4 rows (max 72 most-recent days)
/// Dot size auto-fits available width; height grows with data.
class _AllTimeDotsGrid extends StatelessWidget {
  final List<AllTimeTracking> allTime;
  final Color borderColor;
  final Color bgColor;

  static const int columns = 18;
  static const int maxDots = 72; // 18 × 4

  const _AllTimeDotsGrid({
    required this.allTime,
    required this.borderColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    if (allTime.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 4)),
        child: Text(
          'No tracking data yet',
          style: GoogleFonts.poppins(
            color: const Color(0xFF999999),
            fontSize: rh(context: context, px: 10),
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    // Take last (most recent) maxDots days
    final recent = allTime.length > maxDots
        ? allTime.sublist(allTime.length - maxDots)
        : allTime;

    final stroke = rh(context: context, px: 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Auto-fit: 18 dots + 17 gaps inside available width
        final gap = rh(context: context, px: 4);
        final totalGap = gap * (columns - 1);
        final available = constraints.maxWidth - totalGap;
        final rawSize = (available / columns).floorToDouble();
        final dotSize = rawSize.clamp(
          rh(context: context, px: 6),
          rh(context: context, px: 14),
        );

        // Build only the rows we actually need
        final rowsNeeded = (recent.length / columns).ceil();
        final List<List<AllTimeTracking?>> grid = List.generate(
          rowsNeeded,
              (_) => List<AllTimeTracking?>.filled(columns, null),
        );

        for (int i = 0; i < recent.length; i++) {
          grid[i ~/ columns][i % columns] = recent[i];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int r = 0; r < rowsNeeded; r++) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int c = 0; c < columns; c++) ...[
                    _allTimeDotFor(grid[r][c], dotSize, stroke),
                    if (c < columns - 1) SizedBox(width: gap),
                  ],
                ],
              ),
              if (r < rowsNeeded - 1) SizedBox(height: gap),
            ],
          ],
        );
      },
    );
  }

  Widget _allTimeDotFor(AllTimeTracking? day, double size, double stroke) {
    if (day == null) {
      return SizedBox(width: size, height: size);
    }
    if (day.isTracked) {
      return _Dot(
        size: size,
        fill: borderColor,
        border: borderColor,
        strokeWidth: stroke,
      );
    }
    return _Dot(
      size: size,
      fill: bgColor,
      border: borderColor,
      strokeWidth: stroke,
    );
  }
}