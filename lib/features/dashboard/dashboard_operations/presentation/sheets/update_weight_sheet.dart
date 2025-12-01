import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../../common/bottom_sheets/respyr_bottom_sheet.dart';
import '../../bloc/dashboard_operation_bloc.dart';
import '../../bloc/dashboard_operation_event.dart';
import '../../bloc/dashboard_operation_state.dart';

void showWeightUpdateBottomSheet({
  required BuildContext context,
  required ClientProfileModel clientProfile,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return BlocProvider(
        create: (_) => DashboardOperationBloc(initialWeight: double.parse(clientProfile.weight), initialWater: 250, targetWaterMl: 3500),
        child: BlocBuilder<DashboardOperationBloc, DashboardOperationState>(
          builder: (bottomSheetContext, state) {
            if (state is DashboardOperationLoaded) {
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
                          "Log Weight",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1,
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

                        // +/- row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 43,
                          children: [
                            // − button
                            IconButton(
                              onPressed: () {
                                bottomSheetContext
                                    .read<DashboardOperationBloc>()
                                    .add(DecrementWeight());
                              },
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

                            // weight display
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
                                    state.currentWeight.toString(),
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
                                bottomSheetContext
                                    .read<DashboardOperationBloc>()
                                    .add(IncrementWeight());
                              },
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

                        const SizedBox(height: 36),

                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF308BF9),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25000),
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

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            }


            return SizedBox.shrink();
          },
        ),
      );
    },
  );
}