import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/features_allow/data/model/features_allow_model.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';

class CalibrationParams {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final FeaturesAllowData featuresAllowData;
  final UserHabitsModel userHabitsModel;

  CalibrationParams({required this.clientProfileModel, required this.dietPlanStrategyModel, required this.minRange, required this.maxRange, required this.featuresAllowData, required this.userHabitsModel});
}