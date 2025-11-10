import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../log_food/data/repository/insert_food_log_api.dart';

class LogFoodSheet {
  Widget valuesContainer(String valueType, String value, String valueIndicator) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valueType,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w700,
              height: 1.26,
              letterSpacing: -0.50,
            ),
          ),
          Text(
            valueIndicator,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.20,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logFood({
    required int index,
    required String mealTitle,
    required String foodName,
    required String foodType,
    required String foodScale,
    required String foodCalories,
    required String foodProtein,
    required String foodFat,
    required String foodCarbs,
    required BuildContext context,
    required String dieticianId,
    required String profileId,
    required String dietPlanId,
  }) async {
    final Map<String, dynamic> foodValues = {
      "foodScale": foodScale,
      "foodCalories": foodCalories,
      "foodProtein": foodProtein,
      "foodFat": foodFat,
      "foodCarbs": foodCarbs,
    };

    final result = await FoodLogApi.insertFoodLog(
      dieticianId: dieticianId,
      profileId: profileId,
      dietPlanId: dietPlanId,
      mealTitle: mealTitle,
      mealName: foodName,
      mealValues: jsonEncode(foodValues),
    );

    if (result["success"] == true) {
      if (kDebugMode) debugPrint("✅ Inserted Successfully: ${result["data"]}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserted Successfully")),
      );
    } else {
      if (kDebugMode) debugPrint("⚠️ Error: ${result["error"] ?? result["message"]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${result["error"] ?? "Failed"}")),
      );
      throw Exception(result["error"] ?? "Insert failed");
    }
  }

  void showFoodBottomSheet({
    required int index,
    required String mealTitle,
    required String foodName,
    required String foodType,
    required String foodScale,
    required String foodCalories,
    required String foodProtein,
    required String foodFat,
    required String foodCarbs,
    required BuildContext context,
    required bool isLogged,
    required VoidCallback onLogged,
    required VoidCallback onAlreadyLogged,
    required String dieticianId,
    required String profileId,
    required String dietPlanId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header gradient (UI unchanged)
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.50, -0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [Color(0xFFFFF7AD), Colors.white],
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 20, bottom: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(bottomSheetContext, {
                                "status": "closed",
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 33),
                      Text(
                        mealTitle,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFAC9C0C),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.72,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content (UI unchanged)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Column(
                    children: [
                      Text(
                        foodName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          valuesContainer("Calories", foodCalories, "kcal"),
                          valuesContainer("Protein", foodProtein, "gram"),
                        ],
                      ),
                      const SizedBox(height: 53.5),
                      Row(
                        children: [
                          valuesContainer("Fat", foodFat, "gram"),
                          valuesContainer("Carbs", foodCarbs, "gram"),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // CTA — logs (if needed) and RETURNS to main with result
                      TextButton(
                        onPressed: () async {
                          if (isLogged) {
                            onAlreadyLogged();
                            // Return to main with "already_logged"
                            Navigator.pop(bottomSheetContext, {
                              "status": "already_logged",
                              "mealTitle": mealTitle,
                              "mealName": foodName,
                            });
                            return;
                          }

                          try {
                            await logFood(
                              index: index,
                              mealTitle: mealTitle,
                              foodName: foodName,
                              foodType: foodType,
                              foodScale: foodScale,
                              foodCalories: foodCalories,
                              foodProtein: foodProtein,
                              foodFat: foodFat,
                              foodCarbs: foodCarbs,
                              context: bottomSheetContext,
                              dieticianId: dieticianId,
                              profileId: profileId,
                              dietPlanId: dietPlanId,
                            );
                            onLogged();
                            // Return to main with "logged" and payload
                            Navigator.pop(bottomSheetContext, {
                              "status": "logged",
                              "mealTitle": mealTitle,
                              "mealName": foodName,
                              "values": {
                                "calories": foodCalories,
                                "protein": foodProtein,
                                "fat": foodFat,
                                "carbs": foodCarbs,
                              },
                            });
                          } catch (_) {
                            // Keep sheet open on failure
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 14,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLogged ? "Already Logged" : "Log this meal",
                              style: GoogleFonts.poppins(
                                color:
                                isLogged ? Colors.grey : const Color(0xFF308BF9),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.10,
                                letterSpacing: -0.30,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_outlined,
                              color:
                              isLogged ? Colors.grey : const Color(0xFF308BF9),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
