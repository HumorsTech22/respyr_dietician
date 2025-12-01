import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../client-dashboard/data/model/client_profile_model.dart'
    show ClientProfileModel;
import '../../../../../common/bottom_sheets/respyr_bottom_sheet.dart';
import '../../../../../common/dialogs/floating_message.dart';
import '../../../../../common/widgets/water_progress.dart';
import '../../bloc/dashboard_operation_bloc.dart';
import '../../bloc/dashboard_operation_event.dart';
import '../../bloc/dashboard_operation_state.dart';

void showUpdateWaterIntakeSheet({
  required BuildContext context,
  required ClientProfileModel clientProfile,
}) {
  // 🔹 initial ml used in this sheet
  const double initialWaterMl = 250; // 1 glass

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return BlocProvider(
        create: (_) => DashboardOperationBloc(
          initialWeight: double.parse(clientProfile.weight),
          initialWater: initialWaterMl, // starting from 1 glass
          targetWaterMl: 3500,          // daily target ml (you can replace with dynamic)
        ),

        // 🔹 Listen for success/error from insert_water_log.php
        child: BlocListener<DashboardOperationBloc, DashboardOperationState>(
          listenWhen: (previous, current) {
            if (previous is DashboardOperationLoaded &&
                current is DashboardOperationLoaded) {
              return previous.lastSaveSuccess != current.lastSaveSuccess ||
                  previous.errorMessage != current.errorMessage;
            }
            return false;
          },
          listener: (listenerContext, state) {
            if (state is DashboardOperationLoaded) {
              if (state.lastSaveSuccess) {
                FloatingMessage.show(context, message: "Water intake logged", type: FloatingMessageType.success);
                Navigator.of(ctx).pop();
              }
              else if (state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                FloatingMessage.show(context, message: state.errorMessage!, type: FloatingMessageType.error);

              }
            }
          },

          child: BlocBuilder<DashboardOperationBloc, DashboardOperationState>(
            builder: (bottomSheetContext, state) {
              if (state is! DashboardOperationLoaded) {
                return const SizedBox.shrink();
              }

              // use values from state
              final double targetWaterMl = state.targetWaterMl;
              final double waterIntake = state.waterIntake;

              const int glassSizeMl = 250;
              final int totalGlasses = (targetWaterMl / glassSizeMl).ceil();
              final int consumedGlasses = (waterIntake / glassSizeMl).ceil();

              final bool isSaving = state.isSaving;
              final bool canIncrement = !isSaving;
              final bool canDecrement =
                  !isSaving && waterIntake >= glassSizeMl;

              return AppBottomSheet(
                onCloseSheet: () {
                  Navigator.of(ctx).pop();
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 21),
                        Text(
                          "1 Glass (${glassSizeMl}ml)",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.75,
                            letterSpacing: -0.24,
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

                        /// +/- row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 43,
                          children: [
                            // − button
                            IconButton(
                              onPressed: canDecrement
                                  ? () {
                                // 1) update local UI
                                bottomSheetContext
                                    .read<DashboardOperationBloc>()
                                    .add(DecrementWater());

                                // 2) send -1 glass log to API
                                bottomSheetContext
                                    .read<DashboardOperationBloc>()
                                    .add(
                                  InsertWaterLog(
                                    profileId:
                                    clientProfile.profileId,
                                    consumedMl: -glassSizeMl,
                                    targetedMl:
                                    targetWaterMl.toInt(),
                                    loggedBy: 'dietitian',
                                    loggedById:
                                    "dieticianId", // TODO: actual id
                                    notes: null,
                                  ),
                                );
                              }
                                  : null,
                              style: IconButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF252525),
                                  width: 2,
                                ),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25000),
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

                            // glass widget
                            SizedBox(
                              child: SimpleWaterGlass(
                                targetMl: targetWaterMl,
                                consumedMl: waterIntake,
                              ),
                            ),

                            // + button
                            IconButton(
                              onPressed: canIncrement
                                  ? () {
                                // 1) update local UI
                                bottomSheetContext
                                    .read<DashboardOperationBloc>()
                                    .add(IncrementWater());

                                // 2) send +1 glass log to API
                                bottomSheetContext
                                    .read<DashboardOperationBloc>()
                                    .add(
                                  InsertWaterLog(
                                    profileId:
                                    clientProfile.profileId,
                                    consumedMl: glassSizeMl,
                                    targetedMl:
                                    targetWaterMl.toInt(),
                                    loggedBy: 'dietitian',
                                    loggedById:
                                    "dieticianId", // TODO: actual id
                                    notes: null,
                                  ),
                                );
                              }
                                  : null,
                              style: IconButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF252525),
                                  width: 2,
                                ),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25000),
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

                        const SizedBox(height: 40),

                        /// progress bars
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Row(
                                children: List.generate(totalGlasses, (index) {
                                  return Expanded(
                                    child: Container(
                                      margin:
                                      const EdgeInsets.only(right: 4),
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: index + 1 <= consumedGlasses
                                            ? const Color(0xFF308BF9)
                                            : const Color(0xFFF0F0F0),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: consumedGlasses.toString(),
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF308BF9),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                        height: 1.24,
                                        letterSpacing: -0.34,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                      " Out of $totalGlasses glasses",
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFA1A1A1),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                        height: 1.24,
                                        letterSpacing: -0.34,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
