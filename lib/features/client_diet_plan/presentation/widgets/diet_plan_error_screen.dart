import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'diet_plan_appbar.dart';

class  DietPlanErrorScreen extends StatelessWidget {
  final String errorMessage;
  const  DietPlanErrorScreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {

    if(errorMessage.contains("No weekly data found for last 3 months")){
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: dietPlanAppBar(),
        body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 30
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 30
                    ),
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF5F7FA),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0xFFD9D9D9),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Column(
                      children: [
                        Image.asset("assets/images/icons/ic_no_history.png"),
                        Text("No active or previous diet plans were found for your profile",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFA1A1A1),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            height: 1.10,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: dietPlanAppBar(),
      body: SafeArea(
          child: Center(
            child: Text(errorMessage,
             textAlign: TextAlign.center,

            ),
          )
      ),
    );
  }
}
