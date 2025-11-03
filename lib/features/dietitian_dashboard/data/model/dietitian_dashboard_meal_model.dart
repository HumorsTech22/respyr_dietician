// dietitian_dashboard_meal_model.dart

class DietitianDashboardMealModel {
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final List<Meal> meals;

  DietitianDashboardMealModel({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.meals,
  });

  factory DietitianDashboardMealModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] ?? {};
    final data = json['data'] ?? {};
    // assuming only one day key present (e.g., "monday")
    final dayMap =
        data.values.isNotEmpty ? data.values.first as Map<String, dynamic> : {};
    final totals = dayMap['totals'] as Map<String, dynamic>? ?? {};

    return DietitianDashboardMealModel(
      totalCalories: (metadata['total_calories'] ?? 0) as int,
      totalProtein: (totals['protein'] ?? 0) as int,
      totalCarbs: (totals['carbs'] ?? 0) as int,
      totalFat: (totals['fat'] ?? 0) as int,
      meals:
          (dayMap['meals'] as List?)
              ?.map((m) => Meal.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Meal {
  final String time;
  final int protein;
  final int carbs;
  final int fat;
  final int calories;
  final List<DietitianDashboardFoodItem> items;

  Meal({
    required this.time,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.items,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>? ?? {};
    return Meal(
      time: json['time'] as String? ?? '',
      protein: (totals['protein'] ?? 0) as int,
      carbs: (totals['carbs'] ?? 0) as int,
      fat: (totals['fat'] ?? 0) as int,
      calories: (totals['calories_kcal'] ?? 0) as int,
      items:
          (json['items'] as List?)
              ?.map(
                (i) => DietitianDashboardFoodItem.fromJson(
                  i as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}

class DietitianDashboardFoodItem {
  final String name;
  final String portion;
  final int protein;
  final int carbs;
  final int fat;
  final int calories;

  DietitianDashboardFoodItem({
    required this.name,
    required this.portion,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });

  factory DietitianDashboardFoodItem.fromJson(Map<String, dynamic> json) {
    return DietitianDashboardFoodItem(
      name: json['name'] as String? ?? '',
      portion: json['portion'] as String? ?? '',
      protein: (json['protein'] ?? 0) as int,
      carbs: (json['carbs'] ?? 0) as int,
      fat: (json['fat'] ?? 0) as int,
      calories: (json['calories_kcal'] ?? 0) as int,
    );
  }
}
