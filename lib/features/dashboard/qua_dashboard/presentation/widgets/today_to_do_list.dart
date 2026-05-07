import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodayToDoList extends StatefulWidget {
  const TodayToDoList({super.key});

  @override
  State<TodayToDoList> createState() => _TodayToDoListState();
}

class _TodayToDoListState extends State<TodayToDoList> {
  final Set<int> poppedIndexes = {};
  final Map<int, Offset> previousPositions = {};

  List<double>? _cachedSizes;
  List<double>? _cachedTitleSizes;

  final List<HabitBubbleData> habits = [
    HabitBubbleData(
      title: "Hit daily\nprotein goal",
      subtitle: "Everyday",
      color: const Color(0xFFFFF176).withOpacity(.55),
      textColor: const Color(0xFF8C8100),
    ),
    HabitBubbleData(
      title: "Stop eating\nafter 9 PM",
      subtitle: "Everyday",
      color: const Color(0xFFA8DDB5).withOpacity(.55),
      textColor: const Color(0xFF078C21),
    ),
    HabitBubbleData(
      title: "Cardio",
      subtitle: "3 x week",
      color: const Color(0xFFFFB6B6).withOpacity(.55),
      textColor: const Color(0xFFB92525),
    ),
    HabitBubbleData(
      title: "Grocery\nshopping",
      subtitle: "1 x week",
      color: const Color(0xFFBBD6F6).withOpacity(.65),
      textColor: const Color(0xFF1E5AA5),
    ),
    HabitBubbleData(
      title: "No screens 30\nmin..",
      subtitle: "Everyday",
      color: const Color(0xFFB9F3F2).withOpacity(.65),
      textColor: const Color(0xFF15989A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final int completedCount = poppedIndexes.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Habits",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Today's To-do List",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F7FA),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 5, color: Color(0xFFE1E6ED)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 432,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      final double height = constraints.maxHeight;

                      // Cache sizes on first build only
                      _cachedSizes ??= List<double>.generate(
                        habits.length,
                            (index) => _bubbleSize(habits[index], width),
                      );
                      _cachedTitleSizes ??= List<double>.generate(
                        habits.length,
                            (index) => _dynamicTitleSize(
                          habits[index],
                          _cachedSizes![index],
                        ),
                      );

                      final List<int> visibleIndexes =
                      List<int>.generate(habits.length, (index) => index)
                          .where((index) => !poppedIndexes.contains(index))
                          .toList();

                      final List<double> sizes = visibleIndexes
                          .map((index) => _cachedSizes![index])
                          .toList();

                      final List<Offset> positions = _placeNonOverlapping(
                        sizes: sizes,
                        width: width,
                        height: height,
                      );

                      return Stack(
                        children: List.generate(visibleIndexes.length, (i) {
                          final int habitIndex = visibleIndexes[i];
                          final HabitBubbleData habit = habits[habitIndex];
                          final double size = _cachedSizes![habitIndex];
                          final double titleSize =
                          _cachedTitleSizes![habitIndex];

                          final Offset newPosition = positions[i];
                          final Offset? oldPosition =
                          previousPositions[habitIndex];

                          final bool isFallingDown =
                              oldPosition != null &&
                                  newPosition.dy > oldPosition.dy + 2;

                          previousPositions[habitIndex] = newPosition;

                          return AnimatedPositioned(
                            key: ValueKey(habitIndex),
                            duration: Duration(
                              milliseconds: isFallingDown ? 900 : 480,
                            ),
                            curve: isFallingDown
                                ? const Cubic(0.18, 0.89, 0.32, 1.28)
                                : Curves.easeOutCubic,
                            left: newPosition.dx,
                            top: newPosition.dy,
                            child: BubblePopItem(
                              key: ValueKey("bubble_$habitIndex"),
                              item: habit,
                              size: size,
                              titleSize: titleSize,
                              onPopCompleted: () {
                                if (!mounted) return;
                                setState(() {
                                  poppedIndexes.add(habitIndex);
                                  previousPositions.remove(habitIndex);
                                });
                              },
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                Container(
                  height: 87,
                  padding: const EdgeInsets.all(5),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 242,
                          height: 87,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: 20,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            "$completedCount/${habits.length} completed",
                            key: ValueKey(completedCount),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 40,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.80,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Offset> _placeNonOverlapping({
    required List<double> sizes,
    required double width,
    required double height,
  }) {
    final int count = sizes.length;
    if (count == 0) return [];

    final List<double> radii = sizes.map((size) => size / 2).toList();

    const double gap = 8.0;
    const double padding = 8.0;

    final List<int> sortedIndexes = List<int>.generate(count, (index) => index)
      ..sort((a, b) => radii[b].compareTo(radii[a]));

    final List<Offset?> centers = List<Offset?>.filled(count, null);

    for (final int index in sortedIndexes) {
      final double radius = radii[index];

      Offset? bestCenter;
      double bestScore = double.infinity;

      for (double y = height - radius - padding;
      y >= radius + padding;
      y -= 5) {
        for (double x = radius + padding;
        x <= width - radius - padding;
        x += 5) {
          final Offset candidate = Offset(x, y);
          bool isValid = true;

          for (int placedIndex = 0; placedIndex < count; placedIndex++) {
            final Offset? placedCenter = centers[placedIndex];
            if (placedCenter == null) continue;

            final double distance = (candidate - placedCenter).distance;
            final double minDistance = radius + radii[placedIndex] + gap;

            if (distance < minDistance) {
              isValid = false;
              break;
            }
          }

          if (!isValid) continue;

          final double centerX = width / 2;
          final double score =
              (height - candidate.dy) * 100 + (candidate.dx - centerX).abs();

          if (score < bestScore) {
            bestScore = score;
            bestCenter = candidate;
          }
        }
      }

      centers[index] = bestCenter ??
          Offset(
            radius + padding,
            height - radius - padding,
          );
    }

    final List<Offset> resultCenters =
    centers.map((center) => center ?? Offset.zero).toList();

    for (int loop = 0; loop < 350; loop++) {
      bool hasOverlap = false;

      for (int i = 0; i < count; i++) {
        for (int j = i + 1; j < count; j++) {
          final Offset delta = resultCenters[j] - resultCenters[i];
          final double distance = delta.distance;
          final double minDistance = radii[i] + radii[j] + gap;

          if (distance < minDistance) {
            hasOverlap = true;

            if (distance > 0.001) {
              final double overlap = (minDistance - distance) / 2;
              final Offset direction = delta / distance;

              resultCenters[i] = resultCenters[i] - direction * overlap;
              resultCenters[j] = resultCenters[j] + direction * overlap;
            } else {
              resultCenters[j] = resultCenters[j] + Offset(minDistance, 0);
            }
          }
        }
      }

      for (int i = 0; i < count; i++) {
        final double radius = radii[i];

        resultCenters[i] = Offset(
          resultCenters[i]
              .dx
              .clamp(radius + padding, width - radius - padding)
              .toDouble(),
          resultCenters[i]
              .dy
              .clamp(radius + padding, height - radius - padding)
              .toDouble(),
        );
      }

      if (!hasOverlap) break;
    }

    return List<Offset>.generate(count, (index) {
      return Offset(
        resultCenters[index].dx - radii[index],
        resultCenters[index].dy - radii[index],
      );
    });
  }

  double _bubbleSize(HabitBubbleData item, double maxWidth) {
    final int titleLength = item.title.replaceAll('\n', '').length;

    if (titleLength <= 8) return 95;
    if (titleLength <= 16) return 132;
    if (titleLength <= 24) return 168;
    if (titleLength <= 34) return 198;

    return min(220, maxWidth * 0.62).toDouble();
  }

  double _dynamicTitleSize(HabitBubbleData item, double bubbleSize) {
    final List<String> lines = item.title.split('\n');

    final int longestLine =
        lines.reduce((a, b) => a.length > b.length ? a : b).length;

    final double usableWidth = bubbleSize * 0.64;
    final double fontByWidth = usableWidth / (longestLine * 0.55);

    final double usableHeight = bubbleSize * 0.46;
    final double fontByHeight = usableHeight / max(lines.length, 1);

    return min(fontByWidth, fontByHeight).clamp(14, 34).toDouble();
  }
}

class BubblePopItem extends StatefulWidget {
  final HabitBubbleData item;
  final double size;
  final double titleSize;
  final VoidCallback onPopCompleted;

  const BubblePopItem({
    super.key,
    required this.item,
    required this.size,
    required this.titleSize,
    required this.onPopCompleted,
  });

  @override
  State<BubblePopItem> createState() => _BubblePopItemState();
}

class _BubblePopItemState extends State<BubblePopItem> {
  bool isPopping = false;

  Future<void> _popBubble() async {
    if (isPopping) return;

    setState(() {
      isPopping = true;
    });

    await Future.delayed(const Duration(milliseconds: 240));

    if (!mounted) return;

    widget.onPopCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _popBubble,
      child: AnimatedScale(
        scale: isPopping ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: isPopping ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          child: Container(
            width: widget.size,
            height: widget.size,
            padding: EdgeInsets.all(widget.size * 0.18),
            decoration: BoxDecoration(
              color: widget.item.color,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.item.title,
                      style: GoogleFonts.poppins(
                        color: widget.item.textColor,
                        fontSize: widget.titleSize,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: -0.30,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.item.subtitle,
                      style: GoogleFonts.poppins(
                        color: widget.item.textColor,
                        fontSize: widget.titleSize * 0.45,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HabitBubbleData {
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;

  HabitBubbleData({
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.color,
  });
}