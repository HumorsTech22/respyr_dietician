import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_horizontal_calendar/utils/app_color.dart';

import '../../../../core/size/get_height.dart';

class IsExhaledInInhale extends StatelessWidget {
  final VoidCallback startAgainClicked;

  const IsExhaledInInhale({super.key, required this.startAgainClicked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You breathed air out\nInstead of In",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 25),
              fontWeight: FontWeight.w600,
              height: 1.29,
              letterSpacing: rh(context: context, px: -1),
            ),
          ),
          Image.asset("assets/images/device_connection/img_inhale_screen_exhale.png"),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                startAgainClicked();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 18)),
                backgroundColor: const Color(0xFF308BF9),
              ),
              child: Text(
                "Try again",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w700,
                  height: 1.10,
                  letterSpacing: rh(context: context, px: 0.30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
