import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:respyr_dietitian/core/utils/text_style.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/data/model/dietitian_dashboard_meal_model.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_cubit.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_state.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/widgets/food_container_list.dart';
import 'package:respyr_dietitian/features/test_result_screen/presentation/pages/test_result_screen.dart';

class DietitianDashboardScreen extends StatelessWidget {
  const DietitianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFFE29F),
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocBuilder<DietitianDashboardCubit, DietitianDashboardState>(
        builder: (context, state) {
          if (state is DietitianDashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF908BF9)),
            );
          } else if (state is DietitianDashboardLoaded) {
            final meal = state.meal;
            return _DashboardMealView(meal: meal);
          } else if (state is DietitianDashboardError) {
            return const Center(child: Text("Error loading dashboard"));
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _DashboardMealView extends StatelessWidget {
  final DietitianDashboardMealModel meal;
  const _DashboardMealView({required this.meal});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE29F), Color(0xFFFFA99F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _dashboardDietitianHeader(),
                      const SizedBox(height: 40),
                      Text(
                        "It's ${meal.mealTitle} time!",
                        style: poppinsTextStyle(
                          color: const Color(0xFFDA5647),
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: poppinsTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFFDA5747),
                          ),
                          children: [
                            const TextSpan(text: 'As per your '),
                            TextSpan(
                              text: 'diet plan',
                              style: poppinsTextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDA5747),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          meal.timeRange,
                          textAlign: TextAlign.center,
                          style: poppinsTextStyle(
                            color: const Color(0xFFDA5747),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      FoodContainerList(foodItems: meal.foodItems),
                      _totalFoodCountContainer(context, meal),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Future content goes here",
                    style: poppinsTextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // TestResultScreen(),
                  const SizedBox(height: 1000),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardDietitianHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi sparsh',
              style: poppinsTextStyle(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Good morning',
              style: poppinsTextStyle(
                color: const Color(0xFF252525),
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          height: 40,
          width: 40,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Color(0xFFE48326),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            "assets/images/dietitian_dashboard/messages_icon.svg",
            height: 15,
            width: 15,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          height: 40,
          width: 40,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Color(0xFFE48326),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            "assets/images/common/profile_logo.svg",
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFFFFFFFF),
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  Widget _totalFoodCountContainer(
    BuildContext context,
    DietitianDashboardMealModel meal,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: MediaQuery.of(context).size.height * 0.18,
      decoration: BoxDecoration(
        color: const Color(0xFFF6270E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: poppinsTextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(text: 'Your Meal Macros goal\n'),
                    TextSpan(
                      text: ' 3 items',
                      style: poppinsTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${meal.totalCalories} kcal\nCalories',
                textAlign: TextAlign.right,
                style: poppinsTextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Divider(),
          Row(
            children: [
              Expanded(
                child: _textRowButton(
                  "assets/images/common/doc_svg.svg",
                  "View full plan",
                  () {},
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _textRowButton(
                  "assets/images/common/rice_bowl.svg",
                  "Log this meal",
                  () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textRowButton(String svgAsset, String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(svgAsset),
          SizedBox(width: 5),
          Text(
            text,
            style: poppinsTextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 5),

          const Icon(Icons.keyboard_arrow_right, color: Colors.white),
        ],
      ),
    );
  }
}
