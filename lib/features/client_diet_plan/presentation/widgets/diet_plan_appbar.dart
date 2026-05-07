import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar dietPlanAppBar(){
  return  AppBar(
    backgroundColor: const Color(0xFFF5F7FA),
    surfaceTintColor: const Color(0xFFF5F7FA),
    elevation: 0,
    title: Text(
      "Diet Plan",
      style: GoogleFonts.poppins(
        color: const Color(0xFF252525),
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.30,
      ),
    ),
  );
}