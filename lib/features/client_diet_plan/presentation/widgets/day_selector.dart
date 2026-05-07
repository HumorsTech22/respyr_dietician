import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/client_diet_plan/data/model/weekly_food_model.dart';
import '../../utils/diet_plan_date_helper.dart';

class DaySelector extends StatelessWidget {
  final List<DietDay> days;
  final int selectedDayIndex;
  final String weekStartDate;
  final ValueChanged<int> onDaySelected;

  const DaySelector({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.weekStartDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(days.length, (index) {
        final day = days[index];
        final isSelected = selectedDayIndex == index;

        return Expanded(
          child: GestureDetector(
            onTap: () => onDaySelected(index),
            child: Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 6),
                vertical: rh(context: context, px: 6),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF308BF9)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  rh(context: context, px: 12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // DietPlanDateHelper.getDayOnly(
                    //   weekStartDate,
                    //   index,
                    // ),
                    day.dayCode.toUpperCase() ,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF252525),
                      fontWeight: FontWeight.w600,
                      fontSize: rh(context: context, px: 15),
                      height: 1.0,
                      letterSpacing: rh(context: context, px: -0.30),
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 4)),
                  Text(
                    DietPlanDateHelper.shortDayName(day.day),
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF777777),
                      fontSize: rh(context: context, px: 10),
                      fontWeight: FontWeight.w400,
                      letterSpacing: rh(context: context, px: -0.20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}