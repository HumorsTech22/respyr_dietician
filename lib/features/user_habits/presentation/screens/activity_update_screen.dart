import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/update_user_habit_request.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';
import 'package:respyr_dietitian/features/user_habits/data/services/update_user_habit_services.dart';

class ActivityUpdateScreen extends StatefulWidget {
  final String initialActivity;
  final ClientProfileModel clientProfileModel;
  final UserHabitsModel userHabitsModel;

  const ActivityUpdateScreen({
    super.key,
    this.initialActivity = 'sedentary',
    required this.clientProfileModel,
    required this.userHabitsModel,
  });

  @override
  State<ActivityUpdateScreen> createState() => _ActivityUpdateScreenState();
}

class _ActivityUpdateScreenState extends State<ActivityUpdateScreen> {
  String _selectedActivityOption = 'Sedentary';
  bool _isLoading = false;

  final List<String> _activityOptions = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  ];

  final List<String> descriptions = [
    'Little to no exercise. Mostly sitting during the day.',
    'Light exercise, or sports 1-3 days/week.',
    'Moderate exercise, or sports 3-5 days/week.',
    'Hard exercise, or sports 6-7 days a week.',
    'Very hard exercise or a physically demanding job.',
  ];

  final Color primaryBlue = const Color(0xFF308BF9);

  @override
  void initState() {
    super.initState();
    _selectedActivityOption = _mapActivityToUi(widget.initialActivity);
  }

  String _mapActivityToUi(String activity) {
    switch (activity.toLowerCase()) {
      case 'sedentary':
        return 'Sedentary';
      case 'light':
        return 'Light';
      case 'moderate':
        return 'Moderate';
      case 'active':
        return 'Active';
      case 'very_active':
        return 'Very Active';
      default:
        return 'Sedentary';
    }
  }

  String _mapUiToActivity(String activity) {
    return activity.toLowerCase().replaceAll(" ", "_");
  }

  String _safeValue(String value, String fallback) {
    if (value.trim().isEmpty || value.trim().toLowerCase() == "not_available") {
      return fallback;
    }
    return value;
  }

  Future<void> _updateActivity() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await UpdateUserHabitsService.updateUserHabits(
        request: UpdateUserHabitsRequest(
          profileId: widget.clientProfileModel.profileId,
          goal: _safeValue(widget.userHabitsModel.goal, "fat_loss"),
          activity: _mapUiToActivity(_selectedActivityOption),
          dietType: _safeValue(
            widget.userHabitsModel.foodType.dietType,
            "no_dietary_preferences",
          ),
          primaryCuisine: _safeValue(
            widget.userHabitsModel.foodType.primaryCuisine,
            "indian",
          ),
          secondaryCuisine: _safeValue(
            widget.userHabitsModel.foodType.secondaryCuisine,
            "indian",
          ),
        ),
      );

      if (!mounted) return;

      if (result.status) {
        Navigator.pop(context, _mapUiToActivity(_selectedActivityOption));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildActivityOption(String title, String description) {
    final bool isSelected = _selectedActivityOption == title;

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
              color: isSelected ? const Color(0xFF308BF9) : const Color(0xFFD9D9D9),
            ),
            borderRadius: BorderRadius.circular(rh(context: context, px: 10)),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: rh(context: context, px: 14),
          horizontal: rh(context: context, px: 20),
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
                      color: const Color(0xFF252525),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: rh(context: context, px: 35)),
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
                    child: ListView.separated(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: ProfileBottomNavigation(
          onBack: () {
            if (_isLoading) return;
            Navigator.pop(context);
          },
          onNext: () async {
            await _updateActivity();
          },
        ),
      ),
    );
  }
}