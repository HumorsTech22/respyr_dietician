import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MetabolismCard extends StatelessWidget {
  final String metabolismType;
  const MetabolismCard({super.key, required this.metabolismType});

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

  @override
  Widget build(BuildContext context) {
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
                colorFilter: ColorFilter.mode(
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
              /// Absorptive Metabolism Score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _metabolismSubTypeOne[metabolismType] ?? "",
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
                          '97%',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: -0.24,
                          ),
                        ),
                        Container(height: 10, width: 1, color: Colors.black),

                        Text(
                          'Good',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF3EAF58),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: -0.24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),

              /// Proper Divider
              Container(height: 40, width: 1, color: Colors.black),
              SizedBox(width: 10),

              /// Fermentative Metabolism Score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _metabolismSubTypeTwo[metabolismType] ?? "",
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
                          '7%',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: -0.24,
                          ),
                        ),
                        Container(height: 10, width: 1, color: Colors.black),
                        Text(
                          'Good',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF3EAF58),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: -0.24,
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
