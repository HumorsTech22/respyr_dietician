class FoodPreference {
  final String dietType;
  final String primaryCuisine;
  final String secondaryCuisine;

  FoodPreference({
    required this.dietType,
    required this.primaryCuisine,
    required this.secondaryCuisine,
  });

  Map<String, dynamic> toJson() {
    return {
      "diet_type": dietType,
      "primary_cuisine": primaryCuisine,
      "secondary_cuisine": secondaryCuisine,
    };
  }
}