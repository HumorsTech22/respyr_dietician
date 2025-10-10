import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/log_food/presentation/widgets/nutrients_progess.dart';

class DietLogCalScore extends StatelessWidget {
  const DietLogCalScore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 4,
                        backgroundColor: Color(0xFFF5F7FA),
                        color: Color(0xFF3FAF58),
                      ),
                      Center(
                        child: SvgPicture.asset(
                          "assets/images/common/trophy.svg",
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Daily Goal',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '75% completed',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 0.75,
                            strokeWidth: 6,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.orange,
                          ),
                          Center(
                            child: SvgPicture.asset(
                              "assets/images/common/calories.svg",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calories',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.10,
                            letterSpacing: -0.24,
                          ),
                        ),
                        Text(
                          '1200 kcal',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.26,
                            letterSpacing: -0.40,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.20,
                            ),
                            children: [
                              TextSpan(text: 'out of '),
                              TextSpan(
                                text: '1800kcal',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: NutrientsProgessWidget(
                        name: "Protein",
                        value: "70g",
                        total: "100g",
                        color: Color(0xFFFFC412),
                        progress: 0.70,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: NutrientsProgessWidget(
                        name: "Protein",
                        value: "30g",
                        total: "100g",
                        color: Color(0xFF38A250),
                        progress: 0.30,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: NutrientsProgessWidget(
                        name: "Protein",
                        value: "80g",
                        total: "100g",
                        color: Color(0xFF38A250),
                        progress: 0.80,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: NutrientsProgessWidget(
                        name: "Protein",
                        value: "21g",
                        total: "100g",
                        color: Color(0xFFFFC412),
                        progress: 0.21,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
