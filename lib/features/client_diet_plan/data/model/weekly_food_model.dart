class WeeklyFoodResponse {
  final bool status;
  final String message;
  final WeeklyFoodData? data;

  WeeklyFoodResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WeeklyFoodResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyFoodResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? WeeklyFoodData.fromJson(json['data']) : null,
    );
  }
}

class WeeklyFoodData {
  final int id;
  final String weekStartDate;
  final String weekEndDate;
  final String weekRange;
  final FoodJson foodJson;

  WeeklyFoodData({
    required this.id,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.weekRange,
    required this.foodJson,
  });

  factory WeeklyFoodData.fromJson(Map<String, dynamic> json) {
    return WeeklyFoodData(
      id: int.tryParse(json['id'].toString()) ?? 0,
      weekStartDate: json['week_start_date']?.toString() ?? '',
      weekEndDate: json['week_end_date']?.toString() ?? '',
      weekRange: json['week_range']?.toString() ?? '',
      foodJson: FoodJson.fromJson(json['food_json'] ?? {}),
    );
  }
}

class FoodJson {
  final List<DietDay> days;
  final WeeklyJsonData weeklyJsonData;

  FoodJson({
    required this.days,
    required this.weeklyJsonData,
  });

  factory FoodJson.fromJson(Map<String, dynamic> json) {
    return FoodJson(
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => DietDay.fromJson(e))
          .toList(),
      weeklyJsonData: WeeklyJsonData.fromJson(json['weekly_json_data'] ?? {}),
    );
  }
}

class WeeklyJsonData {
  final double calories;
  final double carbsG;
  final double proteinG;
  final double fatG;
  final double fiberG;
  final String note;

  WeeklyJsonData({
    required this.calories,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.fiberG,
    required this.note,
  });

  factory WeeklyJsonData.fromJson(Map<String, dynamic> json) {
    return WeeklyJsonData(
      calories: double.tryParse(json['calories'].toString()) ?? 0,
      carbsG: double.tryParse(json['carbs_g'].toString()) ?? 0,
      proteinG: double.tryParse(json['protein_g'].toString()) ?? 0,
      fatG: double.tryParse(json['fat_g'].toString()) ?? 0,
      fiberG: double.tryParse(json['fiber_g'].toString()) ?? 0,
      note: json['note']?.toString() ?? '',
    );
  }
}

class DietDay {
  final String dayCode;
  final String day;
  final Meal breakfast;
  final Meal lunch;
  final Meal snacks;
  final Meal dinner;

  DietDay({
    required this.dayCode,
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });

  factory DietDay.fromJson(Map<String, dynamic> json) {
    return DietDay(
      dayCode: json['day_code']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      breakfast: Meal.fromJson(json['breakfast'] ?? {}),
      lunch: Meal.fromJson(json['lunch'] ?? {}),
      snacks: Meal.fromJson(json['snacks'] ?? {}),
      dinner: Meal.fromJson(json['dinner'] ?? {}),
    );
  }
}

class Meal {
  final List<FoodItem> foods;

  Meal({required this.foods});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      foods: (json['foods'] as List<dynamic>? ?? [])
          .map((e) => FoodItem.fromJson(e))
          .toList(),
    );
  }
}

class FoodItem {
  final String foodName;
  final double calories;
  final double carbsG;
  final double proteinG;
  final double fatG;
  final double fiberG;
  final String portionWithMetric;
  final String category;

  FoodItem({
    required this.foodName,
    required this.calories,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.fiberG,
    required this.portionWithMetric,
    required this.category,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodName: json['food_name']?.toString() ?? '',
      calories: double.tryParse(json['calories'].toString()) ?? 0,
      carbsG: double.tryParse(json['carbs_g'].toString()) ?? 0,
      proteinG: double.tryParse(json['protein_g'].toString()) ?? 0,
      fatG: double.tryParse(json['fat_g'].toString()) ?? 0,
      fiberG: double.tryParse(json['fiber_g'].toString()) ?? 0,
      portionWithMetric: json['portion_with_metric']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }
}



// final weeklyData = foodState.response.data?.foodJson.weeklyJsonData;
//
// print(weeklyData?.calories);
// print(weeklyData?.proteinG);
// print(weeklyData?.note);