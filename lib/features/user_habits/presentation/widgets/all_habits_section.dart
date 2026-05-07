// lib/features/user_habits/presentation/widgets/all_habits_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/user_habits/presentation/widgets/grid_list_button.dart';

import '../../../../core/size/get_height.dart';
import '../bloc/habit_tracking_bloc.dart';
import 'insight_grid_card.dart';

/// 3 display modes for the habits section
enum HabitViewMode {
  weeklyGrid,    // 2-col grid, weekly 7 dots
  weeklyList,    // full-width rows, weekly 7 dots
  totalList,     // full-width rows, all-time dots
}

class AllHabitsSection extends StatefulWidget {
  final String profileId;

  const AllHabitsSection({super.key, required this.profileId});

  @override
  State<AllHabitsSection> createState() => _AllHabitsSectionState();
}

class _AllHabitsSectionState extends State<AllHabitsSection> {
  HabitViewMode _viewMode = HabitViewMode.weeklyGrid;

  /// Cycle: grid → list → total → grid
  void _toggleView() {
    setState(() {
      switch (_viewMode) {
        case HabitViewMode.weeklyGrid:
          _viewMode = HabitViewMode.weeklyList;
          break;
        case HabitViewMode.weeklyList:
          _viewMode = HabitViewMode.totalList;
          break;
        case HabitViewMode.totalList:
          _viewMode = HabitViewMode.weeklyGrid;
          break;
      }
    });
  }

  /// Icon shown in the toggle button — represents the CURRENT mode
  String get _toggleIcon {
    switch (_viewMode) {
      case HabitViewMode.weeklyGrid:
        return 'assets/images/icons/grid_icon.svg';
      case HabitViewMode.weeklyList:
        return 'assets/images/icons/ic_list.svg';
      case HabitViewMode.totalList:
        return 'assets/images/icons/ic_total_list.svg';
    }
  }

  Future<void> _onRefresh() async {
    context.read<HabitTrackingBloc>().add(
      RefreshWeeklyHabits(profileId: widget.profileId),
    );
    await context.read<HabitTrackingBloc>().stream.firstWhere(
          (s) => !s.isLoading && !s.isRefreshing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = rh(context: context, px: 15);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "All Habits",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 25),
                  fontWeight: FontWeight.w600,
                  letterSpacing: rh(context: context, px: -1),
                ),
              ),
              GridListButton(
                onTap: _toggleView,
                iconPath: _toggleIcon,
              ),
            ],
          ),
          SizedBox(height: rh(context: context, px: 29.5)),

          // Content
          BlocBuilder<HabitTrackingBloc, HabitTrackingState>(
            builder: (context, state) {
              if (state.isLoading && !state.hasData) {
                return _buildLoading(context);
              }

              if (state.isFailure && !state.hasData) {
                return _buildError(context, state);
              }

              if (state.isEmpty) {
                return _buildEmpty(context);
              }

              if (state.hasData) {
                final habits = state.habits;
                switch (_viewMode) {
                  case HabitViewMode.weeklyGrid:
                    return _buildGridView(context, spacing, habits);
                  case HabitViewMode.weeklyList:
                    return _buildListView(
                      context,
                      spacing,
                      habits,
                      mode: HabitCardMode.weeklyList,
                    );
                  case HabitViewMode.totalList:
                    return _buildListView(
                      context,
                      spacing,
                      habits,
                      mode: HabitCardMode.totalList,
                    );
                }
              }

              return _buildLoading(context);
            },
          ),

          SizedBox(height: rh(context: context, px: 40)),
          SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
        ],
      ),
    );
  }

  // ---------------- Views ----------------

  Widget _buildGridView(BuildContext context, double spacing, List habits) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: habits.asMap().entries.map((entry) {
            final i = entry.key;
            final habit = entry.value;
            return SizedBox(
              width: cardWidth,
              child: InsightGridCard(
                habit: habit,
                index: i + 1,
                mode: HabitCardMode.weeklyGrid,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildListView(
      BuildContext context,
      double spacing,
      List habits, {
        required HabitCardMode mode,
      }) {
    return Column(
      children: List.generate(habits.length, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == habits.length - 1 ? 0 : spacing,
          ),
          child: InsightGridCard(
            habit: habits[index],
            index: index + 1,
            mode: mode,
          ),
        );
      }),
    );
  }

  // ---------------- Placeholders ----------------

  Widget _buildLoading(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 60)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 60)),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: rh(context: context, px: 50), color: Colors.grey),
          SizedBox(height: rh(context: context, px: 12)),
          Text(
            "No habits selected yet",
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, HabitTrackingState state) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: rh(context: context, px: 40),
        horizontal: rh(context: context, px: 12),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline,
              size: rh(context: context, px: 48), color: Colors.redAccent),
          SizedBox(height: rh(context: context, px: 12)),
          Text(
            state.errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 13),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: rh(context: context, px: 16)),
          ElevatedButton(
            onPressed: () {
              context.read<HabitTrackingBloc>().add(
                RetryLoadWeeklyHabits(profileId: widget.profileId),
              );
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}