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
