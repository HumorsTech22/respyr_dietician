import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/helpers/macro_colors.dart';

Widget macroInfoCard({
  required String macroType,
  required double macroValue,
  required double changePercent,
  required String changeType,
  required BuildContext context,
}) {
  final bool isIncrease = changeType.toLowerCase() == "increase";
  final bool isDecrease = changeType.toLowerCase() == "decrease";
  final bool isNoChange = changeType.toLowerCase() == "no_change";

  final IconData icon = isDecrease
      ? CupertinoIcons.arrow_down
      : isIncrease
      ? CupertinoIcons.arrow_up
      : CupertinoIcons.minus;

  final Color changeColor = isDecrease
      ? const Color(0xFFE76F51)
      : isIncrease
      ? const Color(0xFF2A9D8F)
      : const Color(0xFF535359);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: rh(context: context, px: 6),
            height: rh(context: context, px: 6),
            decoration: ShapeDecoration(
              color: MacroColors.getColor(macroType),
              shape: const OvalBorder(),
            ),
          ),
          SizedBox(width: rh(context: context, px: 5)),
          Text(
            macroType,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 10),
              fontWeight: FontWeight.w600,
              height: 1,
              letterSpacing: rh(context: context, px: -0.20),
            ),
          ),
        ],
      ),
      SizedBox(height: rh(context: context, px: 20)),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            macroValue % 1 == 0
                ? macroValue.toInt().toString()
                : macroValue.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 40),
              height: 1,
              fontWeight: FontWeight.w400,
              letterSpacing: rh(context: context, px: -0.80),
            ),
          ),
          SizedBox(width: rh(context: context, px: 5)),
          Text(
            "g",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 10),
              fontWeight: FontWeight.w400,
              height: -3,
              letterSpacing: rh(context: context, px: -0.20),
            ),
          ),
        ],
      ),
      SizedBox(height: rh(context: context, px: 4)),
      if (!isNoChange) ...[
        Row(
          children: [
            Icon(
              icon,
              size: rh(context: context, px: 12),
              color: changeColor,
            ),
            SizedBox(width: rh(context: context, px: 2)),
            Text(
              changePercent.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                color: changeColor,
                fontSize: rh(context: context, px: 10),
                fontWeight: FontWeight.w600,
                letterSpacing: rh(context: context, px: -0.20),
              ),
            ),
          ],
        ),
      ],
    ],
  );
}