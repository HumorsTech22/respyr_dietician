// day_cell.dart (IMPORTANT: import the file that contains DayRecord)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/performance_calender/data/model/daily_reading.dart';

class DayCell extends StatelessWidget {
  final DayRecord? record;
  final VoidCallback? onTap;
  final double metaScore;

  const DayCell({
    super.key,
    required this.record,
    required this.metaScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = record;
    if (r == null) return const SizedBox.shrink();

    final bool isSunday = r.date.weekday == DateTime.sunday;
    final double? score = r.score;

    print("score :" + score.toString());

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '${r.date.day}',
            style: GoogleFonts.poppins(
              color: isSunday ? const Color(0xFFDA5747) : const Color(0xFF252525),
              fontSize: rh(context: context, px: 10),
              fontWeight: FontWeight.w400,
              letterSpacing: rh(context: context, px: -0.20),
            ),
          ),
          SizedBox(height: rh(context: context, px: 6)),
          if (r.zone != null)
            Container(
              width: rh(context: context, px: 6),
              height: rh(context: context, px: 6),
              decoration: BoxDecoration(
                color: r.dotColor,
                shape: BoxShape.circle,
              ),
            )
          else
            SizedBox(height: rh(context: context, px: 6)),
          SizedBox(height: rh(context: context, px: 4)),
          if (score != null)
            Text(
              "${score.toStringAsFixed(0)}%",
              style: GoogleFonts.poppins(
                fontSize: rh(context: context, px: 10),
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            SizedBox(height: rh(context: context, px: 12)),
        ],
      ),
    );
  }
}