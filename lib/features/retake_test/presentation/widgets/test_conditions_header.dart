// lib/features/test_conditions/presentation/widgets/test_conditions_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/test_conditions_tokens.dart';

class TestConditionsHeader extends StatelessWidget {
  const TestConditionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: TestConditionsTokens.headerPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Remember",
            style: GoogleFonts.poppins(
              color: TestConditionsTokens.white,
              fontSize: TestConditionsTokens.headerTitleSize,
              fontWeight: FontWeight.w400,
              letterSpacing: TestConditionsTokens.headerTitleLetterSpacing,
              height: 1.0,
            ),
          ),
          TestConditionsTokens.headerGap20,
          Text(
            "Best conditions to take the test",
            style: GoogleFonts.poppins(
              color: TestConditionsTokens.white,
              fontSize: TestConditionsTokens.headerSubtitleSize,
              fontWeight: FontWeight.w400,
              height: 1.0,
              letterSpacing: TestConditionsTokens.headerSubtitleLetterSpacing,
            ),
          ),
          TestConditionsTokens.headerGap40,
        ],
      ),
    );
  }
}
