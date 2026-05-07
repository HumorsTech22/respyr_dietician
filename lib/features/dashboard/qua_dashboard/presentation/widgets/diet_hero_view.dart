import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/size/get_height.dart';
import 'diet_hero_meal_card.dart';

class DietHeroView extends StatelessWidget {
  const DietHeroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFE0CD),
      ),
      padding: EdgeInsets.only(
        top: rh(context: context, px: 30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Diet Plan",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFDA5747),
                    fontSize: rh(context: context, px: 12),
                    fontWeight: FontWeight.w400,
                    letterSpacing: rh(context: context, px: -0.24),
                    height: 1.0,
                  ),
                ),
                SizedBox(height: rh(context: context, px: 20)),
                Text(
                  "It’s Breakfast time!",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFDA5747),
                    fontSize: rh(context: context, px: 25),
                    fontWeight: FontWeight.w600,
                    letterSpacing: rh(context: context, px: -1),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: rh(context: context, px: 30)),

          Container(
            height: rh(context: context, px: 305),
            padding: EdgeInsets.only(
              left: rh(context: context, px: 20),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.all(
                rh(context: context, px: 2),
              ),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return const DietHeroMealCard();
              },
              separatorBuilder: (context, index) {
                return SizedBox(width: rh(context: context, px: 20));
              },
              itemCount: 5,
            ),
          ),

          Row(
            children: [
              SizedBox(width: rh(context: context, px: 34)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      CupertinoIcons.arrow_right,
                      color: Color(0xFFDA5747),
                    ),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: rh(context: context, px: 1),
                          color: const Color(0xFFDA5747),
                        ),
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 33),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 15)),
                  Text(
                    "View Full Plan",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFDA5747),
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                      letterSpacing: rh(context: context, px: -0.30),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Image.asset(
                  "assets/images/common/img_breakfast_cloud.png",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}