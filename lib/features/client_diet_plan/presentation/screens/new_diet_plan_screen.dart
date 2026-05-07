import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/client_diet_plan/presentation/widgets/day_selector.dart';
import 'package:respyr_dietitian/features/client_diet_plan/presentation/widgets/diet_main_content.dart';
import 'package:respyr_dietitian/features/client_diet_plan/presentation/widgets/selected_day_diet_view.dart';
import 'package:respyr_dietitian/features/client_diet_plan/utils/meal_color_helper.dart';
import 'package:respyr_dietitian/features/client_diet_plan/utils/meal_helper.dart';

import '../../../../core/size/get_height.dart';
import '../../data/model/weekly_food_model.dart';

class NewDietPlanScreen extends StatefulWidget {
  final List<DietDay> days;
  final int selectedDayIndex;
  final String weekStartDate;
  final ValueChanged<int> onDaySelected;
  final DietDay day;

  const NewDietPlanScreen({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.weekStartDate,
    required this.onDaySelected,
    required this.day,
  });

  @override
  State<NewDietPlanScreen> createState() => _NewDietPlanScreenState();
}

class _NewDietPlanScreenState extends State<NewDietPlanScreen> {
  double? sheetHeight;
  bool isDragging = false;

  void updateSheetHeight({
    required DragUpdateDetails details,
    required double minHeight,
    required double maxHeight,
  }) {
    final currentHeight = sheetHeight ?? minHeight;

    setState(() {
      isDragging = true;

      final newHeight = currentHeight - details.delta.dy;
      sheetHeight = newHeight.clamp(minHeight, maxHeight);
    });
  }

  void settleSheet({
    required DragEndDetails details,
    required double minHeight,
    required double maxHeight,
  }) {
    final velocity = details.primaryVelocity ?? 0;
    final currentHeight = sheetHeight ?? minHeight;

    double targetHeight;

    if (velocity < -300) {
      targetHeight = maxHeight;
    } else if (velocity > 300) {
      targetHeight = minHeight;
    } else {
      final middle = minHeight + ((maxHeight - minHeight) / 2);
      targetHeight = currentHeight > middle ? maxHeight : minHeight;
    }

    setState(() {
      isDragging = false;
      sheetHeight = targetHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMealName = MealHelper().getCurrentMealName();

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final headerHeight = rh(context: context, px: 180);

    final minHeight = headerHeight + bottomPadding;
    final maxHeight = screenHeight;

    final currentHeight = (sheetHeight ?? minHeight).clamp(
      minHeight,
      maxHeight,
    );

    final isFullScreen = currentHeight >= screenHeight * 0.98;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MealColorHelper().getMealBgColor(currentMealName),
      body: Stack(
        children: [
          Positioned.fill(
            child: mainContentDietPlan(
              context,
              days: widget.days,
              weekStartDate: widget.weekStartDate,
            ),
          ),

          Positioned(
            left: 0,
            right: 0,

            // THIS IS THE MAIN FIX
            // Bottom is always zero.
            // It will never move while dragging.
            bottom: 0,

            height: currentHeight,

            child: AnimatedContainer(
              duration: isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                    isFullScreen ? 0 : rh(context: context, px: 24),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: (details) {
                      updateSheetHeight(
                        details: details,
                        minHeight: minHeight,
                        maxHeight: maxHeight,
                      );
                    },
                    onVerticalDragEnd: (details) {
                      settleSheet(
                        details: details,
                        minHeight: minHeight,
                        maxHeight: maxHeight,
                      );
                    },
                    child: Container(
                      height: headerHeight,
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        top: rh(context: context, px: 20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: rh(context: context, px: 45),
                            height: rh(context: context, px: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),

                          SizedBox(height: rh(context: context, px: 18)),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Diet plan",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: rh(context: context, px: 25),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "05 July - 19 July",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: rh(context: context, px: 15),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: rh(context: context, px: 20)),

                          DaySelector(
                            days: widget.days,
                            selectedDayIndex: widget.selectedDayIndex,
                            weekStartDate: widget.weekStartDate,
                            onDaySelected: widget.onDaySelected,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: CustomScrollView(
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        SelectedDayDietView(day: widget.day),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}