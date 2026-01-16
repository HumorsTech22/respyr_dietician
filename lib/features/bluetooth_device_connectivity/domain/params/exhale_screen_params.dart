import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';

class ExhaleScreenParams {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final String baseValue;
  final double minRange;
  final double maxRange;

  ExhaleScreenParams({
    required this.clientProfileModel,
    required this.baseValue,
    required this.dietPlanStrategyModel, required this.minRange, required this.maxRange,
  });
}
