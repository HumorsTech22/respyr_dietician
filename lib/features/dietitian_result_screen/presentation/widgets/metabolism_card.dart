import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_state.dart';

class MetabolismCard extends StatelessWidget {
  final String metabolismType;
  final DietitianResultState state;

  const MetabolismCard({
    super.key,
    required this.metabolismType,
    required this.state,
  });

  static final Map<String, String> _metabolismIcon = {
    "Gut": "assets/images/result_screen/dietitian_gut_outline.svg",
    "Fat": "assets/images/result_screen/dietitian_pancreas_outline.svg",
    "Liver": "assets/images/result_screen/dietitian_liver_outline.svg",
  };

  static final Map<String, String> _metabolismTitle = {
    "Gut": "Gut Fermentation Metabolism",
    "Fat": "Glucose\n-Vs-\nFat Metabolism",
    "Liver": "Liver Hepatic Metabolism",
  };

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

  Map<String, int> _getScores() {
    final result = state.dietitianResult;
    if (result == null) return {"one": 0, "two": 0};

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

  String _getRating(int score) {
    if (score >= 80) return "Good";
    if (score >= 60) return "Fair";
    if (score >= 40) return "Poor";
    return "Poor";
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case "Good":
        return const Color(0xFF3EAF58);
      case "Fair":
        return const Color(0xFFFFA500);
      case "Poor":
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFFE74C3C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scores = _getScores();
    final score1 = scores["one"] ?? 0;
    final score2 = scores["two"] ?? 0;

    final rating1 = _getRating(score1);
    final rating2 = _getRating(score2);

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
                          rating1,
                          style: GoogleFonts.poppins(
                            color: _getRatingColor(rating1),
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
                          rating2,
                          style: GoogleFonts.poppins(
                            color: _getRatingColor(rating2),
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
