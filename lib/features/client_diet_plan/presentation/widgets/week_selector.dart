import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import '../../utils/diet_plan_date_helper.dart';

class WeekSelector extends StatelessWidget {
  final String weekStartDate;
  final String weekEndDate;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const WeekSelector({
    super.key,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: canGoPrevious ? onPrevious : null,
          icon: Icon(
            Icons.chevron_left_outlined,
            size: rh(context: context, px: 24),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(
              rh(context: context, px: 16),
            ),
            child: Center(
              child: Text(
                '${DietPlanDateHelper.formatDate(weekStartDate)} - ${DietPlanDateHelper.formatDate(weekEndDate)}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: canGoNext ? onNext : null,
          icon: Icon(
            Icons.chevron_right_outlined,
            size: rh(context: context, px: 24),
          ),
        ),
      ],
    );
  }
}