// lib/features/test_conditions/presentation/widgets/test_conditions_bottom_cta.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/test_conditions_tokens.dart';

class TestConditionsBottomCta extends StatelessWidget {
  const TestConditionsBottomCta({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      color: TestConditionsTokens.white,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: TestConditionsTokens.white,
          boxShadow: [TestConditionsTokens.bottomShadow],
        ),
        padding: TestConditionsTokens.bottomPadding,
        child: Semantics(
          button: true,
          label: 'I remember',
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: TestConditionsTokens.ctaBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TestConditionsTokens.ctaRadius),
              ),
            ),
            child: Text(
              "I remember",
              style: GoogleFonts.poppins(
                color: TestConditionsTokens.white,
                fontSize: TestConditionsTokens.ctaTextSize,
                fontWeight: FontWeight.w700,
                height: TestConditionsTokens.ctaTextHeight,
                letterSpacing: TestConditionsTokens.ctaTextLetterSpacing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
