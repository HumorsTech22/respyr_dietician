import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class SelectHabitLevelScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const SelectHabitLevelScreen({
    super.key,
    required this.clientProfileModel,
  });

  @override
  State<SelectHabitLevelScreen> createState() => _SelectHabitLevelScreenState();
}

class _SelectHabitLevelScreenState extends State<SelectHabitLevelScreen> {
  int selectedLevelId = 1;

  final List<Map<String, dynamic>> levels = [
    {
      "id": 1,
      "title": "Level - 1",
      "subtitle": "Easy Start",
    },
    {
      "id": 2,
      "title": "Level - 2",
      "subtitle": "Steady Growth",
    },
    {
      "id": 3,
      "title": "Level - 3",
      "subtitle": "Strong Discipline",
    },
  ];

  void _goNext() {
    context.push(
      AppRoutes.habitMasterScreen,
      extra: {
        'client': widget.clientProfileModel,
        'levelId': selectedLevelId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: ProfileBottomNavigation(
          onBack: () {
            context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
          },
          onNext: _goNext,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: rh(context: context, px: 24)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 17),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose Your Starting Level",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 34),
                      fontWeight: FontWeight.w400,
                      letterSpacing: rh(context: context, px: -2.04),
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 12)),
                  Text(
                    "Find the right pace for your habit journey",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      letterSpacing: rh(context: context, px: -0.30),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: rh(context: context, px: 40)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rh(context: context, px: 20),
                ),
                child: Column(
                  children: [
                    for (final level in levels) ...[
                      _levelCard(
                        context: context,
                        levelId: level["id"],
                        title: level["title"],
                        subtitle: level["subtitle"],
                      ),
                      SizedBox(height: rh(context: context, px: 20)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelCard({
    required BuildContext context,
    required int levelId,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = selectedLevelId == levelId;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevelId = levelId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: EdgeInsets.only(
          left: rh(context: context, px: 40),
          top: rh(context: context, px: 30),
          bottom: rh(context: context, px: 30),
          right: rh(context: context, px: 40),
        ),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: rh(context: context, px: 2),
              strokeAlign: BorderSide.strokeAlignCenter,
              color: isSelected
                  ? const Color(0xFF308BF9)
                  : const Color(0xFFE1E6ED),
            ),
            borderRadius: BorderRadius.circular(
              rh(context: context, px: 5),
            ),
          ),
          shadows: isSelected
              ? [
            BoxShadow(
              color: const Color(0x3F308BF9),
              blurRadius: rh(context: context, px: 7.20),
              offset: Offset(
                rh(context: context, px: 0),
                rh(context: context, px: 0),
              ),
              spreadRadius: rh(context: context, px: 0),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                      letterSpacing: rh(context: context, px: -0.30),
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 15)),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w400,
                      letterSpacing: rh(context: context, px: -0.30),
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              size: rh(context: context, px: 24),
              color: isSelected
                  ? const Color(0xFF308BF9)
                  : const Color(0xFF535359),
            ),
          ],
        ),
      ),
    );
  }
}