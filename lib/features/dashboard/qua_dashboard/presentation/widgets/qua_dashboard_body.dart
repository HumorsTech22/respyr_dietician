import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/country/presentation/widgets/country_sheet.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/bloc/latest_test_bloc.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/bloc/latest_test_state.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/core/color_manager.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/models/latest_test_data.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/controllers/qua_dashboard_controller.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/diet_hero_view.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/qua_dashboard_gradient_header.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/qua_dashboard_swipe_action_overlay.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/dietitian_info.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/score_chart.dart';
import 'package:respyr_dietitian/features/habit_tracking/update_habits/presentation/widgets/client_today_habits_widget.dart';
import 'package:respyr_dietitian/features/habit_tracking/update_habits/presentation/widgets/today_habit_bubble_card.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/today_to_do_list.dart';
import 'package:respyr_dietitian/features/habit_tracking/bloc/client_habit_cubit.dart';
import 'package:respyr_dietitian/features/habit_tracking/bloc/client_habit_state.dart';
import 'package:respyr_dietitian/features/habit_tracking/repoistory/client_habit_repository.dart';
import 'package:respyr_dietitian/features/habit_tracking/services/client_habit_service.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import 'macro_distribution_chart.dart';
import 'nutrition_analysis.dart';

class QuaDashboardBody extends StatelessWidget {
  final QuaDashboardController controller;

  const QuaDashboardBody({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final now = DateTime.now();

        if (controller.lastBackPressed == null ||
            now.difference(controller.lastBackPressed!) >
                const Duration(seconds: 2)) {
          controller.lastBackPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press back again to exit"),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: BlocBuilder<LatestTestBloc, LatestTestState>(
        buildWhen: (prev, curr) =>
        prev.runtimeType != curr.runtimeType || curr is LatestTestLoaded,
        builder: (context, state) {
          final LatestTestData? testData =
          state is LatestTestLoaded ? state.data : null;

          final bool hasData = testData != null;
          final String? zone = testData?.testJsonData?.primaryTrend.zone;

          final Color themeColor = (hasData && zone != null)
              ? ColorManager.getZoneColor(zone: zone)
              : const Color(0xFFA5A9AF);

          final double minRange =
              testData?.minRange ?? controller.dashboardParams.currentMinRange;
          final double maxRange =
              testData?.maxRange ?? controller.dashboardParams.currentMaxRange;
          final double latestScore =
              testData?.testJsonData?.primaryTrend.score ?? 0.0;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: themeColor,
              toolbarHeight: 0,
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  RefreshIndicator(
                    color: const Color(0xFF308BF9),
                    backgroundColor: Colors.white,
                    onRefresh: () => controller.refreshDataAsync(force: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QuaDashboardGradientHeader(
                            color: themeColor,
                            hasData: hasData,
                            data: testData,
                            clientProfile: controller.dashboardParams.clientProfile,
                            selectedDate: controller.selectedDate,
                            dateList: controller.dateList,
                            onDateSelected: controller.setSelectedDate,
                            planData: controller.dashboardParams.planData,
                            userHabitsModel: controller.dashboardParams.userHabitsModel,
                          ),
                          if (hasData)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    controller.navigateToDetailedResult(testData.testId);
                                  },
                                  child: Text(
                                    "Know More",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF308BF9),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      height: 1.10,
                                      letterSpacing: 0.30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 100),
                          ScoreChart(
                            clientProfileModel: controller.dashboardParams.clientProfile,
                            latestScore: latestScore,
                            latestScoreMinRange: minRange,
                            latestScoreMaxRange: maxRange,
                          ),





                         if(hasData)...[
                           SizedBox(height: rh(context: context, px: 50)),
                           NutritionAnalysis(
                             clientProfileModel: controller.dashboardParams.clientProfile,
                           )
                         ],

                          ElevatedButton(
                              onPressed: (){
                                context.push(
                                  AppRoutes.habitAnalysisScreen,
                                  extra: controller.dashboardParams.clientProfile
                                );
                              },
                              child: Text("Habits")
                          ),



                          SizedBox(height: rh(context: context, px: 35)),

                          ClientTodayHabitsWidget(
                            profileId: controller.dashboardParams.clientProfile.profileId,
                            trackingDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          ),

                           SizedBox(height: rh(context: context, px: 200)),
                        ],
                      ),
                    ),
                  ),

                  QuaDashboardSwipeActionOverlay(
                    clientProfile: controller.dashboardParams.clientProfile,
                    onSwiped: (testState) => controller.handleStartTest(testState),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}