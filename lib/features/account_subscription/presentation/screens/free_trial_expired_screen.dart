import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class FreeTrialExpiredScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final VoidCallback skipClicked;

  const FreeTrialExpiredScreen({
    super.key,
    required this.clientProfileModel,
    required this.skipClicked,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = rh(context: context, px: 20);
    final smallTextSize = rh(context: context, px: 12);
    final titleSize = rh(context: context, px: 34);
    final sectionTitleSize = rh(context: context, px: 25);
    final benefitTitleSize = rh(context: context, px: 15);
    final buttonTextSize = rh(context: context, px: 15);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF252525),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF252525),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 52,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: Image.asset(
                          "assets/images/common/img_free_trail.png",
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                    Positioned(
                      top: rh(context: context, px: 18),
                      right: rh(context: context, px: 15),
                      child: InkWell(
                        onTap: () {
                          skipClicked();
                        },
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            rh(context: context, px: 4),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: rh(context: context, px: 24),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: rh(context: context, px: 60),
                      left: horizontalPadding,
                      right: horizontalPadding,
                      child: Text(
                        "Your Free Trail Has\nEnded!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: titleSize,
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                          letterSpacing: -rh(context: context, px: 2.04),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 48,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF7F7F7),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    rh(context: context, px: 14),
                    horizontalPadding,
                    rh(context: context, px: 15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your 7-day\nFree trail is complete.",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: sectionTitleSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -rh(context: context, px: 1),
                        ),
                      ),
                      SizedBox(height: rh(context: context, px: 10)),
                      Text(
                        "To continue your metabolic journey, please activate your plan.",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: smallTextSize,
                          fontWeight: FontWeight.w400,
                          height: 1.30,
                          letterSpacing: -rh(context: context, px: 0.24),
                        ),
                      ),
                      SizedBox(height: rh(context: context, px: 24)),
                      Text(
                        "Plan Benefits",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: benefitTitleSize,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -rh(context: context, px: 0.60),
                        ),
                      ),
                      SizedBox(height: rh(context: context, px: 18)),
                      _benefitRow(context, "Daily metabolic insights"),
                      SizedBox(height: rh(context: context, px: 10)),
                      _benefitRow(context, "Progress tracking & trends"),
                      SizedBox(height: rh(context: context, px: 10)),
                      _benefitRow(context, "Personalized nutrition guidance"),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go(
                              AppRoutes.activationCodeScree,
                              extra: clientProfileModel,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF308BF9),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              vertical: rh(context: context, px: 20),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 50),
                              ),
                            ),
                          ),
                          child: Text(
                            "Enter Activation Code",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: buttonTextSize,
                              fontWeight: FontWeight.w700,
                              height: 1.10,
                              letterSpacing: rh(context: context, px: 0.30),
                            ),
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
      ),
    );
  }

  Widget _benefitRow(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: rh(context: context, px: 5),
          width: rh(context: context, px: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(
              rh(context: context, px: 50),
            ),
          ),
        ),
        SizedBox(width: rh(context: context, px: 5)),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w400,
              height: 1.30,
              letterSpacing: -rh(context: context, px: 0.24),
            ),
          ),
        ),
      ],
    );
  }
}