import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:respyr_dietitian/features/habit_tracking/data/model/client_habit_status_response_model.dart';

/// Position + size of a single bubble in screen coordinates.
@immutable
class BubblePlacement {
  final double cx;
  final double cy;
  final double r;

  const BubblePlacement({required this.cx, required this.cy, required this.r});

  Offset get topLeft => Offset(cx - r, cy - r);
  double get diameter => r * 2;
}

/// Computes scattered bubble placements using fixed slot anchors with
/// runtime overlap resolution.
///
/// The slot list is ordered "most prominent first". When fewer than 5
/// bubbles are active, we use the FIRST N slots — the cluster always
/// looks balanced because the most important slots are kept.
///
/// After placing bubbles in their slots, an iterative relaxation pass
/// pushes any overlapping bubbles apart along the line between their
/// centers, so they always have a visible gap.
class BubbleLayout {
  BubbleLayout._();

  /// Inner padding inside the layout area — bubbles never enter this zone.
  static const double padX = 8.0;
  static const double padY = 8.0;

  /// Required visible gap between any two bubbles, in pixels.
  static const double minBubbleGap = 8.0;

  /// Max iterations of overlap resolution. Converges in a handful of passes.
  static const int relaxIterations = 12;

  /// [cxFrac, cyFrac, sizeFrac] — fractions of container width/height.
  /// Tuned so any two bubbles always have a visible gap, on phone widths
  /// from ~320px upward.
  static const List<List<double>> _slotAnchors = [
    // Slot 0 — top-left BIG bubble
    [0.32, 0.24, 0.58],
    // Slot 1 — middle-right BIG bubble
    [0.71, 0.55, 0.52],
    // Slot 2 — top-right medium bubble
    [0.80, 0.14, 0.34],
    // Slot 3 — bottom-center medium bubble
    [0.40, 0.84, 0.34],
    // Slot 4 — middle-left small bubble
    [0.14, 0.62, 0.25],
  ];

  /// Lays out [habits] into bubbles inside a [width] × [height] area.
  ///
  /// Habits are sorted by name length (longest first) and assigned to
  /// the most prominent slots first.
  static List<BubblePlacement> compute({
    required List<ClientHabitData> habits,
    required double width,
    required double height,
  }) {
    final int count = habits.length;
    if (count == 0) return const [];

    final List<int> order = _sortByNameLength(habits);
    final List<List<double>> activeSlots =
    _slotAnchors.take(count).toList(growable: false);

    // Build initial placement from slot anchors.
    final List<double> cxs = List<double>.filled(count, 0);
    final List<double> cys = List<double>.filled(count, 0);
    final List<double> rs = List<double>.filled(count, 1);

    for (int slotIdx = 0; slotIdx < activeSlots.length; slotIdx++) {
      final List<double> slot = activeSlots[slotIdx];
      final int habitIdx = order[slotIdx];

      cxs[habitIdx] = slot[0] * width;
      cys[habitIdx] = slot[1] * height;
      rs[habitIdx] = (slot[2] * width) / 2;
    }

    _resolveOverlaps(cxs: cxs, cys: cys, rs: rs, width: width, height: height);

    return List<BubblePlacement>.generate(
      count,
          (i) => BubblePlacement(cx: cxs[i], cy: cys[i], r: rs[i]),
    );
  }

  /// Returns indices of [habits] sorted longest-name-first.
  static List<int> _sortByNameLength(List<ClientHabitData> habits) {
    return List<int>.generate(habits.length, (i) => i)
      ..sort((a, b) =>
          habits[b].habitName.length.compareTo(habits[a].habitName.length));
  }

  /// Iteratively pushes overlapping bubbles apart, then re-clamps to area.
  static void _resolveOverlaps({
    required List<double> cxs,
    required List<double> cys,
    required List<double> rs,
    required double width,
    required double height,
  }) {
    final int count = cxs.length;

    for (int iter = 0; iter < relaxIterations; iter++) {
      bool moved = false;

      for (int i = 0; i < count; i++) {
        for (int j = i + 1; j < count; j++) {
          final double dx = cxs[j] - cxs[i];
          final double dy = cys[j] - cys[i];
          double dist = sqrt(dx * dx + dy * dy);

          // Avoid divide-by-zero if two centers happen to coincide.
          if (dist < 0.001) {
            cxs[j] += 1.0;
            dist = 1.0;
          }

          final double minDist = rs[i] + rs[j] + minBubbleGap;
          if (dist < minDist) {
            final double overlap = (minDist - dist) / 2;
            final double nx = dx / dist;
            final double ny = dy / dist;

            cxs[i] -= nx * overlap;
            cys[i] -= ny * overlap;
            cxs[j] += nx * overlap;
            cys[j] += ny * overlap;
            moved = true;
          }
        }
      }

      // Keep bubbles inside the padded area after pushing.
      for (int i = 0; i < count; i++) {
        cxs[i] = cxs[i].clamp(padX + rs[i], width - padX - rs[i]);
        cys[i] = cys[i].clamp(padY + rs[i], height - padY - rs[i]);
      }

      if (!moved) break;
    }
  }
}