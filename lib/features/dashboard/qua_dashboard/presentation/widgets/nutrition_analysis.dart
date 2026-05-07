import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/bloc/macro_summary_cubit.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/bloc/macro_summary_state.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/services/macro_summary_service.dart';

import 'macro_distribution_chart.dart';
import 'macro_info_card.dart';

class NutritionAnalysis extends StatelessWidget {
  final ClientProfileModel clientProfileModel;

  const NutritionAnalysis({
    super.key,
    required this.clientProfileModel,
  });

  String _currentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MacroSummaryCubit(
        service: MacroSummaryService(),
      )..fetchMacroSummary(
        profileId: clientProfileModel.profileId ?? '',
        date: _currentDate(),
      ),
      child: BlocBuilder<MacroSummaryCubit, MacroSummaryState>(
        builder: (context, state) {
          final current = state.data?.currentData;
          final change = state.data?.macroChangeFromPrevious;

          return Container(
            color: const Color(0xFFF5F7FA),
            padding: EdgeInsets.only(
              top: rh(context: context, px: 37),
              bottom: rh(context: context, px: 30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rh(context: context, px: 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Nutrition Analysis",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 12),
                          fontWeight: FontWeight.w400,
                          letterSpacing: rh(context: context, px: -0.24),
                        ),
                      ),
                      SizedBox(height: rh(context: context, px: 20)),
                      Text(
                        state.isLoading
                            ? "Fetching your nutrition goal..."
                            : current == null
                            ? "No nutrition data found for today."
                            : "You’re calorie goal for today is ${current.finalMacroSummary.calories.toStringAsFixed(0)} Kcal.",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 25),
                          fontWeight: FontWeight.w600,
                          letterSpacing: rh(context: context, px: -1),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: rh(context: context, px: 40)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rh(context: context, px: 5),
                  ),
                  child: state.isLoading
                      ? SizedBox(
                    height: rh(context: context, px: 120),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : MacroDistributionChart(
                    carbs: current?.macroPercentage.carbsPercent ?? 0,
                    fats: current?.macroPercentage.fatPercent ?? 0,
                    protein:
                    current?.macroPercentage.proteinPercent ?? 0,
                    fibre: current?.macroPercentage.fiberPercent ?? 0,
                  ),
                ),
                SizedBox(height: rh(context: context, px: 40)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rh(context: context, px: 20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: macroInfoCard(
                              macroType: 'Carbs',
                              macroValue:
                              current?.finalMacroSummary.carbsG ?? 0,
                              changePercent:
                              change?.carbsG.changePercent ?? 0,
                              changeType:
                              change?.carbsG.changeType ?? 'no_change',
                              context: context,
                            ),
                          ),
                          Expanded(
                            child: macroInfoCard(
                              macroType: 'Fat',
                              macroValue:
                              current?.finalMacroSummary.fatG ?? 0,
                              changePercent:
                              change?.fatG.changePercent ?? 0,
                              changeType:
                              change?.fatG.changeType ?? 'no_change',
                              context: context,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: rh(context: context, px: 24.5)),
                      Row(
                        children: [
                          Expanded(
                            child: macroInfoCard(
                              macroType: 'Protein',
                              macroValue:
                              current?.finalMacroSummary.proteinG ?? 0,
                              changePercent:
                              change?.proteinG.changePercent ?? 0,
                              changeType:
                              change?.proteinG.changeType ?? 'no_change',
                              context: context,
                            ),
                          ),
                          Expanded(
                            child: macroInfoCard(
                              macroType: 'Fibre',
                              macroValue:
                              current?.finalMacroSummary.fiberG ?? 0,
                              changePercent:
                              change?.fiberG.changePercent ?? 0,
                              changeType:
                              change?.fiberG.changeType ?? 'no_change',
                              context: context,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}