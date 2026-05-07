import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/respyr_unified_response.dart';

class QuaDashboardScoreDisplay extends StatelessWidget {
  final UnifiedPrimaryTrend primaryTrend;

  const QuaDashboardScoreDisplay({
    super.key,
    required this.primaryTrend,
  });

  @override
  Widget build(BuildContext context) {
    final double score = primaryTrend.score;

    return Column(
      children: [
        Text(
          primaryTrend.screenTitle,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              score.toStringAsFixed(0),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 100,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "%",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}