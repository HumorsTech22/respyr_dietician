import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bluetooth_device_connectivity/presentation/widgets/new_start_test_counter_screen.dart';

class TestPoornesh extends StatefulWidget {
  const TestPoornesh({super.key});

  @override
  State<TestPoornesh> createState() => _TestPoorneshState();
}

class _TestPoorneshState extends State<TestPoornesh> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        title: Text(
          "Help Center",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 15),
            fontWeight: FontWeight.w400,
            letterSpacing: rh(context: context, px: -0.30),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: rh(context: context, px: 11)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FAQ",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 34),
                      fontWeight: FontWeight.w400,
                      letterSpacing: rh(context: context, px: -2.84),
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 28)),
                  Text(
                    "Here are some frequently asked question with solutions",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w400,
                      letterSpacing: rh(context: context, px: -0.30),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: rh(context: context, px: 18)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: rh(context: context, px: 10),
                children: [
                  Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 5),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: rh(context: context, px: 9),
                        vertical: rh(context: context, px: 26),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "1. Device not connecting issue?",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: rh(context: context, px: 15),
                                fontWeight: FontWeight.w600,
                                letterSpacing: rh(context: context, px: -0.30),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.add,
                            color: const Color(0xFF308BF9),
                            size: rh(context: context, px: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 5),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: rh(context: context, px: 9),
                        vertical: rh(context: context, px: 26),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "2. How to add new profile?",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: rh(context: context, px: 15),
                                fontWeight: FontWeight.w600,
                                letterSpacing: rh(context: context, px: -0.30),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.add,
                            color: const Color(0xFF308BF9),
                            size: rh(context: context, px: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 5),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: rh(context: context, px: 9),
                        vertical: rh(context: context, px: 26),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "3. how switch from one profile to another?",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: rh(context: context, px: 15),
                                fontWeight: FontWeight.w600,
                                letterSpacing: rh(context: context, px: -0.30),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.add,
                            color: const Color(0xFF308BF9),
                            size: rh(context: context, px: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  SizedBox(height: rh(context: context, px: 19)),
                  SizedBox(
                    width: rh(context: context, px: 250),
                    child: Text(
                      'Didn’t find what you’re looking for?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 12),
                        fontWeight: FontWeight.w400,
                        height: 1.40,
                        letterSpacing: rh(context: context, px: -0.24),
                      ),
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 16)),
                  Container(
                    width: rh(context: context, px: 349),
                    height: rh(context: context, px: 61),
                    padding: EdgeInsets.symmetric(
                      horizontal: rh(context: context, px: 20),
                      vertical: rh(context: context, px: 10),
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF252525),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 50),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: rh(context: context, px: 10),
                      children: [
                        Text(
                          'Contact Support',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: rh(context: context, px: 15),
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: rh(context: context, px: 0.30),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 15)),
                  Container(
                    width: rh(context: context, px: 173),
                    padding: EdgeInsets.only(
                      top: rh(context: context, px: 9),
                      left: rh(context: context, px: 20),
                      right: rh(context: context, px: 14),
                      bottom: rh(context: context, px: 9),
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: rh(context: context, px: 1),
                          color: const Color(0xFFC7C6CE),
                        ),
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 25.50),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: rh(context: context, px: 10),
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: rh(context: context, px: 18),
                          children: [
                            Text(
                              'Report an issue',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: rh(context: context, px: 12),
                                fontWeight: FontWeight.w600,
                                height: 1.10,
                                letterSpacing: rh(context: context, px: -0.24),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 19)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}