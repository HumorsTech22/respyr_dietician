import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../data/model/diet_plan_strategy_model.dart';
import '../../extras/date_helper.dart';
import '../widgets/goal_item.dart';
import '../widgets/your_log.dart';


class DietPlanOverview extends StatefulWidget {
  final List<DietPlanStrategyModel> activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;
  final ClientProfileModel clientProfileModel;
  const DietPlanOverview({
    super.key,
    required this.activeData,
    required this.completedData,
    required this.canceledData,
    required this.clientProfileModel,
  });

  @override
  State<DietPlanOverview> createState() => _DietPlanOverviewState();
}

class _DietPlanOverviewState extends State<DietPlanOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Color(0xFFF5F7FA),
          surfaceTintColor: Color(0xFFF5F7FA),
          title: Row(
            children: [
              Text(
                "Active Plan",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.30,
                ),
              )
            ],
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.activeData.asMap().entries.map((entry) {
                      final dietPlanStrategyModel = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dietPlanStrategyModel.planTitle,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 34,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -2.04,
                                  ),
                                ),
                                Text(
                                  "${formatToDayMonth(dietPlanStrategyModel.planStartDate)} - ${formatToDayMonth(dietPlanStrategyModel.planEndDate)}",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                                SizedBox(
                                  height: 29,
                                ),
                                Text(
                                  "'Updated at ${formatToDateTimeString(dietPlanStrategyModel.updatedAt)}'",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8), // outer spacing
                            child: Container(
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  splashFactory:
                                  NoSplash.splashFactory, // disables ripple
                                  highlightColor:
                                  Colors.transparent, // disables highlight
                                  hoverColor:
                                  Colors.transparent, // disables hover effect
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4), // inner padding
                                  collapsedBackgroundColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  collapsedShape: const RoundedRectangleBorder(),
                                  shape: const RoundedRectangleBorder(),
                                  childrenPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 31), // padding for children

                                  title: Text(
                                    'Plan Summary',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF252525),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.10,
                                      letterSpacing: -0.72,
                                    ),
                                  ),

                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                  "assets/images/icons/ic_goal.svg"),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Goal",
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFF252525),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.10,
                                                  letterSpacing: -0.24,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: dietPlanStrategyModel
                                                  .goals.length,
                                              itemBuilder: (context, index) {
                                                final goal = dietPlanStrategyModel
                                                    .goals[index];
                                                return goalItem(
                                                  goalName: goal.name,
                                                  currentStat:
                                                  goal.currentStat.toString(),
                                                  targetStat:
                                                  goal.targetStat.toString(),
                                                  // optional
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                              width: double.infinity,
                                              height: 1,
                                              color: const Color(0xFFCAE1FF)),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                  "assets/images/icons/ic_approach.svg"),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Approach",
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFF252525),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.10,
                                                    letterSpacing: -0.24,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Wrap(
                                              spacing: 5,
                                              runSpacing: 5,
                                              children: dietPlanStrategyModel
                                                  .approaches
                                                  .map((approach) => Container(
                                                  decoration: ShapeDecoration(
                                                    color:
                                                    const Color(0xFFE0E0E0),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: Text(
                                                    approach,
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(
                                                          0xFF535359),
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      height: 1.10,
                                                      letterSpacing: -0.24,
                                                    ),
                                                  )))
                                                  .toList(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8), // outer spacing
                    child: YourLog(clientProfileModel: widget.clientProfileModel, dietPlanId: widget.activeData.first.id.toString(),),
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            )));
  }
}
