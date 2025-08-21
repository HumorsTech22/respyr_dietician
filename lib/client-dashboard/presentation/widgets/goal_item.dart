import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget goalItem({required String goalName, required String currentStat,required String targetStat,}){
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
      SizedBox(height: 20,),
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