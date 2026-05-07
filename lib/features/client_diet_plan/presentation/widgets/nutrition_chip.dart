import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bluetooth_device_connectivity/presentation/widgets/new_start_test_counter_screen.dart';

Widget nutritionChip({
  required BuildContext context,
  required String text,
  required Color textColor,
  required Color bgColor,
}) {
  return Container(
    decoration: ShapeDecoration(
      color: bgColor,
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
      text,
      style: GoogleFonts.poppins(
        color: textColor,
        fontSize: rh(context: context, px: 10),
        fontWeight: FontWeight.w600,
        height: 1.10,
        letterSpacing: rh(context: context, px: -0.20),
      ),
    ),
  );
}