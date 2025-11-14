// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

// class SegmentedScoreBar extends StatelessWidget {
//   final double score; // actual score from 0 to 100

//   const SegmentedScoreBar({super.key, required this.score});

//   double mapScoreToSegment(double score) {
//     if (score <= 60) {
//       // map 0-60 => 0-1
//       return (score / 60) * 1;
//     } else if (score <= 80) {
//       // map 61-80 => 1-2
//       return 1 + ((score - 60) / 20) * 1;
//     } else {
//       // map 81-100 => 2-3
//       return 2 + ((score - 80) / 20) * 1;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double mappedValue = mapScoreToSegment(score);

//     return SizedBox(
//       height: 80,
//       child: SfLinearGauge(
//         minimum: 0,
//         maximum: 3,
//         interval: 1,
//         showTicks: false,
//         showLabels: true,
//         labelFormatterCallback: (label) {
//           switch (label) {
//             case '0':
//               return '0';
//             case '1':
//               return '60';
//             case '2':
//               return '80';
//             case '3':
//               return '100';
//             default:
//               return '';
//           }
//         },
//         axisTrackStyle: const LinearAxisTrackStyle(
//           thickness: 10,
//           edgeStyle: LinearEdgeStyle.bothCurve,
//           color: Colors.transparent,
//         ),
//         ranges: const [
//           LinearGaugeRange(
//             startValue: 0,
//             endValue: 1,
//             color: Colors.red,
//             startWidth: 10,
//             endWidth: 10,
//           ),
//           LinearGaugeRange(
//             startValue: 1,
//             endValue: 2,
//             color: Colors.orange,
//             startWidth: 10,
//             endWidth: 10,
//           ),
//           LinearGaugeRange(
//             startValue: 2,
//             endValue: 3,
//             color: Colors.green,
//             startWidth: 10,
//             endWidth: 10,
//           ),
//         ],
//         markerPointers: [
//           LinearShapePointer(
//             value: mappedValue,
//             shapeType: LinearShapePointerType.diamond,
//             color: Colors.black,
//             height: 20,
//             width: 8,
//             position: LinearElementPosition.cross,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SegmentedScoreBar extends StatelessWidget {
  final double score;
  final String metabolismSubtype;

  const SegmentedScoreBar({
    super.key,
    required this.score,
    required this.metabolismSubtype,
  });

  // Detect which type this is
  bool get isReverseType {
    final name = metabolismSubtype.toLowerCase();
    return name.contains('ferment') ||
        name.contains('glucose') ||
        name.contains('detox');
  }

  double mapScoreToSegment(double score) {
    if (isReverseType) {
      // 0–20–60–100 scale
      if (score <= 20) return (score / 20);
      if (score <= 60) return 1 + ((score - 20) / 40);
      return 2 + ((score - 60) / 40);
    } else {
      // 0–60–80–100 scale
      if (score <= 60) return (score / 60);
      if (score <= 80) return 1 + ((score - 60) / 20);
      return 2 + ((score - 80) / 20);
    }
  }

  String getScoreLabel() {
    if (isReverseType) {
      if (score <= 20) return 'Good';
      if (score <= 60) return 'Fair';
      return 'Poor';
    } else {
      if (score <= 60) return 'Poor';
      if (score <= 80) return 'Fair';
      return 'Good';
    }
  }

  Color getRangeColor(double start, double end) {
    if (isReverseType) {
      // Reverse types: green → orange → red
      if (score <= 20) return Colors.green;
      if (score <= 60) return Colors.orange;
      return Colors.red;
    } else {
      // Normal types: red → orange → green
      if (score <= 60) return Colors.red;
      if (score <= 80) return Colors.orange;
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("lineScore: $score");
    print("linemetabolismSubtype: $metabolismSubtype");
    final double mappedValue = mapScoreToSegment(score).clamp(0, 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 70,
          child: SfLinearGauge(
            minimum: 0,
            maximum: 3,
            interval: 1,
            showTicks: false,
            showLabels: true,
            labelFormatterCallback: (label) {
              if (isReverseType) {
                switch (label) {
                  case '0':
                    return '0';
                  case '1':
                    return '20';
                  case '2':
                    return '60';
                  case '3':
                    return '100';
                }
              } else {
                switch (label) {
                  case '0':
                    return '0';
                  case '1':
                    return '60';
                  case '2':
                    return '80';
                  case '3':
                    return '100';
                }
              }
              return '';
            },
            axisTrackStyle: const LinearAxisTrackStyle(
              thickness: 2.5,
              edgeStyle: LinearEdgeStyle.bothCurve,
              color: Colors.transparent,
            ),
            ranges: [
              LinearGaugeRange(
                startValue: 0,
                endValue: 1,
                color: isReverseType ? Colors.green : Colors.red,
                startWidth: 10,
                endWidth: 10,
              ),
              LinearGaugeRange(
                startValue: 1,
                endValue: 2,
                color: Colors.orange,
                startWidth: 10,
                endWidth: 10,
              ),
              LinearGaugeRange(
                startValue: 2,
                endValue: 3,
                color: isReverseType ? Colors.red : Colors.green,
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
        ),
      ],
    );
  }
}
