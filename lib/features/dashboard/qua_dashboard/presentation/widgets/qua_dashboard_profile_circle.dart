import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/account_subscription/services/check_client_plan_service.dart';
import 'package:respyr_dietitian/features/dashboard/menu/presentation/screens/menu.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';

class QuaDashboardProfileCircle extends StatelessWidget {
  final ClientProfileModel clientProfile;
  final CheckClientPlanResponse planData;
  final UserHabitsModel? userHabitsModel;

  const QuaDashboardProfileCircle({
    super.key,
    required this.clientProfile,
    required this.planData,
    this.userHabitsModel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final UserHabitsModel safeHabitsModel =
            userHabitsModel ??
                UserHabitsModel(
                  id: 0,
                  profileId: clientProfile.profileId,
                  goal: "not_available",
                  activity: "not_available",
                  foodType: FoodTypeModel(
                    dietType: "not_available",
                    primaryCuisine: "not_available",
                    secondaryCuisine: "not_available",
                  ),
                  dateTime: "",
                  timeStamp: "",
                );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardMenuScreen(
              clientProfileModel: clientProfile,
              planData: planData,
              userHabitsModel: safeHabitsModel,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          "assets/images/icons/ic_profile.svg",
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}