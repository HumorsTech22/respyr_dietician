import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/weekly_habit_tracking_model.dart';
import 'package:respyr_dietitian/features/user_habits/data/repositories/habit_tracking_repository.dart';
import 'package:respyr_dietitian/features/user_habits/presentation/bloc/habit_tracking_bloc.dart';
import 'package:respyr_dietitian/features/user_habits/presentation/widgets/all_habits_section.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import '../widgets/habit_menu_button.dart';

class UserHabitsAnalysis extends StatelessWidget {
  final ClientProfileModel clientProfileModel;

  const UserHabitsAnalysis({
    super.key,
    required this.clientProfileModel,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch profileId from your model — adjust field name if different
    final profileId = clientProfileModel.profileId ?? '';

    return BlocProvider(
      create: (_) => HabitTrackingBloc(
        repository: HabitTrackingRepository(
          baseUrl: 'https://humorstech.com/your-api-folder', // <-- update
        ),
      )..add(LoadWeeklyHabits(profileId: profileId)),
      child: _UserHabitsAnalysisView(
        clientProfileModel: clientProfileModel,
        profileId: profileId,
      ),
    );
  }
}

class _UserHabitsAnalysisView extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final String profileId;

  const _UserHabitsAnalysisView({
    required this.clientProfileModel,
    required this.profileId,
  });

  @override
  State<_UserHabitsAnalysisView> createState() =>
      _UserHabitsAnalysisViewState();
}

class _UserHabitsAnalysisViewState extends State<_UserHabitsAnalysisView> {
  late final SheetController _sheetController;

  static const double _minSheetPeekPx = 200;

  @override
  void initState() {
    super.initState();
    _sheetController = SheetController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultSheetController(
      child: Scaffold(
        backgroundColor: const Color(0xFFE9D9FF),
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: const Color(0xFFE9D8FF),
          surfaceTintColor: const Color(0xFFE9D8FF),
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.50, -0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [
                        Color(0xFFE9D8FF),
                        Colors.white,
                        Color(0xFFE9D9FF),
                      ],
                    ),
                  ),
                  child: _BehindContent(
                    clientProfileModel: widget.clientProfileModel,
                  ),
                ),
              ),

              // Bottom sheet
              SheetViewport(
                child: Sheet(
                  controller: _sheetController,
                  initialOffset: SheetOffset.absolute(_minSheetPeekPx),
                  snapGrid: SheetSnapGrid(
                    snaps: [
                      SheetOffset.absolute(_minSheetPeekPx),
                      const SheetOffset(0.55),
                      const SheetOffset(1),
                    ],
                  ),
                  physics: const ClampingSheetPhysics(),
                  scrollConfiguration: const SheetScrollConfiguration(),
                  decoration: MaterialSheetDecoration(
                    size: SheetSize.stretch,
                    color: Colors.white,
                    elevation: rh(context: context, px: 12),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(rh(context: context, px: 24)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: rh(context: context, px: 15)),

                          // Stats card driven by BLoC
                          BlocBuilder<HabitTrackingBloc, HabitTrackingState>(
                            builder: (context, state) {
                              return _buildStatsCard(context, state);
                            },
                          ),

                          SizedBox(height: rh(context: context, px: 42.5)),

                          AllHabitsSection(profileId: widget.profileId),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Stats card ----------------

  Widget _buildStatsCard(BuildContext context, HabitTrackingState state) {
    // Default placeholders while loading or on error
    String completionText = '--';
    String perfectDaysText = '--';

    if (state.hasData) {
      final summary = state.weekSummary;
      final rate = summary?.completionRate ?? 0.0;
      completionText = rate == rate.truncateToDouble()
          ? rate.toInt().toString()
          : rate.toStringAsFixed(1);

      perfectDaysText = _calculatePerfectDays(state.habits).toString();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 15)),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: const Color(0xFFE1E6ED),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rh(context: context, px: 20)),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 33)),
        child: Row(
          children: [
            Expanded(
              child: _StatColumn(
                label: 'Completion Rate',
                value: completionText,
                suffix: '%',
                isLoading: state.isLoading && !state.hasData,
              ),
            ),
            Expanded(
              child: _StatColumn(
                label: 'Total Perfect Days',
                value: perfectDaysText,
                suffix: 'Days',
                isLoading: state.isLoading && !state.hasData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Perfect day = day where ALL habits with status==completed (1)
  /// and none of them are pending (0). Future days are excluded.
  int _calculatePerfectDays(List<HabitItem> habits) {
    if (habits.isEmpty) return 0;

    // Build map: date -> list of statuses
    final Map<String, List<int>> dateStatusMap = {};
    for (final habit in habits) {
      for (final day in habit.tracking) {
        dateStatusMap.putIfAbsent(day.date, () => []);
        dateStatusMap[day.date]!.add(day.status);
      }
    }

    int perfectCount = 0;
    dateStatusMap.forEach((date, statuses) {
      // Skip days with any future status — can't be evaluated yet
      if (statuses.contains(2)) return;
      // All habits must be completed
      if (statuses.isNotEmpty && statuses.every((s) => s == 1)) {
        perfectCount++;
      }
    });

    return perfectCount;
  }
}

// ---------------- Helper widget ----------------

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final bool isLoading;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.suffix,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: rh(context: context, px: 10),
            fontWeight: FontWeight.w600,
            height: 1.10,
            letterSpacing: rh(context: context, px: -0.20),
          ),
        ),
        SizedBox(height: rh(context: context, px: 20)),
        if (isLoading)
          SizedBox(
            height: rh(context: context, px: 24),
            width: rh(context: context, px: 24),
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 40),
                  fontWeight: FontWeight.w400,
                  letterSpacing: rh(context: context, px: -0.80),
                  height: 1,
                ),
              ),
              SizedBox(width: rh(context: context, px: 2)),
              Padding(
                padding: EdgeInsets.only(bottom: rh(context: context, px: 6)),
                child: Text(
                  suffix,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 10),
                    fontWeight: FontWeight.w400,
                    letterSpacing: rh(context: context, px: -0.20),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _BehindContent extends StatelessWidget {
  final ClientProfileModel clientProfileModel;

  const _BehindContent({required this.clientProfileModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(
                    "Your Habits",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6715D2),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.24,
                      height: 1,
                    ),
                  ),
                  Text(
                    "Today’s To-do List ",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6715D2),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.40,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              HabitMenuButton(onTapped: () {}),
            ],
          ),
        ),
      ],
    );
  }
}