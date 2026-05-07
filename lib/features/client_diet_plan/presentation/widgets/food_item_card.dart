import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/client_diet_plan/data/model/weekly_food_model.dart';
import 'package:respyr_dietitian/features/client_diet_plan/utils/meal_color_helper.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/helpers/macro_colors.dart';

import 'nutrition_chip.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem food;
  final int index;
  final String mealType;

  const FoodItemCard({
    super.key,
    required this.food,
    required this.index, required this.mealType,
  });

  @override
  Widget build(BuildContext context) {


    return Container(
      width: rh(context: context, px: 214),
      margin: EdgeInsets.all(rh(context: context, px: 2)),
      decoration: ShapeDecoration(
        color: const Color(0xFFFDFDFD),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: rh(context: context, px: 2),
            strokeAlign: BorderSide.strokeAlignOutside,
            color: const Color(0xFF252525),
          ),
          borderRadius: BorderRadius.circular(
            rh(context: context, px: 15),
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: rh(context: context, px: 166),
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      rh(context: context, px: 20),
                    ),
                    child: Image.asset(
                      FoodImageHelper.getImage(food.category),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: rh(context: context, px: 8),
                  left: rh(context: context, px: 8),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 5),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: rh(context: context, px: 10),
                      vertical: rh(context: context, px: 5),
                    ),
                    child: Text(
                      "Item $index",
                      style: GoogleFonts.poppins(
                        color: MealColorHelper().getMealColor(mealType),
                        fontSize: rh(context: context, px: 10),
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: rh(context: context, px: -0.20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: rh(context: context, px: 14)),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 14),
            ),
            child: Text(
              food.foodName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: rh(context: context, px: 12),
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: rh(context: context, px: -0.24),
              ),
            ),
          ),

          SizedBox(height: rh(context: context, px: 8)),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 14),
            ),
            child: Row(
              children: [
                Text(
                  "${food.calories.toStringAsFixed(0)} Kcal",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: rh(context: context, px: 12),
                    fontWeight: FontWeight.w400,
                    letterSpacing: rh(context: context, px: -0.24),
                  ),
                ),
                if (food.portionWithMetric.isNotEmpty) ...[
                  SizedBox(width: rh(context: context, px: 6)),
                  Container(
                    width: rh(context: context, px: 3),
                    height: rh(context: context, px: 3),
                    decoration: const ShapeDecoration(
                      color: Color(0xFF535359),
                      shape: OvalBorder(),
                    ),
                  ),
                  SizedBox(width: rh(context: context, px: 6)),
                  Expanded(
                    child: Text(
                      food.portionWithMetric,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 10),
                        fontWeight: FontWeight.w400,
                        letterSpacing: rh(context: context, px: -0.20),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: rh(context: context, px: 12)),

          SizedBox(
            height: rh(context: context, px: 24),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                left: rh(context: context, px: 14),
                right: rh(context: context, px: 14),
              ),
              children: [
                nutritionChip(
                  context: context,
                  text: "Protein ${food.proteinG.toStringAsFixed(0)} g",
                  textColor:MacroColors.protein,
                  bgColor: MacroColors.getBgColor("Protein"),
                ),
                SizedBox(width: rh(context: context, px: 4)),
                nutritionChip(
                  context: context,
                  text: "Fibre ${food.fiberG.toStringAsFixed(0)} g",
                  textColor: MacroColors.fibre,
                  bgColor: MacroColors.getBgColor("Fibre"),
                ),
                SizedBox(width: rh(context: context, px: 4)),
                nutritionChip(
                  context: context,
                  text: "Carbs ${food.carbsG.toStringAsFixed(0)} g",
                  textColor: MacroColors.carb,
                  bgColor: MacroColors.getBgColor("Carbs"),
                ),
                SizedBox(width: rh(context: context, px: 4)),
                nutritionChip(
                  context: context,
                  text: "Fat ${food.fatG.toStringAsFixed(0)} g",
                  textColor: MacroColors.fat,
                  bgColor:  MacroColors.getBgColor("Fat"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class FoodImageHelper {
  static String getImage(String type) {
    switch (type.toLowerCase().trim()) {
      case "meal":
      case "food":
        return "assets/images/food/def_meal.png";

      case "drink":
        return "assets/images/food/def_drink.png";

      case "drink1":
        return "assets/images/food/def_drinkl.png";

      case "beverage":
        return "assets/images/food/def_beverage.png";

      case "dessert":
        return "assets/images/food/def_dessert.png";

      case "fruit":
      case "fruits":
        return "assets/images/food/def_fruite.png";

      case "snack":
      case "snacks":
        return "assets/images/food/def_snack.png";

      default:
        return "assets/images/food/def_meal.png";
    }
  }
}