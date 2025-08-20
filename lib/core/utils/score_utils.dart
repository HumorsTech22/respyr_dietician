import 'package:flutter/material.dart';

enum ScoreLevel { poor, fair, good }

class ScoreInfo {
  final String label;
  final Color color;

  const ScoreInfo({required this.label, required this.color});
}

/// Determines score level and provides label & color
ScoreInfo getScoreLevel(double score) {
  if (score >= 0 && score <= 60) {
    return const ScoreInfo(label: 'Poor', color: Color(0xFFEA5455)); // Red
  } else if (score >= 61 && score <= 79) {
    return const ScoreInfo(label: 'Fair', color: Color(0xFFFFC412)); // Yellow
  } else if (score >= 80 && score <= 100) {
    return const ScoreInfo(label: 'Good', color: Color(0xFF3EAF58)); // Green
  } else {
    return const ScoreInfo(label: 'Invalid', color: Colors.grey);
  }
}

class ScoreColorHelper {
  static Color getScoreColor(double score) {
    if (score >= 80.0 && score <= 100.0) {
      return const Color(0xFF3EAF58); // Green - Good
    } else if (score >= 70.0 && score < 80.0) {
      return const Color(0xFFFFC412); // Yellow - Fair
    } else {
      return const Color(0xFFEA5455); // Red - Poor
    }
  }

  static List<Color> getLinearScoreColor(double score) {
    if (score >= 80.0 && score <= 100.0) {
      return [const Color(0xFF3FAF58), const Color(0xFF009245)];
    } else if (score >= 70.0 && score < 80.0) {
      return [const Color(0xFFFFC412), const Color(0xFFE3AC06)];
    } else {
      return [const Color(0xFFEA5455), const Color(0xFFC1272D)];
    }
  }
}
