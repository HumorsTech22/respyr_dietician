import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/screens/client_overall_plan_screen.dart';
import '../extras/date_helper.dart';
import '../model/diet_plan_strategy_model.dart';
import '../widgets/target_item.dart';

class DietPlanCard extends StatelessWidget {
  final List<DietPlanStrategyModel> activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;

  const DietPlanCard({super.key, required this.activeData, required this.completedData, required this.canceledData});

  @override
  Widget build(BuildContext context) {


    return Visibility(
      visible: activeData.isNotEmpty,
      replacement: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: double.infinity,
          decoration: ShapeDecoration(
            color: const Color(0xFFF0F0F0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
          child: Column(
            children: [
              Text("No active diet plan available for you")
            ],
          ),
        ),
      ),
      child: Column(
        children: activeData.asMap().entries.map((entry) {
         // final index = entry.key; // kept in case you use it later
          final dietPlanStrategyModel = entry.value;

          final dietitianInfo = dietPlanStrategyModel.dietitianInfo; // ✅ safe handle
          final logoUrl = (dietitianInfo?.logo ?? '').trim();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                color: const Color(0xFFF0F0F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 31),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Diet Plan Strategy",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        Text(
                          "As per",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.24,
                          ),
                        ),
                        const SizedBox(width: 5),
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade500,
                          child: (logoUrl.isNotEmpty)
                              ? Image.network(
                            logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/icons/default1.png',
                                height: 30,
                                width: 30,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                              : Image.asset(
                            'assets/images/icons/default1.png',
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            dietitianInfo?.name ?? '-',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                              letterSpacing: -0.24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Updated at ${formatToDateTimeString(dietPlanStrategyModel.updatedAt)}",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.10,
                        letterSpacing: -0.24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 23),
                  PlanCard(activeData: activeData, completedData: completedData, canceledData: canceledData,),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/icons/ic_goal.svg"),
                            const SizedBox(width: 5),
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
                        const SizedBox(height: 13),
                        // ✅ Safe when goals is empty
                        if (dietPlanStrategyModel.goals.isEmpty)
                          Text(
                            "-",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                              letterSpacing: -0.24,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: List.generate(
                              dietPlanStrategyModel.goals.length * 2 - 1,
                                  (index) {
                                if (index.isEven) {
                                  return Text(
                                    dietPlanStrategyModel
                                        .goals[(index ~/ 2)].name,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF535359),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.10,
                                      letterSpacing: -0.24,
                                    ),
                                  );
                                } else {
                                  return Container(
                                    width: 1,
                                    height: 12,
                                    color: const Color(0xFF535359),
                                  ); // separator
                                }
                              },
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 14.5),
                  Container(
                    color: const Color(0xFFD7D6D6),
                    height: 1,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                                "assets/images/icons/ic_approach.svg"),
                            const SizedBox(width: 5),
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
                        const SizedBox(height: 13),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: dietPlanStrategyModel.approaches
                              .map(
                                (approach) => Container(
                              decoration: ShapeDecoration(
                                color: const Color(0xFFE0E0E0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                approach,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    color: const Color(0xFFD7D6D6),
                    height: 1,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () {}, // kept as-is (no logic change)
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "View diet plan",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF308BF9),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                              letterSpacing: -0.30,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_right_outlined,
                            color: Color(0xFF308BF9),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {

  final List<DietPlanStrategyModel> activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;

  const PlanCard({super.key, required this.activeData, required this.completedData, required this.canceledData,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: activeData.asMap().entries.map((entry) {
          final dietPlanStrategyModel = entry.value;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dietPlanStrategyModel.planTitle,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: -0.72,
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
                  ],
                ),
              ),
              const SizedBox(height: 11),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientOverallPlanScreen(activeData: activeData, completedData: completedData, canceledData: canceledData,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "View all plans",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF308BF9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.24,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_right_outlined,
                        color: Color(0xFF308BF9),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                color: const Color(0xFFD7D6D6),
                height: 1,
                width: double.infinity,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  SvgPicture.asset("assets/images/icons/ic_target.svg"),
                  const SizedBox(width: 5),
                  Text(
                    "Daily Target",
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
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                child: Row(
                  children: [
                    targetItem(
                      targetLabel: 'Calories',
                      targetIntake: 'Kcal',
                      targetValue: dietPlanStrategyModel.caloriesTarget.toDouble(),
                    ),
                    targetItem(
                      targetLabel: 'Protein',
                      targetIntake: 'gram',
                      targetValue: dietPlanStrategyModel.proteinTarget.toDouble(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                child: Row(
                  children: [
                    targetItem(
                      targetLabel: 'Fibre',
                      targetIntake: 'gram',
                      targetValue: dietPlanStrategyModel.fiberTarget.toDouble(),
                    ),
                    targetItem(
                      targetLabel: 'Water',
                      targetIntake: 'Litre',
                      targetValue: dietPlanStrategyModel.waterTarget,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14.5),
            ],
          );
        }).toList(),



      ),
    );
  }


}
