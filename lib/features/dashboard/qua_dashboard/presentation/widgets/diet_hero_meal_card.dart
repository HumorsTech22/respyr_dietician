import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/size/get_height.dart';

class DietHeroMealCard extends StatelessWidget {
  const DietHeroMealCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rh(context: context, px: 214),
      height: rh(context: context, px: 302),
      margin: EdgeInsets.only(
        top: rh(context: context, px: 10),
        left: rh(context: context, px: 10),
        bottom: rh(context: context, px: 10)
      ),
      decoration: ShapeDecoration(
        color: const Color(0xFFFDFDFD),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: rh(context: context, px: 2),
            strokeAlign: BorderSide.strokeAlignOutside,
            color: const Color(0xFFDA5747),
          ),
          borderRadius: BorderRadius.circular(
            rh(context: context, px: 15),
          ),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0xFFDA5747),
            blurRadius: 0,
            offset: Offset(
              rh(context: context, px: -6),
              rh(context: context, px: -6),
            ),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: rh(context: context, px: 166),
            ),
            width: double.infinity,
            child: Image.asset(
              "assets/images/common/img_food_dummy.png",
            ),
          ),

          SizedBox(height: rh(context: context, px: 15)),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 15),
              ),
              child: Column(
                children: [
                  Text(
                    "Carrot + beetroot + fresh turmeric & zinger [ little ] with lemon drops",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: rh(context: context, px: 12),
                      fontWeight: FontWeight.w600,
                      height: 1.26,
                      letterSpacing: rh(context: context, px: -0.24),
                    ),
                  ),

                  SizedBox(height: rh(context: context, px: 10)),

                  Row(
                    children: [
                      Text(
                        "250Kcal",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 10),
                          fontWeight: FontWeight.w400,
                          letterSpacing: rh(context: context, px: -0.20),
                        ),
                      ),
                      SizedBox(width: rh(context: context, px: 4)),
                      Container(
                        width: rh(context: context, px: 3),
                        height: rh(context: context, px: 3),
                        decoration: const ShapeDecoration(
                          color: Color(0xFF535359),
                          shape: OvalBorder(),
                        ),
                      ),
                      SizedBox(width: rh(context: context, px: 4)),
                      Text(
                        "1 cup (250 ml)",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 10),
                          fontWeight: FontWeight.w400,
                          letterSpacing: rh(context: context, px: -0.20),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: rh(context: context, px: 10)),

                  SizedBox(
                    height: rh(context: context, px: 21),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: ShapeDecoration(
                            color: const Color(0x19E76F51),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 5),
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: rh(context: context, px: 5),
                            horizontal: rh(context: context, px: 10),
                          ),
                          child: Text(
                            "Protein 25g",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFE76F51),
                              fontSize: rh(context: context, px: 10),
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                              letterSpacing: rh(context: context, px: -0.20),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          width: rh(context: context, px: 4),
                        );
                      },
                      itemCount: 5,
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