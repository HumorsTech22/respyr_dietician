
import 'package:flutter/material.dart';

class ColorManager {

  static Color getZoneColor({required String zone}) {
    switch (zone.toLowerCase()) {
      case "poor":
        return const Color(0xFFDA5747); // red
      case "fair":
        return const Color(0xFFF8B10F); // yellow
      case "good":
        return const Color(0xFF3FAF58); // green
      default:
        return Colors.grey;
    }
  }

  static Color getZoneColorByScore({required double score}) {
    if (score < 60) {
      return const Color(0xFFDA5747); // red for Poor (0-59)
    } else if (score >= 60 && score < 80) {
      return const Color(0xFFF8B10F); // yellow for Fair (60-79)
    } else if (score >= 80 && score <= 100) {
      return const Color(0xFF3FAF58); // green for Good (80-100)
    } else {
      return Colors.grey; // for any score outside 0-100 range
    }
  }
}