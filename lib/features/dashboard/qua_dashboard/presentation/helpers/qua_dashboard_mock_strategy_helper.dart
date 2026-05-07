import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/dietitian_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';

DietPlanStrategyModel generateMockStrategy({
  required ClientProfileModel clientProfile,
  required DietitianDetailModel? dietitianDetailModel,
}) {
  return DietPlanStrategyModel(
    id: -1,
    dietitianId: clientProfile.dietitianId.toString(),
    clientId: clientProfile.profileId.toString(),
    planTitle: "Standard Metabolism Protocol",
    dietType: "Balanced",
    planStartDate: DateTime.now(),
    planEndDate: DateTime.now().add(const Duration(days: 30)),
    updatedAt: DateTime.now(),
    caloriesTarget: 2000,
    proteinTarget: 150,
    fiberTarget: 30,
    carbsTarget: 200,
    fatTarget: 70,
    waterTarget: 3.5,
    testNoAssigned: 1,
    isDiabetic: false,
    status: "active",
    goals: const [],
    approaches: const [],
    dietitianInfo: DietitianModel(
      id: 0,
      dietitianId: "N/A",
      name: dietitianDetailModel?.name ?? "Dietitian",
      email: "",
      phoneNo: "",
      location: "",
      logo: "",
      dttm: "",
      password: "",
    ),
  );
}