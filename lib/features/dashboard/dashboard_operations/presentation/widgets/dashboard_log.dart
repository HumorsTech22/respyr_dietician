import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/ring_progress.dart';
import '../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../tracking/water_tracking/presentation/screens/water_tracking.dart';
import '../../../../tracking/weight_tracking/presentation/screens/weight_tracking.dart';
import '../../bloc/dashboard_operation_bloc.dart';
import '../sheets/update_water_intake_sheet.dart';
import '../sheets/update_weight_sheet.dart';

class DashboardLog extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const DashboardLog({super.key, required this.clientProfileModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 30,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Logging",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: IntrinsicHeight(
            child: Row(
              spacing: 10,
              children: [
               Expanded(
                  child: InkWell(
                    onTap: (){

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<DashboardOperationBloc>(), // existing bloc from current screen
                            child: WaterTracking(
                              clientProfileModel: clientProfileModel, // from your selected client
                              targetWaterInML: 4000,                  // from profile or settings
                            ),
                          ),
                        ),
                      );

                    },
                    child: Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFE1E6ED),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 18, 8, 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RingProgress(
                            progress: 0.8,
                            size: 45,
                            strokeWidth: 4,
                            progressColor: const Color(0xFF308BF9),
                            trackColor: const Color(0xFFD9D9D9),
                            center: SvgPicture.asset(
                              "assets/images/icons/ic_water.svg",
                              width: 24,
                            ),
                            startAngle: -90,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Water Intake",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1,
                              letterSpacing: -0.30,
                            ),
                          ),
                          const SizedBox(height: 31),
                          Text(
                            "2.4L",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                              height: 1,
                              letterSpacing: -0.60,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "5 of 8 glasses",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFA1A1A1),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1,
                              letterSpacing: -0.24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 17,
                                  vertical: 7,
                                ),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFD9D9D9),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Goal : 3.2L ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w400,
                                        height: 1,
                                        letterSpacing: -0.18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  showUpdateWaterIntakeSheet(
                                    context: context,
                                    clientProfile: clientProfileModel,
                                  );
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF308BF9),
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
                                  color: Color(0xFF308BF9),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeightTracking(clientProfile: clientProfileModel,),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFE1E6ED),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 18, 8, 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RingProgress(
                            progress: 0.8,
                            size: 45,
                            strokeWidth: 4,
                            progressColor: const Color(0xFFB388EB),
                            trackColor: const Color(0xFFD9D9D9),
                            center: SvgPicture.asset(
                              "assets/images/icons/ic_weight.svg",
                              width: 24,
                            ),
                            startAngle: -90,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Current Weight",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1,
                              letterSpacing: -0.30,
                            ),
                          ),
                          const SizedBox(height: 31),
                          Text(
                            "2.4L",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                              height: 1,
                              letterSpacing: -0.60,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "5 of 8 glasses",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFA1A1A1),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1,
                              letterSpacing: -0.24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 17,
                                  vertical: 7,
                                ),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFD9D9D9),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Goal : 3.2L ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w400,
                                        height: 1,
                                        letterSpacing: -0.18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  showWeightUpdateBottomSheet(
                                    context: context,
                                    clientProfile: clientProfileModel,
                                  );
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF308BF9),
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
                                  color: Color(0xFF308BF9),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
