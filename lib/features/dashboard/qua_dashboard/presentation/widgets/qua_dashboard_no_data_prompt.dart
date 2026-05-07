import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class QuaDashboardNoDataPrompt extends StatelessWidget {
  final DateTime selectedDate;

  const QuaDashboardNoDataPrompt({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/images/icons/no_test.svg",
            height: 80,
          ),
          const SizedBox(height: 24),
          Text(
            isToday ? "You Haven’t Tested\nYet Today" : "No Test Data Found",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isToday
                ? "Swipe below to start \nyour metabolism test!"
                : "Select another date to see\nyour history.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}