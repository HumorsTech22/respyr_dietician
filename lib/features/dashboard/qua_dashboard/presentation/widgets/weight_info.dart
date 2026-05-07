import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/weight_progress_badge.dart';

class WeightInfo extends StatelessWidget {
  const WeightInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rh(context: context, px: 20),
      ),
      child: Container(
        decoration: ShapeDecoration(
          color: const Color(0xFFE1E6ED),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              rh(context: context, px: 10),
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 20),
            vertical: rh(context: context, px: 20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Weight",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 12),
                          fontWeight: FontWeight.w400,
                          letterSpacing:
                          rh(context: context, px: -0.24),
                          height: 1.0,
                        ),
                      ),
                      SizedBox(
                        height: rh(context: context, px: 20),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "75",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize:
                              rh(context: context, px: 100),
                              fontWeight: FontWeight.w400,
                              letterSpacing:
                              rh(context: context, px: -2),
                              height: 1.0,
                            ),
                          ),
                          SizedBox(
                            width: rh(context: context, px: 10),
                          ),
                          Text(
                            "Kg",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize:
                              rh(context: context, px: 20),
                              fontWeight: FontWeight.w600,
                              height: 3,
                              letterSpacing:
                              rh(context: context, px: -0.40),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SvgPicture.asset(
                    "assets/images/icons/ic_weight.svg",
                    width: rh(context: context, px: 24),
                    height: rh(context: context, px: 24),
                    color: const Color(0xFF535359),
                  )
                ],
              ),
              SizedBox(
                height: rh(context: context, px: 32),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF252525),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      rh(context: context, px: 50),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: rh(context: context, px: 30),
                    vertical: rh(context: context, px: 20),
                  ),
                  elevation: 0,
                ),
                onPressed: () {},
                child: Text(
                  'Update Weight',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: rh(context: context, px: 15),
                    fontWeight: FontWeight.w700,
                    height: 1.10,
                    letterSpacing:
                    rh(context: context, px: 0.30),
                  ),
                ),
              ),
              SizedBox(
                height: rh(context: context, px: 28),
              ),
              WeightProgressBadgeCurrent(
                currentWeight: 69,
                targetedWeight: 100,
                initialWeight: 68,
              ),
            ],
          ),
        ),
      ),
    );
  }
}