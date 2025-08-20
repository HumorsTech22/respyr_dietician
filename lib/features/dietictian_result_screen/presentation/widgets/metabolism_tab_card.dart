import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/utils/score_utils.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/presentation/widgets/segment_linebar.dart';

class MetabolismTabCard extends StatelessWidget {
  final String metabolismSubtype;
  const MetabolismTabCard({super.key, required this.metabolismSubtype});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.50,
            color: ScoreColorHelper.getScoreColor(80.0),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metabolismSubtype,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.72,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Shows how well your gut absorbs nutrients. A high score means efficient absorption; a low score may suggest malabsorption or gut issues.',
            style: TextStyle(
              color: const Color(0xFF535359),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.26,
              letterSpacing: -0.24,
            ),
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/images/common/dietitian_share.svg",
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(
                  Color(0xFF308BF9),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 5),
              Text(
                'View trend',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF308BF9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                  letterSpacing: -0.24,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(),
          SizedBox(height: 10),
          Text(
            '25 June 2025, 12:00pm',
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.10,
              letterSpacing: -0.20,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '80%',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.60,
                ),
              ),
              IntrinsicHeight(child: VerticalDivider()),
              Text(
                'Good',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF3EAF58),
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.60,
                ),
              ),
            ],
          ),
          SegmentedScoreBar(score: 80.0),
          SizedBox(height: 10),
          Text(
            'Score Meaning',
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
            'Efficient nutrient absorption',
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.26,
              letterSpacing: -0.24,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Interpretation (Metabolic Insight)',
            style: TextStyle(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: -0.24,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your small intestine is absorbing nutrients well — no excess gas or fermentation.',
            style: TextStyle(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.30,
              letterSpacing: -0.24,
            ),
          ),
        ],
      ),
    );
  }
}
