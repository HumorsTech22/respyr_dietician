import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/client_diet_plan/presentation/widgets/food_item_card.dart';
import 'package:respyr_dietitian/features/client_diet_plan/utils/meal_color_helper.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/diet_hero_meal_card.dart';

import '../../../../core/size/get_height.dart';
import '../../data/model/weekly_food_model.dart';
import 'nutrition_chip.dart';

Widget mainContentDietPlan(
    BuildContext context, {
      required List<DietDay> days,
      required String weekStartDate,
    }) {
  final DietDay currentDay = _getCurrentDietDay(days, weekStartDate);
  final _CurrentMealData currentMeal = _getCurrentMeal(currentDay);

  final Color mealColor = MealColorHelper().getMealColor(currentMeal.mealName);

  final double totalCalories = currentMeal.foods.fold(0, (sum, item) => sum + item.calories);
  final double totalCarbs = currentMeal.foods.fold(0, (sum, item) => sum + item.carbsG);
  final double totalProtein = currentMeal.foods.fold(0, (sum, item) => sum + item.proteinG);
  final double totalFiber = currentMeal.foods.fold(0, (sum, item) => sum + item.fiberG);
  final double totalFat = currentMeal.foods.fold(0, (sum, item) => sum + item.fatG);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: rh(context: context, px: 24)),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today’s Diet",
              style: GoogleFonts.poppins(
                color: mealColor,
                fontSize: rh(context: context, px: 12),
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
            SizedBox(height: rh(context: context, px: 10)),
            Text(
              "It’s ${currentMeal.mealName} time!",
              style: GoogleFonts.poppins(
                color: mealColor,
                fontSize: rh(context: context, px: 20),
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),

      SizedBox(height: rh(context: context, px: 24)),

      Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Intake Summary(${currentMeal.foods.length} items)",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: mealColor,
                      fontSize: rh(context: context, px: 10),
                    ),
                  ),
                ),

                SizedBox(height: rh(context: context, px: 5)),

                Text(
                  "${totalCalories.toStringAsFixed(0)} kcal Calories",
                  style: GoogleFonts.poppins(
                    color: mealColor,
                    fontSize: rh(context: context, px: 20),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    nutritionChip(context: context, text: "Carbs ${totalCarbs.toStringAsFixed(0)} g", textColor: const Color(0xFFE76F51), bgColor: const Color(0x19E76F51)),
                    nutritionChip(context: context, text: "Protein ${totalProtein.toStringAsFixed(0)} g", textColor: const Color(0xFF2A9D8F), bgColor: const Color(0x192A9D8F)),
                    nutritionChip(context: context, text: "Fibre ${totalFiber.toStringAsFixed(0)} g", textColor: const Color(0xFFF4A261), bgColor: const Color(0x19F4A261)),
                    nutritionChip(context: context, text: "Fat ${totalFat.toStringAsFixed(0)} g", textColor: const Color(0xFF3A86FF), bgColor: const Color(0x193A86FF)),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: rh(context: context, px: 305),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      return FoodItemCard(
                        food: currentMeal.foods[index],
                        index: index + 1, mealType: '',
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 20),
                    itemCount: currentMeal.foods.length,
                  ),
                ),

                SizedBox(height: rh(context: context, px: 56)),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

class _CurrentMealData {
  final String mealName;
  final List<FoodItem> foods;

  _CurrentMealData({
    required this.mealName,
    required this.foods,
  });
}

DietDay _getCurrentDietDay(List<DietDay> days, String weekStartDate) {
  final DateTime startDate = DateTime.parse(weekStartDate);
  final DateTime today = DateTime.now();

  final int index = today.difference(
    DateTime(startDate.year, startDate.month, startDate.day),
  ).inDays;

  if (index >= 0 && index < days.length) {
    return days[index];
  }

  return days.first;
}

_CurrentMealData _getCurrentMeal(DietDay day) {
  final int hour = DateTime.now().hour;

  if (hour >= 5 && hour < 12) {
    return _CurrentMealData(mealName: "Breakfast", foods: day.breakfast.foods);
  } else if (hour >= 12 && hour < 16) {
    return _CurrentMealData(mealName: "Lunch", foods: day.lunch.foods);
  } else if (hour >= 16 && hour < 19) {
    return _CurrentMealData(mealName: "Snacks", foods: day.snacks.foods);
  } else {
    return _CurrentMealData(mealName: "Dinner", foods: day.dinner.foods);
  }
}