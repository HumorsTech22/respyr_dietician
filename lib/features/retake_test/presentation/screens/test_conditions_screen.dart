import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../routes/app_routes.dart';
import '../theme/test_conditions_tokens.dart';
import '../widgets/test_conditions_bottom_cta.dart';
import '../widgets/test_conditions_header.dart';
import '../widgets/test_conditions_sheet.dart';

class TestConditionsScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  const TestConditionsScreen({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

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
              onPressed: () => _navigateToDashboard(context),
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
      bottomNavigationBar: TestConditionsBottomCta(
        confirmedToNavigate: () => _navigateToBluetooth(context),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context) {
    context.go(
      AppRoutes.clientDashboard,
      extra: clientProfileModel,
    );
  }

  void _navigateToBluetooth(BuildContext context) {
    context.go(
      AppRoutes.bluetoothDeviceConnectivity,
      extra: <String, Object?>{
        "client": clientProfileModel,
        "strategy": dietPlanStrategyModel,
        "min_range": minRange,
        "max_range": maxRange,
      },
    );
  }
}
