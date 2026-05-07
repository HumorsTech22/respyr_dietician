import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/cuisine_sheet.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/update_user_habit_request.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';
import 'package:respyr_dietitian/features/user_habits/data/services/update_user_habit_services.dart';

class FoodPreferenceUpdateScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final UserHabitsModel userHabitsModel;

  const FoodPreferenceUpdateScreen({
    super.key,
    required this.clientProfileModel,
    required this.userHabitsModel,
  });

  @override
  State<FoodPreferenceUpdateScreen> createState() =>
      _FoodPreferenceUpdateScreenState();
}

class _FoodPreferenceUpdateScreenState
    extends State<FoodPreferenceUpdateScreen> {
  final List<String> _dietOptions = [
    'Vegetarian',
    'Vegan',
    'Eggitarian',
    'Non-vegetarian',
  ];

  final Map<String, String> _dietBackendValues = {
    'Vegetarian': 'veg',
    'Vegan': 'vegan',
    'Eggitarian': 'eggitarian',
    'Non-vegetarian': 'nonveg',
  };

  final Map<String, String> _backendToUiDietValues = {
    'veg': 'Vegetarian',
    'vegan': 'Vegan',
    'eggitarian': 'Eggitarian',
    'nonveg': 'Non-vegetarian',
    'only_vegetarian': 'Vegetarian',
    'non_vegetarian': 'Non-vegetarian',
    'non-vegetarian': 'Non-vegetarian',
  };

  final List<String> cuisines = [
    "Indian",
    "American",
  ];

  late String primaryCuisine;
  late String secondaryCuisine;
  late String _selectedDiet;

  bool _isLoading = false;

  final Color primaryBlue = const Color(0xFF308BF9);

  @override
  void initState() {
    super.initState();

    _selectedDiet = _mapDietTypeToUi(widget.userHabitsModel.foodType.dietType);

    primaryCuisine = _mapCuisineToUi(
      widget.userHabitsModel.foodType.primaryCuisine,
      fallback: "American",
    );

    secondaryCuisine = _mapCuisineToUi(
      widget.userHabitsModel.foodType.secondaryCuisine,
      fallback: "American",
    );
  }

  String _mapDietTypeToUi(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty || normalized == "not_available") {
      return 'Vegetarian';
    }

    return _backendToUiDietValues[normalized] ?? 'Vegetarian';
  }

  String _dietTypeForApi(String value) {
    return _dietBackendValues[value] ?? 'veg';
  }

  String _mapCuisineToUi(String value, {required String fallback}) {
    if (value.trim().isEmpty || value.trim().toLowerCase() == "not_available") {
      return fallback;
    }

    final normalized = value.trim().toLowerCase();

    for (final cuisine in cuisines) {
      if (cuisine.toLowerCase() == normalized) {
        return cuisine;
      }
    }

    return fallback;
  }

  String _safeValue(String value, String fallback) {
    if (value.trim().isEmpty || value.trim().toLowerCase() == "not_available") {
      return fallback;
    }
    return value;
  }

  Future<void> _updateFoodPreferences() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dietTypeForApi = _dietTypeForApi(_selectedDiet);

      final result = await UpdateUserHabitsService.updateUserHabits(
        request: UpdateUserHabitsRequest(
          profileId: widget.clientProfileModel.profileId,
          goal: _safeValue(widget.userHabitsModel.goal, "fat_loss"),
          activity: _safeValue(widget.userHabitsModel.activity, "sedentary"),
          dietType: dietTypeForApi,
          primaryCuisine: primaryCuisine.toLowerCase(),
          secondaryCuisine: secondaryCuisine.toLowerCase(),
        ),
      );

      if (!mounted) return;

      if (result.status) {
        Navigator.pop(
          context,
          FoodTypeModel(
            dietType: dietTypeForApi,
            primaryCuisine: primaryCuisine.toLowerCase(),
            secondaryCuisine: secondaryCuisine.toLowerCase(),
          ),
        );
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

  Widget _buildCuisineTile(String title, String value) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                  letterSpacing: -0.30,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_outlined),
            ],
          ),
          SizedBox(height: rh(context: context, px: 10)),
          Container(
            decoration: ShapeDecoration(
              color: const Color(0xFFEBF4FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            padding: EdgeInsets.symmetric(
              vertical: rh(context: context, px: 8),
              horizontal: rh(context: context, px: 10),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: const Color(0xFF308BF9),
                fontSize: rh(context: context, px: 10),
                fontWeight: FontWeight.w600,
                height: 1.26,
                letterSpacing: -0.20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietOption(String title) {
    final bool isSelected = _selectedDiet == title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDiet = title;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: rh(context: context, px: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected ? primaryBlue : const Color(0xFF252525),
                fontSize: rh(context: context, px: 13),
                fontWeight: FontWeight.w400,
                height: 1.30,
                letterSpacing: -0.30,
              ),
            ),
            Container(
              width: rh(context: context, px: 24),
              height: rh(context: context, px: 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryBlue : Colors.black87,
                  width: rh(context: context, px: 1),
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: rh(context: context, px: 18),
                  height: rh(context: context, px: 18),
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF308BF9),
                        Color(0xFF8EC1FF),
                      ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  title: Text(
                    "Update food preferences",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.30,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rh(context: context, px: 24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: rh(context: context, px: 35)),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose dietary preferences',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: rh(context: context, px: 13),
                                    fontWeight: FontWeight.w600,
                                    height: 1.10,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                SizedBox(height: rh(context: context, px: 18)),
                                ..._dietOptions.map(
                                      (option) => _buildDietOption(option),
                                ),
                                SizedBox(
                                  height: rh(context: context, px: 62.5),
                                ),
                                InkWell(
                                  onTap: () async {
                                    final selectedCuisine =
                                    await CuisineSheet.show(
                                      context: context,
                                      cuisines: cuisines,
                                    );

                                    if (selectedCuisine != null) {
                                      setState(() {
                                        primaryCuisine = selectedCuisine;
                                      });
                                    }
                                  },
                                  child: _buildCuisineTile(
                                    "Select Primary Cuisine",
                                    primaryCuisine,
                                  ),
                                ),
                                SizedBox(height: rh(context: context, px: 20)),
                                InkWell(
                                  onTap: () async {
                                    final selectedCuisine =
                                    await CuisineSheet.show(
                                      context: context,
                                      cuisines: cuisines,
                                    );

                                    if (selectedCuisine != null) {
                                      setState(() {
                                        secondaryCuisine = selectedCuisine;
                                      });
                                    }
                                  },
                                  child: _buildCuisineTile(
                                    "Select Secondary Cuisine",
                                    secondaryCuisine,
                                  ),
                                ),
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
            await _updateFoodPreferences();
          },
        ),
      ),
    );
  }
}