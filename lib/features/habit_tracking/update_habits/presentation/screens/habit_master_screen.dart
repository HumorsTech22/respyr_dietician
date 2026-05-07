import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/common/dialogs/floating_message.dart';

import 'package:respyr_dietitian/features/habit_tracking/update_habits/bloc/habit_master_cubit.dart';
import 'package:respyr_dietitian/features/habit_tracking/update_habits/bloc/habit_master_state.dart';
import 'package:respyr_dietitian/features/habit_tracking/update_habits/data/model/habit_master_model.dart';
import 'package:respyr_dietitian/features/habit_tracking/update_habits/data/services/save_selected_habits_service.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../../core/size/get_height.dart';

class SelectHabitsScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final int levelId;
  const SelectHabitsScreen({super.key, required this.clientProfileModel, required this.levelId});

  @override
  State<SelectHabitsScreen> createState() => _SelectHabitsScreenState();
}

class _SelectHabitsScreenState extends State<SelectHabitsScreen> {
  final Set<int> selectedHabitIds = {};
  final Map<String, bool> expandedCategories = {};
  


  void _toggleHabit(HabitMasterData habit) {
    setState(() {
      if (selectedHabitIds.contains(habit.id)) {
        selectedHabitIds.remove(habit.id);
      } else {
        if (selectedHabitIds.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You can select only 5 habits"),
            ),
          );
          return;
        }

        selectedHabitIds.add(habit.id);
      }
    });
  }


  Future<void> _continue() async {
    if (selectedHabitIds.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select exactly 5 habits"),
        ),
      );
      return;
    }

    final habitIds = selectedHabitIds.toList();

    try {
      final success = await SaveSelectedHabitsService.saveSelectedHabits(
        profileId: widget.clientProfileModel.profileId, // replace with dynamic profile id
        habitIds: habitIds, levelId: widget.levelId,
      );

      if (!mounted) return;

      if (success) {

        FloatingMessage.show(context, message: "Your habits has been saved");


        context.pushReplacement(
          AppRoutes.clientDashboard, extra: widget.clientProfileModel
        );

        // TODO: navigate next screen
      }
    } catch (e) {
      if (!mounted) return;
      FloatingMessage.show(context, message: "Something went wrong try again", type: FloatingMessageType.error);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            rh(context: context, px: 20),
          ),
          child: SizedBox(
            height: rh(context: context, px: 54),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedHabitIds.length == 5 ? _continue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F8DFF),
                disabledBackgroundColor: const Color(0xFFE1E6ED),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    rh(context: context, px: 28),
                  ),
                ),
              ),
              child: Text(
                selectedHabitIds.length == 5
                    ? "Continue"
                    : "Select ${5 - selectedHabitIds.length} more",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: rh(context: context, px: 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: BlocBuilder<HabitMasterCubit, HabitMasterState>(
          builder: (context, state) {
            if (state is HabitMasterLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is HabitMasterError) {

              print(state.message);

              return Center(
                child: Padding(
                  padding: EdgeInsets.all(
                    rh(context: context, px: 20),
                  ),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: rh(context: context, px: 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }

            if (state is HabitMasterLoaded) {
              final categories = state.response.data;

              return SingleChildScrollView(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: rh(context: context, px: 24),
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(
                        horizontal: rh(context: context, px: 17)
                      ),
                      child: Text(
                        "Which habits would\nyou like to track?",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 34),
                          fontWeight: FontWeight.w400,
                          letterSpacing: -2.04,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: rh(context: context, px: 35),
                    ),

                    ...categories.entries.map((entry) {
                      final categoryName = entry.key;
                      final habits = entry.value;

                      final isExpanded =
                          expandedCategories[categoryName] ?? false;

                      final visibleHabits =
                      isExpanded ? habits : habits.take(6).toList();

                      return _HabitCategorySection(
                        categoryName: categoryName,
                        habits: visibleHabits,
                        totalHabits: habits.length,
                        isExpanded: isExpanded,
                        selectedHabitIds: selectedHabitIds,
                        onHabitTap: _toggleHabit,
                        onViewMoreTap: () {
                          setState(() {
                            expandedCategories[categoryName] =
                            !isExpanded;
                          });
                        },
                      );
                    }),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _HabitCategorySection extends StatelessWidget {
  final String categoryName;
  final List<HabitMasterData> habits;
  final int totalHabits;
  final bool isExpanded;
  final Set<int> selectedHabitIds;
  final void Function(HabitMasterData habit) onHabitTap;
  final VoidCallback onViewMoreTap;

  const _HabitCategorySection({
    required this.categoryName,
    required this.habits,
    required this.totalHabits,
    required this.isExpanded,
    required this.selectedHabitIds,
    required this.onHabitTap,
    required this.onViewMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: rh(context: context, px: 42),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 20)
            ),
            child: Text(
              categoryName,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: -0.30,
              ),
            ),
          ),

          SizedBox(
            height: rh(context: context, px: 17),
          ),

          Padding(
            padding:  EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 15)
            ),
            child: Wrap(
              spacing: rh(context: context, px: 9),
              runSpacing: rh(context: context, px: 12),
              children: habits.map((habit) {
                final isSelected =
                selectedHabitIds.contains(habit.id);

                return _HabitChoiceChip(
                  title: habit.habitName,
                  isSelected: isSelected,
                  onTap: () => onHabitTap(habit),
                );
              }).toList(),
            ),
          ),

          if (totalHabits > 6) ...[

            Padding(
              padding:  EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 26)
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: rh(context: context, px: 10),
                  ),
                  GestureDetector(
                    onTap: onViewMoreTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded
                              ? "View Less"
                              : "View More",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF308BF9),
                            fontSize:
                            rh(context: context, px: 12),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.24,
                            height: 1,
                          ),
                        ),
                        SizedBox(
                          width: rh(context: context, px: 10),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF2F8DFF),
                          size: rh(context: context, px: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HabitChoiceChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _HabitChoiceChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          rh(context: context, px: 2500),
        ),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 11),
            vertical: rh(context: context, px: 8),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF308BF9)
                : Colors.white,
            borderRadius: BorderRadius.circular(
              rh(context: context, px: 28),
            ),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF308BF9)
                  : const Color(0xFFE1E6ED),
              width: rh(context: context, px: 1.4),
            ),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF535359),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w400,
              letterSpacing: -0.24,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}