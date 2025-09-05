// clinical_name_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/profile_avatar.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class DietitianDetailScreen extends StatelessWidget {
  const DietitianDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileProgressBar(stepCompleted: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Is this your\nconsultant?',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2.04,
                ),
              ),
            ),
            SizedBox(height: 60),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      SizedBox(height: 120, child: ProfileAvatar()),
                      Text(
                        state.dietitianName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Dietitian',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.24,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "clinicalName",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.30,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Telephone',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        state.phoneNo,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.30,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email address',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        state.email,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.30,
                        ),
                      ),
                      SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Color(0xFFC7C6CE)),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/common/closeicon.svg",
                                    height: 24,
                                    width: 24,
                                    colorFilter: ColorFilter.mode(
                                      Color(0xFFEA5455),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'No, incorrect',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF252525),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        height: 1.10,
                                        letterSpacing: -0.30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                context.push(AppRoutes.profileWelcomeScreen);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Color(0xFFC7C6CE)),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/common/tick_icon.svg",
                                    height: 24,
                                    width: 24,
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Yes, correct',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF252525),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        height: 1.10,
                                        letterSpacing: -0.30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
