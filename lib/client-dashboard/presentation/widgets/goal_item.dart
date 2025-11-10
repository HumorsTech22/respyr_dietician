import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget goalItem({required String goalName, required String currentStat,required String targetStat,}){


  bool isTargetCompleted;

  if (double.parse(currentStat) >= double.parse(targetStat)) {
    isTargetCompleted = true;
  } else {
    isTargetCompleted = false;
  }


  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(goalName,
        style: GoogleFonts.poppins(
          color: const Color(0xFF535359),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.10,
          letterSpacing: -0.24,
        ),
      ),
      SizedBox(height: 20,),
      Row(
        children: [
          statItem(message: currentStat, headingText: "Current stat"),
          Spacer(),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey,
            ),
          ),
          Spacer(),
          statItem(message: targetStat, headingText: "Target stat"),
        ],
      ),
      SizedBox(height: 10,),

      Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: isTargetCompleted ? Color(0xFFD0F3D8) : Color(0xFFF2D1CD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          spacing: 20,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(currentStat,
                  style: GoogleFonts.poppins(
                    color:isTargetCompleted ?   Color(0xFF0B8226) :Color(0xFF7E190C) ,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.26,
                    letterSpacing: -0.40,
                  ),
                ),
                Text("Current stat",
                  style: GoogleFonts.poppins(
                    color:isTargetCompleted ?   Color(0xFF0B8226) :Color(0xFF7E190C) ,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.20,
                  ),
                )
              ],
            ),
            Expanded(
                child: Text(
                  isTargetCompleted
                      ? "Congratulations! You’ve achieved your target stat."
                      : "You are ${int.parse(targetStat) - int.parse(currentStat)} away from reaching your target.",
                  style: GoogleFonts.poppins(
                    color: isTargetCompleted ? Color(0xFF0B8226) : Color(0xFF7E190C),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.20,
                  ),
                )

            )
          ],
        ),
      ),
      SizedBox(height: 30,),
    ],
  );
}


Column statItem({required String message,required String headingText}){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(message,
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.26,
          letterSpacing: -0.40,
        ),
      ),
      Text(headingText,
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.20,
        ),
      )
    ],
  );
}