import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietician/core/utils/validators.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietician/features/profile_info/presentation/widgets/dietician_detail_screen.dart';
import 'package:respyr_dietician/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietician/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietician/routes/app_routes.dart';

class DieticianScreen extends StatefulWidget {
  final int stepCompleted;

  const DieticianScreen({super.key, required this.stepCompleted});

  @override
  State<DieticianScreen> createState() => _DieticianScreenState();
}

class _DieticianScreenState extends State<DieticianScreen> {
  final TextEditingController dieticianController = TextEditingController();
  String? errorText;
  final FocusNode _dieticianFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_dieticianFocusNode);
    });
  }

  @override
  void dispose() {
    dieticianController.dispose();
    _dieticianFocusNode.dispose();
    super.dispose();
  }

  void _validateAndProceed(ProfileState state) async {
    final cubit = context.read<ProfileCubit>();
    final input = dieticianController.text.trim();

    final error = Validators.validateDieticianId(input);
    setState(() => errorText = error);

    if (error != null) return;

    // Fetch asynchronously
    await cubit.fetchDieticianName(input);

    // ✅ Check if widget is still mounted
    if (!mounted) return;

    final updatedState = context.read<ProfileCubit>().state;

    // Show error if not found or failed
    if (updatedState.dieticianName == 'NotFound' ||
        updatedState.dieticianName == 'Error' ||
        updatedState.dieticianName.trim().isEmpty) {
      setState(() {
        errorText = "Dietician not found";
      });
      return;
    }

    cubit.updateDietician(input);

    context.push(AppRoutes.dieticianDetailScreen);
  }

  bool _validateInput(ProfileState state) {
    final input = dieticianController.text.trim();
    final error = Validators.validateDieticianId(input);
    setState(() => errorText = error);
    return error == null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileProgressBar(stepCompleted: widget.stepCompleted),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Almost there!',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Your Dietician ID?',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 34,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -2.04,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    errorText != null
                                        ? Colors.red
                                        : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: TextFormField(
                              focusNode: _dieticianFocusNode,
                              controller: dieticianController,

                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              maxLength: 9,
                              decoration: InputDecoration(
                                hintText: "Enter your dietician ID",
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                  height: 1.10,
                                  letterSpacing: -0.30,
                                ),
                                counterText: "",
                                border: noBorder,
                                enabledBorder: noBorder,
                                disabledBorder: noBorder,
                                focusedBorder: noBorder,
                              ),
                              onChanged: (value) {
                                final trimmed = value.trim();
                                _validateInput(state);

                                final cubit = context.read<ProfileCubit>();

                                if (trimmed.isEmpty || trimmed.length <= 7) {
                                  cubit.clearDieticianName();
                                  return;
                                }
                              },
                            ),
                          ),
                          if (errorText != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 10,
                              ),
                              child: Text(
                                errorText!,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                          Spacer(),

                          SizedBox(height: 30),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return ProfileBottomNavigation(
              onBack: () {
                context.pop();
              },
              onNext: () {
                FocusScope.of(context).unfocus();
                _validateAndProceed(context.read<ProfileCubit>().state);
              },
              nextLabel: "Finished Up",
            );
          },
        ),
      ),
    );
  }
}
