class UpdateUserHabitsResponse {
  final bool status;
  final String message;
  final UpdateUserHabitsData? data;

  UpdateUserHabitsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory UpdateUserHabitsResponse.fromJson(Map<String, dynamic> json) {
    return UpdateUserHabitsResponse(
      status: json["status"] == true,
      message: json["message"]?.toString() ?? "",
      data: json["data"] != null
          ? UpdateUserHabitsData.fromJson(json["data"])
          : null,
    );
  }
}

class UpdateUserHabitsData {
  final String profileId;
  final String goal;
  final String activity;
  final FoodTypeData foodType;

  UpdateUserHabitsData({
    required this.profileId,
    required this.goal,
    required this.activity,
    required this.foodType,
  });

  factory UpdateUserHabitsData.fromJson(Map<String, dynamic> json) {
    return UpdateUserHabitsData(
      profileId: json["profile_id"]?.toString() ?? "",
      goal: json["goal"]?.toString() ?? "",
      activity: json["activity"]?.toString() ?? "",
      foodType: FoodTypeData.fromJson(
        Map<String, dynamic>.from(json["food_type"] ?? {}),
      ),
    );
  }
}

class FoodTypeData {
  final String dietType;
  final String primaryCuisine;
  final String secondaryCuisine;

  FoodTypeData({
    required this.dietType,
    required this.primaryCuisine,
    required this.secondaryCuisine,
  });

  factory FoodTypeData.fromJson(Map<String, dynamic> json) {
    return FoodTypeData(
      dietType: json["diet_type"]?.toString() ?? "",
      primaryCuisine: json["primary_cuisine"]?.toString() ?? "",
      secondaryCuisine: json["secondary_cuisine"]?.toString() ?? "",
    );
  }
}