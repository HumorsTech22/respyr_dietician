import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';


class GoalScreen extends StatefulWidget {
  final int stepCompleted;
  final String foodType;
  final String activityLevel;
  const GoalScreen({super.key, required this.stepCompleted, required this.foodType, required this.activityLevel});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  // State for selected activity option
  String _selectedActivityOption = 'Fat Loss';

  // List of activity options based on the UI
  final List<String> _activityOptions = [
    'Fat Loss',
    // 'Weight Gain',
    'Muscle Gain'
  ];

  // Descriptions corresponding to each activity level
  final List<String> descriptions = [
    'Support healthy fat reduction through better metabolism.',
    // 'Support healthy weight gain through improved nutrition and metabolism.',
    'Support muscle growth through enhanced nutrition and training.'
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
                      'What would you like to improve?',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 34),
                        fontWeight: FontWeight.w400,
                        letterSpacing: -2.04,
                      ),
                    ),
                    SizedBox(height: rh(context: context, px: 35)),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // List of activity options
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _activityOptions.length,
                            itemBuilder: (context, index) {
                              return _buildActivityOption(
                                _activityOptions[index],
                                descriptions[index],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(height: rh(context: context, px: 10));
                            },
                          )
                        ],
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
              AppRoutes.profileWelcomeScreen,
              extra: {
                'stepCompleted': widget.stepCompleted + 1,
                'goal': _selectedActivityOption.toLowerCase().replaceAll(" ", "_"),
                'activity': widget.activityLevel,
                'food': widget.foodType,
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

    String getSvgAsset(String title) {
      switch (title) {
        case 'Fat Loss':
          return "assets/images/icons/ic_weight_loss.svg";
        case 'Weight Gain':
          return "assets/images/icons/ic_weight_gain.svg";
        case 'Muscle Gain':
          return "assets/images/icons/ic_muscle_gain.svg";
        default:
          return "assets/images/icons/ic_weight_loss.svg";
      }
    }

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
              color: isSelected ? primaryBlue : const Color(0xFFD9D9D9),
            ),
            borderRadius: BorderRadius.circular(rh(context: context, px: 10)),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 14), horizontal: rh(context: context, px: 20)),
        child: Row(
          children: [
            SvgPicture.asset(
              getSvgAsset(title),
              width: rh(context: context, px: 30),
              height: rh(context: context, px: 30),
            ),
            SizedBox(width: rh(context: context, px: 20)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: isSelected ? primaryBlue : const Color(0xFF252525),
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}