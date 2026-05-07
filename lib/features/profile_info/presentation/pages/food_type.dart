import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/food_preference.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/cuisine_sheet.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';

import '../../../../routes/app_routes.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_progress_bar.dart';

class FoodType extends StatefulWidget {
  final int stepCompleted;

  const FoodType({
    super.key,
    required this.stepCompleted,
  });

  @override
  State<FoodType> createState() => _FoodTypeScreenState();
}

class _FoodTypeScreenState extends State<FoodType> {
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

  final List<String> cuisines = [
    "Indian",
    "American",
  ];

  late String primaryCuisine;
  late String secondaryCuisine;
  late String _selectedDiet;

  final Color primaryBlue = const Color(0xFF308BF9);

  @override
  void initState() {
    super.initState();

    primaryCuisine = "American";
    secondaryCuisine = "American";
    _selectedDiet = _dietOptions[0];
  }

  String get _selectedDietBackendValue {
    return _dietBackendValues[_selectedDiet] ?? 'veg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileProgressBar(stepCompleted: widget.stepCompleted + 1),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rh(context: context, px: 24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us your food preferences',
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
                            SizedBox(height: rh(context: context, px: 62.5)),

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
      bottomNavigationBar: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return ProfileBottomNavigation(
              onBack: () {
                context.pop();
              },
              onNext: () {
                FocusScope.of(context).unfocus();

                final foodPreference = FoodPreference(
                  dietType: _selectedDietBackendValue,
                  primaryCuisine: primaryCuisine.toLowerCase(),
                  secondaryCuisine: secondaryCuisine.toLowerCase(),
                );

                context.push(
                  AppRoutes.activityLevelScreen,
                  extra: {
                    'stepCompleted': widget.stepCompleted + 1,
                    'food': jsonEncode(foodPreference.toJson()),
                    'diet_type': _selectedDietBackendValue,
                    'primary_cuisine': primaryCuisine.toLowerCase(),
                    'secondary_cuisine': secondaryCuisine.toLowerCase(),
                  },
                );
              },
            );
          },
        ),
      ),
    );
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
}