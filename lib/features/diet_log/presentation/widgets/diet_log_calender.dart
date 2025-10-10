import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DietLogCalender extends StatelessWidget {
  final List<DateTime> weekDates;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DietLogCalender({
    super.key,
    required this.weekDates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xFFFFFFFF),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            weekDates.map((date) {
              final isToday =
                  date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year;
              final isFuture = date.isAfter(today);

              return GestureDetector(
                onTap: isFuture ? null : () => onDateSelected(date),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isToday ? Color(0xFF308BF9) : Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      Text(
                        date.day.toString().padLeft(2, '0'),
                        style: GoogleFonts.poppins(
                          color:
                              isFuture
                                  ? Colors.grey
                                  : (isToday ? Colors.white : Colors.black),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ][date.weekday - 1],
                        style: GoogleFonts.poppins(
                          color:
                              isFuture
                                  ? Colors.grey
                                  : (isToday ? Colors.white : Colors.black),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
