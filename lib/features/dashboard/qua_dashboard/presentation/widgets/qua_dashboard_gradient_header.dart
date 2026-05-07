import 'package:flutter/material.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/account_subscription/services/check_client_plan_service.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/models/latest_test_data.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/hero_calender_widget.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/qua_dashboard_no_data_prompt.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/qua_dashboard_score_display.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/qua_dashboard_top_nav_bar.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/qua_dashboard_zone_info_card.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';

class QuaDashboardGradientHeader extends StatelessWidget {
  final Color color;
  final bool hasData;
  final LatestTestData? data;
  final ClientProfileModel clientProfile;
  final DateTime selectedDate;
  final List<DateTime> dateList;
  final ValueChanged<DateTime> onDateSelected;
  final CheckClientPlanResponse planData;
  final UserHabitsModel? userHabitsModel;

  const QuaDashboardGradientHeader({
    super.key,
    required this.color,
    required this.hasData,
    required this.data,
    required this.clientProfile,
    required this.selectedDate,
    required this.dateList,
    required this.onDateSelected,
    required this.planData,
    this.userHabitsModel,
  });

  @override
  Widget build(BuildContext context) {
    final scoreObj = data?.testJsonData?.primaryTrend;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.50, 0.00),
          end: const Alignment(0.50, 1.00),
          colors: [color, Colors.white],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            QuaDashboardTopNavBar(
              clientProfile: clientProfile,
              planData: planData,
              userHabitsModel: userHabitsModel,
            ),
            HeroCalenderWidget(
              selectedDate: selectedDate,
              onDateSelected: onDateSelected,
              dateList: dateList,
            ),
            const SizedBox(height: 40),
            if (hasData && scoreObj != null) ...[
              QuaDashboardScoreDisplay(primaryTrend: scoreObj),
              const SizedBox(height: 60),
              QuaDashboardZoneInfoCard(
                themeColor: color,
                primaryTrend: scoreObj,
              ),
            ] else ...[
              const SizedBox(height: 40),
              QuaDashboardNoDataPrompt(selectedDate: selectedDate),
            ],
          ],
        ),
      ),
    );
  }
}