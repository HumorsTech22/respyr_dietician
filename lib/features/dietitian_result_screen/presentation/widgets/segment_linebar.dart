import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SegmentedScoreBar extends StatelessWidget {
  final double score; // actual score from 0 to 100

  const SegmentedScoreBar({super.key, required this.score});

  double mapScoreToSegment(double score) {
    if (score <= 60) {
      // map 0-60 => 0-1
      return (score / 60) * 1;
    } else if (score <= 80) {
      // map 61-80 => 1-2
      return 1 + ((score - 60) / 20) * 1;
    } else {
      // map 81-100 => 2-3
      return 2 + ((score - 80) / 20) * 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double mappedValue = mapScoreToSegment(score);

    return SizedBox(
      height: 80,
      child: SfLinearGauge(
        minimum: 0,
        maximum: 3,
        interval: 1,
        showTicks: false,
        showLabels: true,
        labelFormatterCallback: (label) {
          switch (label) {
            case '0':
              return '0';
            case '1':
              return '60';
            case '2':
              return '80';
            case '3':
              return '100';
            default:
              return '';
          }
        },
        axisTrackStyle: const LinearAxisTrackStyle(
          thickness: 10,
          edgeStyle: LinearEdgeStyle.bothCurve,
          color: Colors.transparent,
        ),
        ranges: const [
          LinearGaugeRange(
            startValue: 0,
            endValue: 1,
            color: Colors.red,
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
            color: Colors.green,
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
