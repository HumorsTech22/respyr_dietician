import 'package:flutter/material.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/client_diet_plan/data/model/weekly_food_model.dart';

import 'meal_card.dart';

class SelectedDayDietView extends StatelessWidget {
  final DietDay day;

  const SelectedDayDietView({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    // return SliverList(
    //   delegate: SliverChildListDelegate(
    //     [
    //       Padding(
    //         padding: EdgeInsets.symmetric(
    //           horizontal: rh(context: context, px: 15),
    //         ),
    //         child: MealCard(title: 'Breakfast', foods: day.breakfast.foods),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(
    //           horizontal: rh(context: context, px: 15),
    //         ),
    //         child: MealCard(title: 'Lunch', foods: day.lunch.foods),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(
    //           horizontal: rh(context: context, px: 15),
    //         ),
    //         child: MealCard(title: 'Snacks', foods: day.snacks.foods),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(
    //           horizontal: rh(context: context, px: 15),
    //         ),
    //         child: MealCard(title: 'Dinner', foods: day.dinner.foods),
    //       ),
    //     ],
    //   ),
    // );


    return Column(
           children: [
             Padding(
               padding: EdgeInsets.symmetric(
                 horizontal: rh(context: context, px: 15),
               ),
               child: MealCard(title: 'Breakfast', foods: day.breakfast.foods),
             ),
             Padding(
               padding: EdgeInsets.symmetric(
                 horizontal: rh(context: context, px: 15),
               ),
               child: MealCard(title: 'Lunch', foods: day.lunch.foods),
             ),
             Padding(
               padding: EdgeInsets.symmetric(
                 horizontal: rh(context: context, px: 15),
               ),
               child: MealCard(title: 'Snacks', foods: day.snacks.foods),
             ),
             Padding(
               padding: EdgeInsets.symmetric(
                 horizontal: rh(context: context, px: 15),
               ),
               child: MealCard(title: 'Dinner', foods: day.dinner.foods),
             ),
           ],
        );
  }
}