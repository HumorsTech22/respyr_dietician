import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/coach_sign_in/data/model/dietitian_data_model.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';

import '../../../../routes/app_routes.dart';
import '../widgets/profile_progress_bar.dart';

class ActivityScreen extends StatefulWidget {
  final int stepCompleted;
  final String foodType;
  const ActivityScreen({super.key, required this.stepCompleted, required this.foodType});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  // State for selected activity option
  String _selectedActivityOption = 'Sedentary';

  // List of activity options based on the UI
  final List<String> _activityOptions = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  ];

  // Descriptions corresponding to each activity level
  final List<String> descriptions = [
    'Little to no exercise. Mostly sitting during the day.',
    'Light exercise, or sports 1-3 days/week.',
    'Moderate exercise, or sports 3-5 days/week.',
    'Hard exercise, or sports 6-7 days a week.',
    'Very hard exercise or a physically demanding job.',
  ];

  final Color primaryBlue = const Color(0xFF308BF9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            ProfileProgressBar(stepCompleted: widget.stepCompleted + 1),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is your activity level?',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 34),
                        fontWeight: FontWeight.w400,
                        letterSpacing: -2.04,
                      ),
                    ),
                    SizedBox(height: rh(context: context, px: 35)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // List of activity options
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _activityOptions.length,
                              itemBuilder: (context, index) {
                                return _buildActivityOption(
                                  _activityOptions[index],
                                  descriptions[index],
                                );
                              },
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: rh(context: context, px: 10),);
                                }
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ProfileBottomNavigation(
          onBack: () {
            context.pop();
          },
          onNext: () {
            context.push(
              AppRoutes.goalScreen,
              extra: {
                'stepCompleted': widget.stepCompleted + 1,
                'food': widget.foodType,
                'activity': _selectedActivityOption.toLowerCase().replaceAll(" ", "_"),
              },
            );
          },
        ),
      ),
    );
  }

  // Custom widget for the activity option selection
  Widget _buildActivityOption(String title, String description) {
    bool isSelected = _selectedActivityOption == title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedActivityOption = title;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              strokeAlign: BorderSide.strokeAlignCenter,
              color:  isSelected ? const Color(0xFF308BF9) :  Color(0xFFD9D9D9),
            ),
            borderRadius: BorderRadius.circular(rh(context: context, px: 10)),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 14), horizontal: rh(context: context, px: 20)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color:  const Color(0xFF252525),
                      fontSize: rh(context: context, px: 13),
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                      letterSpacing: -0.30,
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 10)),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: rh(context: context, px: 12),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.24,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: rh(context: context, px: 24),
              height: rh(context: context, px: 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryBlue : const Color(0xFF252525),
                  width: rh(context: context, px: 1.0),
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: rh(context: context, px: 18),
                  height: rh(context: context, px: 18),
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.50, -0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [Color(0xFF308BF9), Color(0xFF8EC1FF)],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}