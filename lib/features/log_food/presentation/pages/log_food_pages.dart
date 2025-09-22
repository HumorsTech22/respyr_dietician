import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/log_food/domain/entities/food_item.dart';
import 'package:respyr_dietitian/features/log_food/domain/entities/meal_category.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/log_food_cubit.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/log_food_state.dart';
import 'package:respyr_dietitian/features/log_food/presentation/widgets/log_food_item_list.dart';
import 'package:respyr_dietitian/features/log_food/presentation/widgets/nutrients_progess.dart';

class LogFoodPage extends StatelessWidget {
  const LogFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: BlocBuilder<LogFoodCubit, LogFoodState>(
          builder: (context, state) {
            if (state.selectedCategory == null) {
              context.read<LogFoodCubit>().openCategory(MealCategory.wakeUp);
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.arrow_back_sharp),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log food',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                '07 July',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  height: 1.10,
                                  letterSpacing: -0.20,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF308BF9),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'Save',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.10,
                                letterSpacing: 0.30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                  ),
                                ),
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  children: [
                                    _buildCategoryCard(
                                      context,
                                      MealCategory.wakeUp,
                                      "Wake Up",
                                      "05:30-06:30 AM",
                                    ),
                                    const Divider(),
                                    _buildCategoryCard(
                                      context,
                                      MealCategory.breakfast,
                                      "Breakfast",
                                      "08:00-09:00 AM",
                                    ),
                                    const Divider(),
                                    _buildCategoryCard(
                                      context,
                                      MealCategory.lunch,
                                      "Lunch",
                                      "12:00-01:00 PM",
                                    ),
                                    const Divider(),
                                    _buildCategoryCard(
                                      context,
                                      MealCategory.snacks,
                                      "Snacks",
                                      "04:00-05:00 PM",
                                    ),
                                    const Divider(),
                                    _buildCategoryCard(
                                      context,
                                      MealCategory.dinner,
                                      "Dinner",
                                      "08:30-09:30 PM",
                                    ),
                                    const Divider(),
                                    _buildCategoryCard(
                                      context,
                                      MealCategory.sleep,
                                      "Sleep",
                                      "11:30-05:30 AM",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              flex: 3,
                              child: _buildFoodList(context, state),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (state.isBottomSheetOpen)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap:
                          () => context.read<LogFoodCubit>().closeBottomSheet(),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          color: Colors.grey.shade400.withAlpha(174),
                        ),
                      ),
                    ),
                  ),
                if (state.isBottomSheetOpen)
                  DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.6,
                    maxChildSize: 0.6,
                    builder: (_, controller) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: ListView(
                            controller: controller,
                            padding: const EdgeInsets.all(20),
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(
                                          value: 0.75,
                                          strokeWidth: 6,
                                          backgroundColor: Colors.grey.shade200,
                                          color: Colors.orange,
                                        ),
                                        Center(
                                          child: SvgPicture.asset(
                                            "assets/images/common/calories.svg",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Calories',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF535359),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          height: 1.10,
                                          letterSpacing: -0.24,
                                        ),
                                      ),
                                      Text(
                                        '1200 kcal',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF252525),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          height: 1.26,
                                          letterSpacing: -0.40,
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF252525),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.20,
                                          ),
                                          children: [
                                            TextSpan(text: 'out of '),
                                            TextSpan(
                                              text: '1800kcal',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: NutrientsProgessWidget(
                                      name: "Protein",
                                      value: "70g",
                                      total: "100g",
                                      color: Color(0xFFFFC412),
                                      progress: 0.70,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: NutrientsProgessWidget(
                                      name: "Protein",
                                      value: "30g",
                                      total: "100g",
                                      color: Color(0xFF38A250),
                                      progress: 0.30,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: NutrientsProgessWidget(
                                      name: "Protein",
                                      value: "80g",
                                      total: "100g",
                                      color: Color(0xFF38A250),
                                      progress: 0.80,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: NutrientsProgessWidget(
                                      name: "Protein",
                                      value: "21g",
                                      total: "100g",
                                      color: Color(0xFFFFC412),
                                      progress: 0.21,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: _bottomNavigation(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context, LogFoodState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 4,
                  backgroundColor: Colors.white24,
                  color: Colors.greenAccent,
                ),
                const Center(
                  child: Icon(Icons.emoji_events, color: Colors.white),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Daily Goal',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '75% completed',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              context.read<LogFoodCubit>().toggleBottomSheet();
            },
            icon: Icon(
              state.isBottomSheetOpen ? Icons.close : Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(BuildContext context, LogFoodState state) {
    final scrollController = ScrollController();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topRight: Radius.circular(15)),
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        radius: const Radius.circular(10),
        thickness: 2,
        child: Column(
          children: [
            _buildSelectAllRow(
              context,
              context.read<LogFoodCubit>().itemsForSelectedCategory,
              state.selectedCategory!,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount:
                    context
                        .read<LogFoodCubit>()
                        .itemsForSelectedCategory
                        .length,
                itemBuilder: (context, index) {
                  final item =
                      context
                          .read<LogFoodCubit>()
                          .itemsForSelectedCategory[index];
                  return Column(
                    children: [
                      LogFoodItemList(
                        item: item,
                        onTap: () {
                          final realIndex = context
                              .read<LogFoodCubit>()
                              .state
                              .items
                              .indexOf(item);
                          context.read<LogFoodCubit>().toggleItem(realIndex);
                        },
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectAllRow(
    BuildContext context,
    List<FoodItem> items,
    MealCategory category,
  ) {
    final allSelected = items.every((item) => item.isSelected);
    return Row(
      children: [
        Checkbox(
          checkColor: const Color(0xFF308BF9),
          activeColor: Colors.white,
          side: WidgetStateBorderSide.resolveWith(
            (states) => const BorderSide(color: Color(0xFFA1A1A1), width: 2),
          ),
          value: allSelected,
          onChanged: (_) {
            context.read<LogFoodCubit>().toggleSelectAll(
              category,
              !allSelected,
            );
          },
        ),
        Text(
          'Select all',
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    MealCategory category,
    String title,
    String time,
  ) {
    final cubit = context.watch<LogFoodCubit>();
    final selected = cubit.selectedCount(category);
    final total = cubit.totalCount(category);

    String statusText;
    Color statusColor;
    Color statusTextColor;

    if (selected == 0) {
      statusText = "Pending";
      statusColor = const Color(0xFFFFEFED);
      statusTextColor = const Color(0xFFDA5747);
    } else if (selected < total) {
      statusText = "$selected/$total Selected";
      statusColor = const Color(0xFFF0F0F0);
      statusTextColor = const Color(0xFF595959);
    } else {
      statusText = "$selected/$total Selected";
      statusColor = const Color(0xFFEBFFF0);
      statusTextColor = const Color(0xFF3FAF58);
    }

    return GestureDetector(
      onTap: () => context.read<LogFoodCubit>().openCategory(category),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: -0.48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: statusColor,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 60,
                    maxWidth: 100,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        color: statusTextColor,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Text(
              time,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
