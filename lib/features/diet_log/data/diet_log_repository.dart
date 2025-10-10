class DietLogRepository {
  Future<DietSummary> fetchSummary(DateTime date) async {
    // mock data (replace with API/db call)
    await Future.delayed(const Duration(milliseconds: 500));
    return DietSummary(
      dailyGoalPercent: 75,
      calories: 1200,
      caloriesGoal: 1800,
      protein: 150,
      proteinGoal: 180,
      carbs: 70,
      carbsGoal: 100,
      fiber: 25,
      fiberGoal: 30,
      fats: 25,
      fatsGoal: 30,
    );
  }

  Future<List<Meal>> fetchMeals(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Meal(
        title: "Carrot + beetroot + turmeric & ginger tea",
        kcal: 220,
        status: MealStatus.completed,
      ),
      Meal(title: "Cinnamon water", kcal: 0, status: MealStatus.skipped),
      Meal(
        title: "Almonds (soaked & deskinned)",
        kcal: 68,
        status: MealStatus.missed,
      ),
    ];
  }
}

class DietSummary {
  final int dailyGoalPercent;
  final int calories;
  final int caloriesGoal;
  final int protein;
  final int proteinGoal;
  final int carbs;
  final int carbsGoal;
  final int fiber;
  final int fiberGoal;
  final int fats;
  final int fatsGoal;

  DietSummary({
    required this.dailyGoalPercent,
    required this.calories,
    required this.caloriesGoal,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbsGoal,
    required this.fiber,
    required this.fiberGoal,
    required this.fats,
    required this.fatsGoal,
  });
}

enum MealStatus { completed, skipped, missed }

class Meal {
  final String title;
  final int kcal;
  final MealStatus status;

  Meal({required this.title, required this.kcal, required this.status});
}
