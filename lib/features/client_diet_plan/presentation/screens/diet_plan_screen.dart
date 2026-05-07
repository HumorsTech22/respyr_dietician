import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/client_diet_plan/presentation/widgets/day_selector.dart';
import 'package:respyr_dietitian/features/client_diet_plan/presentation/widgets/selected_day_diet_view.dart';
import 'package:respyr_dietitian/features/client_diet_plan/utils/diet_plan_date_helper.dart';
import 'package:respyr_dietitian/features/client_diet_plan/utils/meal_color_helper.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:respyr_dietitian/features/client_diet_plan/data/model/weekly_food_model.dart';

class DietScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final List<DietDay> days;
  final int selectedDayIndex;
  final String weekStartDate;
  final ValueChanged<int> onDaySelected;
  final DietDay day;

  const DietScreen({
    super.key,
    required this.clientProfileModel,
    required this.days,
    required this.selectedDayIndex,
    required this.weekStartDate,
    required this.onDaySelected,
    required this.day,
  });

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  late final SheetController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = SheetController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = MealColorHelper().getMealBgColor("breakfast");

    return DefaultSheetController(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          surfaceTintColor: bgColor,
          automaticallyImplyLeading: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: rh(context: context, px: 10)),
              Text(
                "Today’s Diet",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFDA5747),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                  height: 1.0,
                ),
              ),
              SizedBox(height: rh(context: context, px: 10)),
              Text(
                "It’s Breakfast time!",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFDA5647),
                  fontSize: rh(context: context, px: 20),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.40,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),

        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double parentHeight = constraints.maxHeight;

              // Increased because now header contains handle + title + day selector.
              final double handleHeight = rh(context: context, px: 170);

              final double topPadding = rh(context: context, px: 16);
              final double bottomInset =
                  MediaQuery.viewPaddingOf(context).bottom;

              final double sheetHeight = parentHeight - topPadding;

              final SheetOffset minSheetOffset = SheetOffset.absolute(
                handleHeight + bottomInset,
              );

              return Stack(
                children: [
                  Positioned.fill(
                    child: _DietBehindContent(
                      clientProfileModel: widget.clientProfileModel,
                    ),
                  ),

                  SheetViewport(
                    padding: EdgeInsets.only(
                      top: topPadding,
                    ),
                    child: Sheet(
                      controller: _sheetController,
                      initialOffset: minSheetOffset,
                      snapGrid: SheetSnapGrid(
                        snaps: [
                          minSheetOffset,
                          const SheetOffset(0.55),
                          const SheetOffset(1),
                        ],
                      ),
                      physics: const BouncingSheetPhysics(),
                      scrollConfiguration: const SheetScrollConfiguration(),
                      decoration: MaterialSheetDecoration(
                        size: SheetSize.fit,
                        color: Colors.white,
                        elevation: rh(context: context, px: 12),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            rh(context: context, px: 24),
                          ),
                        ),
                      ),
                      child: SizedBox(
                        height: sheetHeight,
                        child: Column(
                          children: [
                            _SheetHeader(
                              handleHeight: handleHeight,
                              days: widget.days,
                              selectedDayIndex: widget.selectedDayIndex,
                              weekStartDate: widget.weekStartDate,
                              onDaySelected: widget.onDaySelected,
                            ),

                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    SelectedDayDietView(day: widget.day),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final double handleHeight;
  final List<DietDay> days;
  final int selectedDayIndex;
  final String weekStartDate;
  final ValueChanged<int> onDaySelected;

  const _SheetHeader({
    required this.handleHeight,
    required this.days,
    required this.selectedDayIndex,
    required this.weekStartDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: handleHeight,
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(height: rh(context: context, px: 32.5)),

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
                  DietPlanDateHelper.formatWeekRange(weekStartDate),
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

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10
            ),
            child: Container(
              decoration: ShapeDecoration(
                color: const Color(0xFFF5F7FA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5
              ),
              child: DaySelector(
                days: days,
                selectedDayIndex: selectedDayIndex,
                weekStartDate: weekStartDate,
                onDaySelected: onDaySelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DietBehindContent extends StatelessWidget {
  final ClientProfileModel clientProfileModel;

  const _DietBehindContent({
    super.key,
    required this.clientProfileModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: rh(context: context, px: 25)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 15),
          ),
          child: SizedBox(
            width: double.infinity,
            height: rh(context: context, px: 468),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 15),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: rh(context: context, px: 20),
                      top: rh(context: context, px: 20),
                      bottom: rh(context: context, px: 56),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Intake Summary(3 items)",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFDA5747),
                            fontSize: rh(context: context, px: 10),
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.20,
                          ),
                        ),
                        Text(
                          "291 kcal Calories",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFDA5747),
                            fontSize: rh(context: context, px: 20),
                            fontWeight: FontWeight.w700,
                            height: 1.26,
                            letterSpacing: -0.40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}