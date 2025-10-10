import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/diet_log/data/model/food_item_model.dart';
import 'package:respyr_dietitian/features/diet_log/presentation/cubit/diet_log_cubit.dart';
import 'package:respyr_dietitian/features/diet_log/presentation/widgets/diet_log_cal_score.dart';
import 'package:respyr_dietitian/features/diet_log/presentation/widgets/diet_log_calender.dart';
import 'package:respyr_dietitian/features/diet_log/presentation/widgets/meal_logged_card.dart';
import '../cubit/diet_log_state.dart';

class DietLogScreen extends StatelessWidget {
  const DietLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String dot = "•";
    final cubit = context.read<DietLogCubit>();
    final weekDates = cubit.getCurrentWeekDates();
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: _buildAppbar(context),
      body: BlocBuilder<DietLogCubit, DietLogState>(
        builder: (context, state) {
          if (state is DietLogLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF308BF9)),
            );
          } else if (state is DietLogLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DietLogCalender(
                    weekDates: weekDates,
                    selectedDate: DateTime.now(),
                    onDateSelected: (date) => cubit.loadDietLog(date),
                  ),
                  SizedBox(height: 20),
                  DietLogCalScore(),

                  const SizedBox(height: 10),
                  Text(
                    'Meal logged',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  MealLoggedCard(
                    title: "Wake up",
                    timeRange: "06:00-06:30AM",
                    foods: [
                      FoodItemModel(
                        icon: Icons.local_drink,
                        number: 1,
                        name: "Carrot + beetroot + turmeric with lemon",
                        kcal: "220 kcal",
                        details: "1 cup (250 ml)",

                        suggest: true,
                        suggestions: [
                          FoodItemModel(
                            icon: Icons.water_drop,
                            number: 0,
                            name: "Cinnamon water",
                            kcal: "0 kcal",
                            details: "1 cup (250 ml)",
                          ),
                        ],
                      ),
                      FoodItemModel(
                        icon: Icons.eco,
                        number: 2,
                        name: "Almonds [soaked + de skinned]",
                        kcal: "68 kcal",
                        details: "8-10 pieces",
                        subDetails: "$dot 15-20 min later",
                        missed: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  MealLoggedCard(
                    title: "Breakfast",
                    timeRange: "08:00-09:00AM",
                    foods: [
                      FoodItemModel(
                        icon: Icons.apple,
                        number: 1,
                        name: "Ragi porridge / Sattu / Oats /Cereals",
                        kcal: "220 kcal",
                        details: "1 bowl (250ml)",
                        subDetails: "$dot 2 tsp soaked chia seeds",
                        suggest: true,
                        missed: true,
                        suggestions: [
                          FoodItemModel(
                            icon: Icons.water_drop,
                            number: 0,
                            name: "North Indian BF with small portions",
                            kcal: "220 kcal",
                            details: "1 piece",
                          ),
                        ],
                      ),
                      FoodItemModel(
                        icon: Icons.palette,
                        number: 2,
                        name: "Boiled sprouts / grilled paneer",
                        kcal: "68 kcal",
                        details: "1 bowl (250ml) ",
                      ),
                      FoodItemModel(
                        icon: Icons.palette,
                        number: 2,
                        name: "Low fat curd",
                        kcal: "68 kcal",
                        details: "1 cup (150ml) ",
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  MealLoggedCard(
                    title: "lunch",
                    timeRange: "12:00-01:00PM",
                    foods: [
                      FoodItemModel(
                        icon: Icons.apple,
                        number: 1,
                        name: "Rice [regular/ basmati/ brown/ millets ]",
                        kcal: "220 kcal",
                        details: "1 bowl (250ml)",
                        subDetails: "$dot 2 tsp soaked chia seeds",
                        suggest: true,
                        suggestions: [
                          FoodItemModel(
                            icon: Icons.water_drop,
                            number: 0,
                            name: "Wheat/ millet roti",
                            kcal: "220 kcal",
                            details: "1 bowl (250ml)",
                            subDetails: "$dot without ghee / oil",
                          ),
                        ],
                      ),
                      FoodItemModel(
                        icon: Icons.palette,
                        number: 2,
                        name: "Cooked Vegetables",
                        kcal: "220 kcal",
                        details: "1 bowl (250ml) ",
                        subDetails: "$dot leafy green / fruit veg / beans",
                        suggest: true,
                        suggestions: [
                          FoodItemModel(
                            name: "Raw salad / boiled veggies / tossed salad",
                            kcal: "220 kcal",
                            details: "1 bowl (250ml) ",
                            subDetails: "$dot without ghee / oil",
                          ),
                        ],
                      ),
                      FoodItemModel(
                        icon: Icons.palette,
                        number: 3,
                        name: "Boiled sprouts / grilled paneer",
                        kcal: "68 kcal",
                        details: "1 bowl (150ml) ",
                      ),
                      FoodItemModel(
                        otherItems: true,
                        number: 4,
                        otherFoodItems: [
                          FoodItemModel(
                            icon: Icons.palette,

                            name: "Ragi porridge / Sattu / Oats /Cereals",
                            kcal: "68 kcal",
                            details: "1 bowl (250ml) ",
                            subDetails: "$dot 2 tsp soaked chia seeds",
                            otherItems: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is DietLogError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Select a date to load diet log"));
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      leading: IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_sharp)),
      backgroundColor: Color(0xFFF5F7FA),
      surfaceTintColor: Color(0xFFF5F7FA),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diet Log',
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.30,
            ),
          ),
          Row(
            children: [
              Text(
                '05 July - 19 July',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                  letterSpacing: -0.20,
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFFFFDFDB),
                  shape: BoxShape.rectangle,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFDA5747),
                      ),
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Non-veg',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFDA5747),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 1.10,
                        letterSpacing: -0.20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
