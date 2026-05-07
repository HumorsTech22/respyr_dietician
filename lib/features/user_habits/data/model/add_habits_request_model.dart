class AddHabitsRequestModel {
  final String profileId;
  final String goal;
  final String activity;
  final String foodType;

  const AddHabitsRequestModel({
    required this.profileId,
    required this.goal,
    required this.activity,
    required this.foodType,
  });

  Map<String, dynamic> toJson() {
    return {
      "profile_id": profileId,
      "goal": goal,
      "activity": activity,
      "food_type": foodType,
    };
  }
}