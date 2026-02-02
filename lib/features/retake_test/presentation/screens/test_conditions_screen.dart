import 'package:flutter/material.dart';

import '../theme/test_conditions_tokens.dart';
import '../widgets/test_conditions_bottom_cta.dart';
import '../widgets/test_conditions_header.dart';
import '../widgets/test_conditions_sheet.dart';

class TestConditionsScreen extends StatelessWidget {
  const TestConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TestConditionsTokens.appBarBlue,
        actions: [
          Semantics(
            button: true,
            label: 'Close',
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: TestConditionsTokens.gradientColors,
              stops: TestConditionsTokens.gradientStops,
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TestConditionsHeader(),
              Expanded(child: TestConditionsSheet()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TestConditionsBottomCta(),
    );
  }
}
