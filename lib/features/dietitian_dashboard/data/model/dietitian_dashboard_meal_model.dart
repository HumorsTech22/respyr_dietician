class DietitianDashboardMealModel {
  final String mealTitle;
  final String timeRange;
  final int totalCalories;
  final List<DietitianDashboardFoodItem> foodItems;

  DietitianDashboardMealModel({
    required this.mealTitle,
    required this.foodItems,
    required this.timeRange,
    required this.totalCalories,
  });
}

class DietitianDashboardFoodItem {
  final String foodName;
  final String foodDetails;
  final int kCal;
  final int foodNumber;

  DietitianDashboardFoodItem({
    required this.foodDetails,
    required this.foodName,
    required this.foodNumber,
    required this.kCal,
  });
}
