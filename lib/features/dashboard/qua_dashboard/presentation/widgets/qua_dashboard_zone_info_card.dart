import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/respyr_unified_response.dart';

class QuaDashboardZoneInfoCard extends StatelessWidget {
  final Color themeColor;
  final UnifiedPrimaryTrend primaryTrend;

  const QuaDashboardZoneInfoCard({
    super.key,
    required this.themeColor,
    required this.primaryTrend,
  });

  @override
  Widget build(BuildContext context) {
    final String zone = primaryTrend.zone;
    final String interpretation = primaryTrend.clientInterpretation.text;
    final String zoneBase = zone.toLowerCase() == "focus" ? "needs to" : "is";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            "Your Trend $zoneBase $zone!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: themeColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            interpretation,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF4A4A4A),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}