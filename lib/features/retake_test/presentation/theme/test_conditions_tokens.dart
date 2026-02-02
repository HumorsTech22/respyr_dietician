// lib/features/test_conditions/presentation/theme/test_conditions_tokens.dart
import 'package:flutter/material.dart';

sealed class TestConditionsTokens {
  static const Color appBarBlue = Color(0xFF1879EE);
  static const Color dark = Color(0xFF252525);
  static const Color white = Colors.white;

  static const List<Color> gradientColors = <Color>[appBarBlue, dark];
  static const List<double> gradientStops = <double>[0.0003, 0.5622];

  static const EdgeInsets headerPadding = EdgeInsets.symmetric(horizontal: 17);
  static const EdgeInsets sheetPadding =
  EdgeInsets.symmetric(horizontal: 17, vertical: 35);

  static const SizedBox headerGap20 = SizedBox(height: 20);
  static const SizedBox headerGap40 = SizedBox(height: 40);

  static const double headerTitleSize = 34;
  static const double headerTitleLetterSpacing = -2.04;

  static const double headerSubtitleSize = 15;
  static const double headerSubtitleLetterSpacing = -0.30;

  static const double itemTitleSize = 18;
  static const double itemTitleLetterSpacing = -0.72;

  static const double itemBodySize = 12;
  static const double itemBodyLetterSpacing = -0.24;
  static const double itemBodyHeight = 1.30;

  static const double sheetTopRadius = 15;

  // Keep these EXACT since you hardcoded them
  static const double sheetWidth = 375;
  static const double sheetHeight = 612;

  static const EdgeInsets bottomPadding =
  EdgeInsets.symmetric(horizontal: 13, vertical: 10);

  static const double ctaRadius = 50;
  static const Color ctaBg = dark;

  static const double ctaTextSize = 15;
  static const double ctaTextLetterSpacing = 0.30;
  static const double ctaTextHeight = 1.10;

  static const BoxShadow bottomShadow = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 6,
    offset: Offset(0, -4),
    spreadRadius: 0,
  );

  static const double itemsColumnSpacing = 30;
  static const double rowSpacing = 20;
  static const double itemTextSpacing = 10;
}
