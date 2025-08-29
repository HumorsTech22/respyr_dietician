import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/profile_avatar.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class ProfileWelcomeScreen extends StatefulWidget {
  const ProfileWelcomeScreen({super.key});

  @override
  State<ProfileWelcomeScreen> createState() => _ProfileWelcomeScreenState();
}

class _ProfileWelcomeScreenState extends State<ProfileWelcomeScreen> {
  double _circleBottom = -400;

  @override
  void initState() {
    super.initState();

    // Animate circle after screen builds
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _circleBottom = -150; // bring it up into view
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            /// Animated background circle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              bottom: _circleBottom,
              right: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: const BoxDecoration(
                  color: Color(0xFF2F80ED),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              right: 30,
              child: InkWell(
                onTap: () {
                  context.push(AppRoutes.usbDeviceConnectivity);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Go to dashboard',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.10,
                        letterSpacing: 0.30,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final cubit = context.read<ProfileCubit>();

                final bmi = cubit.getBMI();
                final bmr = cubit.getBMR();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const ProfileAvatar(),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome sparsh!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 34,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -2.04,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your profile has been created',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.30,
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (bmi != null && bmr != null) ...[
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children: [
                                  Text(
                                    'Current BMI',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF535359),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,

                                      letterSpacing: -0.24,
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${bmi.toStringAsFixed(1)}kg/m',
                                          style: TextStyle(
                                            color: const Color(0xFF535359),
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '2',
                                          style: TextStyle(
                                            color: const Color(0xFF535359),
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,

                                            fontFeatures: [
                                              FontFeature.enable("sups"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              VerticalDivider(
                                color: Color(0xFFC7C6CE),
                                width: 2,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Current BMR',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF535359),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,

                                      letterSpacing: -0.24,
                                    ),
                                  ),

                                  Text(
                                    '${bmr.toStringAsFixed(0)} kcal',
                                    style: TextStyle(
                                      color: const Color(0xFF535359),
                                      fontSize: 20,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Text(
                          "Missing profile data to calculate BMI/BMR.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
