import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/generating_result_model.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_state.dart';

class MetabolismCard extends StatelessWidget {
  final String metabolismType; // "Gut" | "Fat" | "Liver"
  final DietitianResultState state;
  final GeneratingResultModel result;

  const MetabolismCard({
    super.key,
    required this.metabolismType,
    required this.state,
    required this.result,
  });

  // Icons
  static final Map<String, String> _metabolismIcon = {
    "Gut": "assets/images/result_screen/dietitian_gut_outline.svg",
    "Fat": "assets/images/result_screen/dietitian_pancreas_outline.svg",
    "Liver": "assets/images/result_screen/dietitian_liver_outline.svg",
  };

  // Titles
  static final Map<String, String> _metabolismTitle = {
    "Gut": "Gut Fermentation Metabolism",
    "Fat": "Glucose\n-Vs-\nFat Metabolism",
    "Liver": "Liver Hepatic Metabolism",
  };

  // Subtype labels
  static final Map<String, String> _metabolismSubTypeOne = {
    "Gut": "Absorptive Metabolism Score",
    "Fat": "Fat Metabolism Score",
    "Liver": "Hepatic Stress Metabolism Score",
  };

  static final Map<String, String> _metabolismSubTypeTwo = {
    "Gut": "Fermentative Metabolism Score",
    "Fat": "Glucose Metabolism Score",
    "Liver": "Detoxification Metabolism Score",
  };

  /// 🔢 Scores from API (as int %)
  Map<String, int> _getScores(GeneratingResultModel result) {
    final metabolism = result.respyrResponse.metabolismScoreAnalysis;
    int toInt(num? value) => (value ?? 0).toInt();

    switch (metabolismType) {
      case "Gut":
        return {
          "one": toInt(metabolism.absorption.score),
          "two": toInt(metabolism.fermentation.score),
        };
      case "Fat":
        return {
          "one": toInt(metabolism.fatMetabolism.score),
          "two": toInt(metabolism.glucoseMetabolism.score),
        };
      case "Liver":
        return {
          "one": toInt(metabolism.hepaticStress.score),
          "two": toInt(metabolism.detoxification.score),
        };
      default:
        return {"one": 0, "two": 0};
    }
  }

  /// 🏷️ Zones from API ("Good", "Fair", "Poor")
  Map<String, String> _getZones(GeneratingResultModel result) {
    final metabolism = result.respyrResponse.metabolismScoreAnalysis;
    String safe(String? v) => v ?? '';

    switch (metabolismType) {
      case "Gut":
        return {
          "one": safe(metabolism.absorption.zone),
          "two": safe(metabolism.fermentation.zone),
        };
      case "Fat":
        return {
          "one": safe(metabolism.fatMetabolism.zone),
          "two": safe(metabolism.glucoseMetabolism.zone),
        };
      case "Liver":
        return {
          "one": safe(metabolism.hepaticStress.zone),
          "two": safe(metabolism.detoxification.zone),
        };
      default:
        return {"one": '', "two": ''};
    }
  }

  /// 🎨 Color based on zone
  Color _zoneColor(String zone) {
    switch (zone.toLowerCase()) {
      case 'poor':
        return const Color(0xFFEA5455); // red
      case 'fair':
        return const Color(0xFFFFC412); // yellow
      case 'good':
        return const Color(0xFF3EAF58); // green
      default:
        return const Color(0xFF252525); // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final scores = _getScores(result);
    final score1 = scores["one"] ?? 0;
    final score2 = scores["two"] ?? 0;

    final zones = _getZones(result);
    final zone1 = zones["one"] ?? '';
    final zone2 = zones["two"] ?? '';

    final zoneColor1 = _zoneColor(zone1);
    final zoneColor2 = _zoneColor(zone2);

    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(74),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Row(
            children: [
              SvgPicture.asset(
                _metabolismIcon[metabolismType] ?? "",
                height: 24,
                width: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF308BF9),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _metabolismTitle[metabolismType] ?? "",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// Score Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Left (SubTypeOne)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _metabolismSubTypeOne[metabolismType] ?? "",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        height: 1.10,
                        letterSpacing: -0.16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${score1.toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                          ),
                        ),
                        Container(height: 10, width: 1, color: Colors.black),
                        Text(
                          zone1, // 👉 Good / Fair / Poor from API
                          style: GoogleFonts.poppins(
                            color: zoneColor1,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              /// Divider
              Container(height: 40, width: 1, color: Colors.black),
              const SizedBox(width: 10),

              /// Right (SubTypeTwo)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _metabolismSubTypeTwo[metabolismType] ?? "",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        height: 1.10,
                        letterSpacing: -0.16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${score2.toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                          ),
                        ),
                        Container(height: 10, width: 1, color: Colors.black),
                        Text(
                          zone2,
                          style: GoogleFonts.poppins(
                            color: zoneColor2,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
