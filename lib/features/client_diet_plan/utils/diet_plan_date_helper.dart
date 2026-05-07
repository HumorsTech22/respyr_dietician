class DietPlanDateHelper {
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String formatDate(String date) {
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return date;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final day = parsedDate.day.toString().padLeft(2, '0');
    final month = months[parsedDate.month - 1];

    return '$day $month';
  }

  static String getDayOnly(String weekStartDate, int index) {
    final startDate = DateTime.tryParse(weekStartDate);
    if (startDate == null) return '';

    final dayDate = startDate.add(Duration(days: index));
    return dayDate.day.toString().padLeft(2, '0');
  }

  static String shortDayName(String day) {
    if (day.length <= 3) return day;
    return day.substring(0, 3);
  }

  static int findCurrentWeekIndex(List list) {
    final today = dateOnly(DateTime.now());

    for (int i = 0; i < list.length; i++) {
      final start = DateTime.tryParse(list[i].weekStartDate);
      final end = DateTime.tryParse(list[i].weekEndDate);

      if (start == null || end == null) continue;

      final startDate = dateOnly(start);
      final endDate = dateOnly(end);

      if ((today.isAtSameMomentAs(startDate) || today.isAfter(startDate)) &&
          (today.isAtSameMomentAs(endDate) || today.isBefore(endDate))) {
        return i;
      }
    }

    return 0;
  }

  static int findTodayDayIndex(String weekStartDate, int totalDays) {
    final start = DateTime.tryParse(weekStartDate);
    if (start == null) return 0;

    final today = dateOnly(DateTime.now());
    final startDate = dateOnly(start);

    final diff = today.difference(startDate).inDays;

    if (diff >= 0 && diff < totalDays) {
      return diff;
    }

    return 0;
  }

  static String formatWeekRange(String weekStartDate, {int totalDays = 7}) {
    final startDate = DateTime.tryParse(weekStartDate);
    if (startDate == null) return weekStartDate;

    final endDate = startDate.add(Duration(days: totalDays - 1));

    final startText = formatDate(startDate.toIso8601String());
    final endText = formatDate(endDate.toIso8601String());

    return '$startText - $endText';
  }
}