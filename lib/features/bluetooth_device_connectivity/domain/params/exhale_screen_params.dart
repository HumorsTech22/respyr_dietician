import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';

class ExhaleScreenParams {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final String baseValue;

  ExhaleScreenParams({
    required this.clientProfileModel,
    required this.baseValue,
    required this.dietPlanStrategyModel,
  });
}
