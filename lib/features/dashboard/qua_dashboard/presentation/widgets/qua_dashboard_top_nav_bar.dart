import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/utils/date_helper.dart';
import 'package:respyr_dietitian/features/account_subscription/services/check_client_plan_service.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/qua_dashboard_profile_circle.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';

class QuaDashboardTopNavBar extends StatelessWidget {
  final ClientProfileModel clientProfile;
  final CheckClientPlanResponse planData;
  final UserHabitsModel? userHabitsModel;

  const QuaDashboardTopNavBar({
    super.key,
    required this.clientProfile,
    required this.planData,
    this.userHabitsModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clientProfile.profileName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Text(
                DateHelper.getGreeting(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          QuaDashboardProfileCircle(
            clientProfile: clientProfile,
            planData: planData,
            userHabitsModel: userHabitsModel,
          ),
        ],
      ),
    );
  }
}