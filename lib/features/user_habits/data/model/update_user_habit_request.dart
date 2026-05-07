class UpdateUserHabitsRequest {
  final String profileId;
  final String goal;
  final String activity;
  final String dietType;
  final String primaryCuisine;
  final String secondaryCuisine;

  UpdateUserHabitsRequest({
    required this.profileId,
    required this.goal,
    required this.activity,
    required this.dietType,
    required this.primaryCuisine,
    required this.secondaryCuisine,
  });

  Map<String, dynamic> toJson() {
    return {
      "profile_id": profileId,
      "goal": goal,
      "activity": activity,
      "food_type": {
        "diet_type": dietType,
        "primary_cuisine": primaryCuisine,
        "secondary_cuisine": secondaryCuisine,
      }
    };
  }
}