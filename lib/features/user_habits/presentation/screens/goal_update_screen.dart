import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/update_user_habit_request.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';
import 'package:respyr_dietitian/features/user_habits/data/services/update_user_habit_services.dart';

class GoalUpdateScreen extends StatefulWidget {
  final String initialGoal;
  final ClientProfileModel clientProfileModel;
  final UserHabitsModel userHabitsModel;

  const GoalUpdateScreen({
    super.key,
    this.initialGoal = 'fat_loss',
    required this.clientProfileModel,
    required this.userHabitsModel,
  });

  @override
  State<GoalUpdateScreen> createState() => _GoalUpdateScreenState();
}

class _GoalUpdateScreenState extends State<GoalUpdateScreen> {
  final Color primaryBlue = const Color(0xFF308BF9);

  late String _selectedGoalOption;
  bool _isLoading = false;

  final List<String> _goalOptions = [
    'Fat Loss',
    'Muscle Gain',
  ];

  final List<String> descriptions = [
    'Support healthy fat reduction through better metabolism.',
    'Support muscle growth through enhanced nutrition and training.'
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoalOption = _mapGoalToUi(widget.initialGoal);
  }

  String _mapGoalToUi(String goal) {
    switch (goal.toLowerCase()) {
      case 'fat_loss':
        return 'Fat Loss';
      case 'muscle_gain':
        return 'Muscle Gain';
      default:
        return 'Fat Loss';
    }
  }

  String _mapUiToGoal(String goal) {
    return goal.toLowerCase().replaceAll(" ", "_");
  }

  String _safeValue(String value, String fallback) {
    if (value.trim().isEmpty || value.trim().toLowerCase() == "not_available") {
      return fallback;
    }
    return value;
  }

  Future<void> _updateGoal() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await UpdateUserHabitsService.updateUserHabits(
        request: UpdateUserHabitsRequest(
          profileId: widget.clientProfileModel.profileId,
          goal: _mapUiToGoal(_selectedGoalOption),
          activity: _safeValue(widget.userHabitsModel.activity, "none"),
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
        Navigator.pop(context, _mapUiToGoal(_selectedGoalOption));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: rh(context: context, px: 35)),
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
                  Expanded(
                    child: ListView.separated(
                      itemCount: _goalOptions.length,
                      itemBuilder: (context, index) {
                        return _buildGoalOption(
                          _goalOptions[index],
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
            await _updateGoal();
          },
        ),
      ),
    );
  }

  Widget _buildGoalOption(String title, String description) {
    final bool isSelected = _selectedGoalOption == title;

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
          _selectedGoalOption = title;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: rh(context: context, px: 14),
          horizontal: rh(context: context, px: 20),
        ),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected ? primaryBlue : const Color(0xFFD9D9D9),
            ),
            borderRadius: BorderRadius.circular(
              rh(context: context, px: 10),
            ),
          ),
        ),
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