import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/account_subscription/services/check_client_plan_service.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';

class DashboardParams {
  final ClientProfileModel clientProfile;
  final DietitianDetailModel? dietitianDetailModel;
  final CheckClientPlanResponse planData;
  final UserHabitsModel? userHabitsModel;
  final double currentMinRange;
  final double currentMaxRange;
  DashboardParams({required this.clientProfile, this.dietitianDetailModel, required this.planData, this.userHabitsModel, required this.currentMinRange, required this.currentMaxRange});
}