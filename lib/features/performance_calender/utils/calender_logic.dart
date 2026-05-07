import 'package:flutter/material.dart';
import 'package:respyr_dietitian/features/performance_calender/data/model/daily_reading.dart';

class CalendarLogic {
  // We now pass in 'monthlyReadings' which contains the real data
  static List<DayRecord?> generateMonthData(
      int year,
      int month,
      Map<int, DailyReading> monthlyReadings,
      ) {
    List<DayRecord?> days = [];

    DateTime firstDay = DateTime(year, month, 1);
    int daysInMonth = DateUtils.getDaysInMonth(year, month);
    int startingWeekdayIndex = firstDay.weekday - 1;

    // Padding cells before the 1st
    for (int i = 0; i < startingWeekdayIndex; i++) {
      days.add(null);
    }

    // Generate actual days
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDate = DateTime(year, month, i);

      // LOOKUP REAL DATA: Check if our database map has a reading for day 'i'
      DailyReading? readingForToday = monthlyReadings[i];

      days.add(
        DayRecord(
          date: currentDate,
          zone: readingForToday?.zone, // Will be null if no reading exists
          metric:
          readingForToday?.weight, // Will be null if no weight was recorded
        ),
      );
    }

    return days;
  }
}