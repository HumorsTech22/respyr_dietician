import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../bloc/weight_log_bloc.dart';
import '../../bloc/weight_log_event.dart';
import '../../bloc/weight_log_state.dart';
import '../../data/repository/weight_log_repository.dart';
import '../widgets/weight_chart.dart';
import '../widgets/weight_log_history_card.dart';

class WeightTracking extends StatefulWidget {
  final ClientProfileModel clientProfile;
  const WeightTracking({super.key, required this.clientProfile});

  @override
  State<WeightTracking> createState() => _WeightTrackingState();
}

class _WeightTrackingState extends State<WeightTracking> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeightLogBloc(
        repository: WeightLogRepository(),
      )..add(LoadWeightLogs(widget.clientProfile.profileId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7FA),
          surfaceTintColor: const Color(0xFFF5F7FA),
          title: Text(
            "Weight tracker",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.40,
              letterSpacing: -0.30,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<WeightLogBloc, WeightLogState>(
            builder: (context, state) {
              if (state is WeightLogLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is WeightLogError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                );
              }

              if (state is WeightLogLoaded) {
                final logs = state.logs;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // ------- Log Weight Card (UI only for now) -------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        child: Container(
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 21),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Log Weight",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.17,
                                  letterSpacing: -0.36,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Today",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFA1A1A1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                  letterSpacing: -0.24,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 43,
                                children: [
                                  // − button
                                  IconButton(
                                    onPressed: () {
                                      // TODO: decrease weight input
                                    },
                                    style: IconButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF252525),
                                        width: 2,
                                      ),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(25000),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Color(0xFF252525),
                                    ),
                                  ),

                                  // weight display (static for now)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 19, vertical: 31),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      spacing: 10,
                                      children: [
                                        Text(
                                          "45",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF252525),
                                            fontSize: 28,
                                            fontWeight: FontWeight.w600,
                                            height: 0.75,
                                            letterSpacing: -0.56,
                                          ),
                                        ),
                                        Text(
                                          "Kg",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF252525),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            height: 1.17,
                                            letterSpacing: -0.36,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  // + button
                                  IconButton(
                                    onPressed: () {
                                      // TODO: increase weight input
                                    },
                                    style: IconButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF252525),
                                        width: 2,
                                      ),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(25000),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    icon: const Icon(
                                      Icons.add,
                                      color: Color(0xFF252525),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 36),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: call API to log weight,
                                    // then re-dispatch LoadWeightLogs
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: const Color(0xFF308BF9),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(25000),
                                    ),
                                  ),
                                  child: Text(
                                    "Log",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      height: 1.10,
                                      letterSpacing: -0.30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ------- CHART + HISTORY --------
                      if (logs.isEmpty) ...[
                        Text(
                          "No weight logs yet",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFA1A1A1),
                            fontSize: 13,
                          ),
                        ),
                      ] else ...[

                        Builder(
                          builder: (_) {
                            final orderedLogs =
                            List.of(logs.reversed);

                            final allWeights = orderedLogs
                                .map((e) => e.weightKg)
                                .toList(growable: false);

                            final allDates = orderedLogs.map((e) {
                              final String dateStr = e.logDate; // "YYYY-MM-DD"
                              final String timeStr =
                              (e.logTime.isNotEmpty ? e.logTime : '00:00:00');
                              final String dateTimeStr = '$dateStr $timeStr';
                              return DateTime.tryParse(dateTimeStr) ??
                                  DateTime.now();
                            }).toList(growable: false);

                            // latest record (last in ordered)
                            final latest = orderedLogs.last;
                            final double targetWeight = latest.targetWeight;
                            final String weightChangeType = latest.weightChangeType;

                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  WeightMiniChart(
                                    allWeights: allWeights,
                                    allDates: allDates,
                                    targetWeight: targetWeight,
                                    weightChangeType: weightChangeType,
                                  ),
                                  const SizedBox(height: 30),
                                  // You can later pass data into this card if needed
                                   WeightLogHistoryCard(
                                    logs: orderedLogs, // reversed list (oldest → latest)
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                );
              }

              // initial state
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
