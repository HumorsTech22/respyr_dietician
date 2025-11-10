import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/utils/score_utils.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_state.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/metabolism_tab_card.dart';

class SectionWidget extends StatelessWidget {
  final GlobalKey sectionKey;
  final String metabolismType;
  final DietitianResultState state;

  const SectionWidget({
    super.key,
    required this.sectionKey,
    required this.metabolismType,
    required this.state,
  });

  static final Map<String, String> _sectionHeaderIcon = {
    "Gut": "assets/images/result_screen/dietitian_gut_outline.svg",
    "Fat": "assets/images/result_screen/dietitian_pancreas_outline.svg",
    "Liver": "assets/images/result_screen/dietitian_liver_outline.svg",
  };

  static final Map<String, String> _metabolismTitle = {
    "Gut": "Gut Fermentation Metabolism",
    "Fat": "Glucose -Vs- Fat Metabolism",
    "Liver": "Liver Hepatic Metabolism",
  };

  static final Map<String, List<String>> _metabolismSubTypes = {
    "Gut": ["Absorptive Metabolism Score", "Fermentative Metabolism Score"],
    "Fat": ["Fat Metabolism Score", "Glucose Metabolism Score"],
    "Liver": [
      "Hepatic Stress Metabolism Score",
      "Detoxification Metabolism Score",
    ],
  };

  @override
  Widget build(BuildContext context) {
    final subTypes = _metabolismSubTypes[metabolismType] ?? [];
    final result = state.dietitianResult;
    if (result == null) return const SizedBox();

    final metabolism = result.respyrResponse.metabolismScoreAnalysis;
    final markers = result.respyrResponse.breathMarkerAnalysis;

    int ppm = 0;
    String mainMarker = '';

    switch (metabolismType) {
      case "Gut":
        mainMarker = "Hydrogen";
        ppm = markers.hydrogen.ppm;
        break;
      case "Fat":
        mainMarker = "Acetone";
        ppm = markers.acetone.ppm;
        break;
      case "Liver":
        mainMarker = "Ethanol";
        ppm = markers.ethanol.ppm;
        break;
    }

    final metab1 = switch (metabolismType) {
      "Gut" => metabolism.absorption,
      "Fat" => metabolism.fatMetabolism,
      "Liver" => metabolism.hepaticStress,
      _ => metabolism.absorption,
    };
    final metab2 = switch (metabolismType) {
      "Gut" => metabolism.fermentation,
      "Fat" => metabolism.glucoseMetabolism,
      "Liver" => metabolism.detoxification,
      _ => metabolism.fermentation,
    };

    final metab1Score = metab1.score;
    final metab2Score = metab2.score;

    final metab1Level = getScoreLevel(metab1Score);
    final metab2Level = getScoreLevel(metab2Score);

    return Container(
      key: sectionKey,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDEE2E6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Main Marker: $mainMarker',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${ppm.toStringAsFixed(0)} ppm',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // 1st metabolism subtype card
                MetabolismTabCard(
                  metabolismSubtype: subTypes[0],
                  score: metab1Score,
                  rating: metab1Level.label,
                  ratingColor: metab1Level.color,
                  interpretation: metab1.interpretation,
                  clientState: metab1.clientState,
                  ppmNote: metab1.ppmNote,
                ),
                const SizedBox(height: 15),

                // 2nd metabolism subtype card
                MetabolismTabCard(
                  metabolismSubtype: subTypes[1],
                  score: metab2Score,
                  rating: metab2Level.label,
                  ratingColor: metab2Level.color,
                  interpretation: metab2.interpretation,
                  clientState: metab2.clientState,
                  ppmNote: metab2.ppmNote,
                ),
              ],
            ),
          ),

          // Floating Header Label
          Positioned(
            top: 0,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: Colors.white,
              child: Row(
                children: [
                  SvgPicture.asset(
                    _sectionHeaderIcon[metabolismType] ?? '',
                    width: 15,
                    height: 15,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF308BF9),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _metabolismTitle[metabolismType] ?? '',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
