import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../extras/meal_type_helper.dart';


class DietPlanWidgets{
  Widget dietFoodItemCard({required int index}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: BoxConstraints( maxHeight: 100),
        width: double.infinity,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
        ),
        child: Stack(
          children: [
            // ⬇️ Apply opacity to the background
            Opacity(
              opacity: 0.5,
              child: Container(
                height: double.infinity,
                decoration: ShapeDecoration(
                  gradient: ThemeHelper().getDietItemGradient(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            // ⬇️ Keep text fully visible
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  SvgPicture.asset("assets/images/icons/food_cat_meal.svg"),
                  Text(index.toString(),
                    style: GoogleFonts.poppins(
                      color: ThemeHelper().getThemeDarkColor(),
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      height: 1.26,
                      letterSpacing: -0.50,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Moong Dal Chilla",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                          letterSpacing: -0.30,
                        ),
                      ),
                      SizedBox(height: 4,),
                      Text("2 ladles (60g each)",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.20,
                        ),
                      )
                    ],
                  ),
                  Text("220 kcal",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.30,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

