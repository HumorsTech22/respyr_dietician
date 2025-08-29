import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/presentation/widgets/metabolism_tab_card.dart';

class SectionWidget extends StatelessWidget {
  final GlobalKey sectionKey;
  final String sectionType;

  const SectionWidget({
    super.key,
    required this.sectionKey,
    required this.sectionType,
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
    final subTypes = _metabolismSubTypes[sectionType] ?? [];
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
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Main Marker: Acetone',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                          letterSpacing: -0.24,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '1.03 ppm',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.40,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),
                for (final subtype in subTypes) ...[
                  MetabolismTabCard(metabolismSubtype: subtype),
                ],
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: Colors.white,
              child: Row(
                children: [
                  SvgPicture.asset(
                    _sectionHeaderIcon[sectionType] ?? '',
                    width: 15,
                    height: 15,
                    colorFilter: ColorFilter.mode(
                      Color(0xFF308BF9),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    _metabolismTitle[sectionType] ?? "",
                    style: GoogleFonts.poppins(
                      color: Color(0xFF252525),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.10,
                      letterSpacing: -0.24,
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
