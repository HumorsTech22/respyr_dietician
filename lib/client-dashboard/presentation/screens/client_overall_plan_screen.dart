import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../extras/date_helper.dart';
import '../model/diet_plan_strategy_model.dart';
import '../widgets/goal_item.dart';
import '../widgets/plan_history_widgets.dart';
import 'active_plan_screen.dart';


class ClientOverallPlanScreen extends StatefulWidget {
  final List<DietPlanStrategyModel> activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;
  const ClientOverallPlanScreen({super.key, required this.activeData, required this.completedData, required this.canceledData});

  @override
  State<ClientOverallPlanScreen> createState() => _ClientOverallPlanScreenState();
}

class _ClientOverallPlanScreenState extends State<ClientOverallPlanScreen> {

  @override
  Widget build(BuildContext context) {

    List<DietPlanStrategyModel> mergeAndSortPlans({
      required List<DietPlanStrategyModel> completedData,
      required List<DietPlanStrategyModel> canceledData,
    }) {
      final mergedList = [...completedData, ...canceledData];
      mergedList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return mergedList;
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F7FA),
        surfaceTintColor: Color(0xFFF5F7FA),
        title: Row(
          children: [
            Text("Your Plans",
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text("Active Plan",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2.04,
                ),
              ),
            ),
            SizedBox(height: 19,),
            Column(
              children: widget.activeData.asMap().entries.map((entry) {
                final dietPlanStrategyModel = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  DietPlanOverview(activeData: widget.activeData, completedData: widget.completedData, canceledData: widget.canceledData,),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dietPlanStrategyModel.planTitle,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.10,
                                  letterSpacing: -0.72,
                                ),
                              ),
                              Text("${formatToDayMonth(dietPlanStrategyModel.planStartDate)} - ${formatToDayMonth(dietPlanStrategyModel.planEndDate)}",
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
                          SizedBox(height: 15,),
                          Text(formatToDateTimeString(dietPlanStrategyModel.updatedAt),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              height: 1.10,
                              letterSpacing: -0.20,
                            ),
                          ),
                          SizedBox(height: 12,),
                          Container(
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF0F5FC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset("assets/images/icons/ic_goal.svg"),
                                    SizedBox(width: 5,),
                                    Text("Goal",
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
                                SizedBox(height: 19,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: dietPlanStrategyModel.goals.length,
                                    itemBuilder: (context, index) {

                                      final goal = dietPlanStrategyModel.goals[index];
                                      return goalItem(
                                        goalName: goal.name,
                                        currentStat: goal.currentStat.toString(),
                                        targetStat: goal.targetStat.toString(),
                                        // optional
                                      );


                                    },
                                  ) ,
                                ),

                              ],
                            ),
                          ),
                          SizedBox(height: 15,),
                          Text("Updated 05 Jul, 12:30pm",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              height: 1.10,
                              letterSpacing: -0.20,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text("Plans History",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2.04,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                itemCount: mergeAndSortPlans(completedData: widget.completedData, canceledData: widget.canceledData).length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final plan = mergeAndSortPlans(completedData: widget.completedData, canceledData: widget.canceledData)[index];
                  return PlanHistoryWidgets().planHistoryItem(dietPlanStrategyModel: plan);
                },
              ),
            ),
            SizedBox(height: 50,),
          ],
        ),
      ),
    );
  }
}
