class MealHelper {
  String getCurrentMealName() {
    final int hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Breakfast";
    } else if (hour >= 12 && hour < 16) {
      return "Lunch";
    } else if (hour >= 16 && hour < 19) {
      return "Snacks";
    } else {
      return "Dinner";
    }
  }
}