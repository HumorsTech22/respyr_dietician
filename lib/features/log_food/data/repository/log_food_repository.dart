import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_category.dart';

class LogFoodRepository {
  List<FoodItem> getDummyFoodItem() {
    return [
      // Wake Up
      FoodItem(
        title: "Carrot + beetroot + turmeric + ginger with lemon",
        category: MealCategory.wakeUp,
      ),
      FoodItem(
        title: "Cinnamon water",
        subTitle: "1 cup (250 ml)",
        category: MealCategory.wakeUp,
      ),
      FoodItem(
        title: "Almonds (soaked & de-skinned)",
        subTitle: "8-10 pieces • 15-20 min later",
        category: MealCategory.wakeUp,
      ),

      // Breakfast
      FoodItem(
        title: "Idli with sambar",
        subTitle: "2 pcs",
        category: MealCategory.breakfast,
      ),
      FoodItem(
        title: "Oats porridge with fruits",
        subTitle: "1 bowl",
        category: MealCategory.breakfast,
      ),
      FoodItem(
        title: "Boiled eggs",
        subTitle: "2 pcs",
        category: MealCategory.breakfast,
      ),

      // Lunch
      FoodItem(
        title: "Veg salad",
        subTitle: "1 bowl",
        category: MealCategory.lunch,
      ),
      FoodItem(
        title: "non-Veg salad",
        subTitle: "1 bowl",
        category: MealCategory.lunch,
      ),
      FoodItem(
        title: "fruit salad",
        subTitle: "1 bowl",
        category: MealCategory.lunch,
      ),
      FoodItem(title: "egg", subTitle: "1 bowl", category: MealCategory.lunch),
      FoodItem(
        title: "Dal + roti",
        subTitle: "2 roti + dal",
        category: MealCategory.lunch,
      ),
      FoodItem(
        title: "Curd rice",
        subTitle: "1 cup",
        category: MealCategory.lunch,
      ),

      // Snacks
      FoodItem(
        title: "Fruit bowl",
        subTitle: "Seasonal fruits",
        category: MealCategory.snacks,
      ),
      FoodItem(
        title: "Green tea",
        subTitle: "1 cup",
        category: MealCategory.snacks,
      ),
      FoodItem(
        title: "Sprouts chaat",
        subTitle: "1 bowl",
        category: MealCategory.snacks,
      ),

      // Dinner
      FoodItem(
        title: "Paneer curry + roti",
        subTitle: "2 roti",
        category: MealCategory.dinner,
      ),
      FoodItem(
        title: "Mixed veg soup",
        subTitle: "1 bowl",
        category: MealCategory.dinner,
      ),
      FoodItem(
        title: "Steamed rice + dal tadka",
        subTitle: "1 cup rice + dal",
        category: MealCategory.dinner,
      ),

      // Sleep
      FoodItem(
        title: "Warm turmeric milk",
        subTitle: "1 glass",
        category: MealCategory.sleep,
      ),
      FoodItem(
        title: "Chamomile tea",
        subTitle: "1 cup",
        category: MealCategory.sleep,
      ),
      FoodItem(
        title: "Soaked walnuts",
        subTitle: "3-4 pcs",
        category: MealCategory.sleep,
      ),
    ];
  }
}
