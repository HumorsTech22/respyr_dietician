import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/client_diet_plan/data/model/weekly_food_model.dart';
import 'package:respyr_dietitian/features/client_diet_plan/utils/meal_color_helper.dart';

import 'food_item_card.dart';

class MealCard extends StatefulWidget {
  final String title;
  final List<FoodItem> foods;

  const MealCard({
    super.key,
    required this.title,
    required this.foods,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  final PageController _pageController = PageController(
    viewportFraction: 0.68,
  );

  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String getTime(String title) {
    switch (title.toLowerCase()) {
      case "breakfast":
        return "08:00-09:00 AM";
      case "lunch":
        return "12:30-01:30 PM";
      case "snacks":
        return "04:00-05:00 PM";
      case "dinner":
        return "08:00-09:00 PM";
      default:
        return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: rh(context: context, px: 14),
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: rh(context: context, px: 1),
            color: const Color(0xFFD9D9D9),
          ),
          borderRadius: BorderRadius.circular(
            rh(context: context, px: 15),
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: rh(context: context, px: 17),
        bottom: rh(context: context, px: 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 18),
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    letterSpacing: rh(context: context, px: -0.72),
                  ),
                ),
                SizedBox(height: rh(context: context, px: 10)),
                Text(
                  getTime(widget.title),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 12),
                    fontWeight: FontWeight.w400,
                    letterSpacing: rh(context: context, px: -0.24),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: rh(context: context, px: 12)),

          if (widget.foods.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 15),
              ),
              child: Text(
                'No food added',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF777777),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          else ...[
            SizedBox(
              height: rh(context: context, px: 292),
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                padEnds: false,
                itemCount: widget.foods.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0
                            ? rh(context: context, px: 20)
                            : rh(context: context, px: 0),
                        right: rh(context: context, px: 10),
                      ),
                      child: FoodItemCard(
                        food: widget.foods[index],
                        index: index + 1, mealType: widget.title,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: rh(context: context, px: 18)),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.foods.length,
                      (index) {
                    final bool isActive = _currentIndex == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.symmetric(
                        horizontal: rh(context: context, px: 3),
                      ),
                      width: rh(context: context, px: 8),
                      height: rh(context: context, px: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? MealColorHelper().getMealColor(widget.title)
                            : const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 20),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}