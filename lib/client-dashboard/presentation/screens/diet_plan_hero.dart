import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/model/dietitian_model.dart';
import 'package:respyr_dietitian/features/dashboard_menu/peresentation/dashboard_menu_screen.dart';

import '../../features/chat_manger/presentation/screen/chat_screen.dart';
import '../extras/meal_type_helper.dart';
import '../model/client_profile_model.dart';
import '../widgets/diet_food_item_card.dart';

class DietPlanHero extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianModel dietitianModel;
  const DietPlanHero({
    super.key,
    required this.clientProfileModel,
    required this.dietitianModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: ThemeHelper().getHeroGradient(),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientProfileModel.profileName,
                      style: GoogleFonts.poppins(
                        color: ThemeHelper().getGreetingTextColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.30,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      ThemeHelper().getGreetingMessage(),
                      style: GoogleFonts.poppins(
                        color: ThemeHelper().getGreetingTextColor(),
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                        height: 1.2,
                      ),
                    )
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          dietitianModel: dietitianModel,
                        ),
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: ThemeHelper().getThemeDarkColor(),
                  ),
                  icon: SvgPicture.asset("assets/images/icons/ic_message.svg"),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardMenuScreen(clientProfileModel: clientProfileModel,
                         
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: "client-image",
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(clientProfileModel.profileImage),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 41),
          SizedBox(
            width: double.infinity,
            child: Center(
              child: Text(
                "It’s after lunch time!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: ThemeHelper().getThemeDarkColor(),
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.68,
                ),
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "As per your",
                  style: GoogleFonts.poppins(
                    color: ThemeHelper().getThemeDarkColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.30,
                  ),
                ),
                TextSpan(
                  text: " diet plan",
                  style: GoogleFonts.poppins(
                    color: ThemeHelper().getThemeDarkColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 33),
          Container(
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25000),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              "8:00–9:00 AM",
              style: GoogleFonts.poppins(
                color: ThemeHelper().getThemeDarkColor(),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.30,
              ),
            ),
          ),
          const SizedBox(height: 33),
          ListView.builder(
            itemCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return DietPlanWidgets().dietFoodItemCard(index: index + 1);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 150),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.50,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: ThemeHelper().getThemeDarkColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Your Meal Macros goal",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.20,
                                    ),
                                  ),
                                  Text(
                                    "3 items",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.26,
                                      letterSpacing: -0.30,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "291 kcal\nCalories",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.26,
                                  letterSpacing: -0.40,
                                ),
                              ),
                            ],
                          ),
                          Container(height: 0.5, width: double.infinity, color: Colors.white),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset("assets/images/icons/ic_diet_plan.svg"),
                                    const SizedBox(width: 5),
                                    Text(
                                      "View full plan",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        height: 1.10,
                                        letterSpacing: -0.24,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset("assets/images/icons/ic_food.svg"),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Log this meal",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        height: 1.10,
                                        letterSpacing: -0.24,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 33),
        ],
      ),
    );
  }
}
