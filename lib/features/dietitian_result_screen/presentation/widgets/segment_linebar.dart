import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

enum ScoreZone { optimal, moderate, focus }

class SegmentedScoreBar extends StatelessWidget {
  final double score;
  final bool isRange1;

  const SegmentedScoreBar({
    super.key,
    required this.score,
    required this.isRange1,
  });

  ScoreZone get zone {
    final v = score.clamp(0.0, 100.0);

    if (isRange1) {
      if (v >= 80.0) return ScoreZone.optimal;
      if (v >= 70.0) return ScoreZone.moderate;
      return ScoreZone.focus;
    } else {
      if (v <= 20.0) return ScoreZone.optimal;
      if (v <= 30.0) return ScoreZone.moderate;
      return ScoreZone.focus;
    }
  }

  static String zoneText(ScoreZone z) {
    switch (z) {
      case ScoreZone.optimal:
        return "Optimal";
      case ScoreZone.moderate:
        return "Moderate";
      case ScoreZone.focus:
        return "Focus";
    }
  }

  static Color zoneColor(ScoreZone z) {
    switch (z) {
      case ScoreZone.optimal:
        return const Color(0xFF3FAF58);
      case ScoreZone.moderate:
        return const Color(0xFFFFBF2D);
      case ScoreZone.focus:
        return const Color(0xFFE48326);
    }
  }

  double mapScoreToSegment(double s) {
    final v = s.clamp(0.0, 100.0);

    if (isRange1) {
      // Visual scale: 0–70–80–100
      if (v < 70.0) return v / 70.0; // 0..1
      if (v < 80.0) return 1.0 + ((v - 70.0) / 10.0); // 1..2
      return 2.0 + ((v - 80.0) / 20.0); // 2..3
    } else {
      // Visual scale: 0–20–30–100
      if (v <= 20.0) return v / 20.0; // 0..1
      if (v <= 30.0) return 1.0 + ((v - 20.0) / 10.0); // 1..2
      return 2.0 + ((v - 30.0) / 70.0); // 2..3
    }
  }

  @override
  Widget build(BuildContext context) {
    final mappedValue = mapScoreToSegment(score).clamp(0.0, 3.0);

    return SizedBox(
      height: 70,
      child: SfLinearGauge(
        minimum: 0,
        maximum: 3,
        interval: 1,
        showTicks: false,
        showLabels: true,
        labelFormatterCallback: (label) {
          if (isRange1) {
            // 0–70–80–100
            switch (label) {
              case '0':
                return '0';
              case '1':
                return '70';
              case '2':
                return '80';
              case '3':
                return '100';
              default:
                return '';
            }
          } else {
            // 0–20–30–100
            switch (label) {
              case '0':
                return '0';
              case '1':
                return '20';
              case '2':
                return '30';
              case '3':
                return '100';
              default:
                return '';
            }
          }
        },
        axisTrackStyle: const LinearAxisTrackStyle(
          thickness: 2.5,
          edgeStyle: LinearEdgeStyle.bothCurve,
          color: Colors.transparent,
        ),
        ranges: isRange1
            ? const [
          LinearGaugeRange(
            startValue: 0,
            endValue: 1,
            color: Color(0xFFE48326), // Focus
            startWidth: 10,
            endWidth: 10,
          ),
          LinearGaugeRange(
            startValue: 1,
            endValue: 2,
            color: Color(0xFFFFBF2D), // Moderate
            startWidth: 10,
            endWidth: 10,
          ),
          LinearGaugeRange(
            startValue: 2,
            endValue: 3,
            color: Color(0xFF3FAF58), // Optimal
            startWidth: 10,
            endWidth: 10,
          ),
        ]
            : const [
          LinearGaugeRange(
            startValue: 0,
            endValue: 1,
            color: Color(0xFF3FAF58), // Optimal
            startWidth: 10,
            endWidth: 10,
          ),
          LinearGaugeRange(
            startValue: 1,
            endValue: 2,
            color: Color(0xFFFFBF2D), // Moderate
            startWidth: 10,
            endWidth: 10,
          ),
          LinearGaugeRange(
            startValue: 2,
            endValue: 3,
            color: Color(0xFFE48326), // Focus
            startWidth: 10,
            endWidth: 10,
          ),
        ],
        markerPointers: [
          LinearShapePointer(
            value: mappedValue,
            shapeType: LinearShapePointerType.diamond,
            color: Colors.black,
            height: 20,
            width: 8,
            position: LinearElementPosition.cross,
          ),
        ],
      ),
    );
  }
}
