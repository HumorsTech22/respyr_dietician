import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietician/core/utils/validators.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_state.dart';
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
  Timer? _debounce;
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
    _debounce?.cancel();
    dieticianController.dispose();
    _dieticianFocusNode.dispose();
    super.dispose();
  }

  void _validateAndProceed(BuildContext context, ProfileState state) {
    final cubit = context.read<ProfileCubit>();
    final input = dieticianController.text.trim();

    final error = Validators.validateDieticianId(input);
    final isChecked = state.isCheckboxChecked;
    final isDieticianIdFound = state.dieticianName;
    setState(() => errorText = error);

    if (error != null) return;

    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please confirm your Dietician ID by checking the box.",
          ),
          backgroundColor: Color(0xFF308BF9),
        ),
      );
      return;
    }
    if (isDieticianIdFound == 'NotFound') return;

    final dieticianId = int.parse(input);
    cubit.updateDietician(dieticianId);

    context.push(AppRoutes.profileWelcomeScreen);
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
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileProgressBar(stepCompleted: widget.stepCompleted),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      final cubit = context.read<ProfileCubit>();

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
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
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
                                _validateInput(state);

                                if (_debounce?.isActive ?? false) {
                                  _debounce?.cancel();
                                }

                                // Clear clinical name when input is empty
                                if (value.trim().isEmpty ||
                                    value.trim().length <= 7) {
                                  context
                                      .read<ProfileCubit>()
                                      .clearDieticianName();
                                  return;
                                }
                                _debounce = Timer(
                                  const Duration(milliseconds: 300),
                                  () {
                                    if (value.trim().length >= 9) {
                                      context
                                          .read<ProfileCubit>()
                                          .fetchDieticianName(value.trim());
                                    }
                                  },
                                );
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
                          if (state.dieticianName.isNotEmpty &&
                              state.dieticianName != 'NotFound')
                            SizedBox(height: 20),
                          if (state.dieticianName.isNotEmpty &&
                              state.dieticianName != 'NotFound')
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: const Color(0xFFB9B9B9),
                                  ),
                                ),
                                child: Text(
                                  "Clinical Name: ${state.dieticianName}",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          if (state.dieticianName == 'NotFound')
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 10,
                              ),
                              child: Text(
                                "Clinical Name not found",
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          Spacer(),
                          Row(
                            children: [
                              BlocBuilder<ProfileCubit, ProfileState>(
                                builder: (context, state) {
                                  return Checkbox(
                                    value: state.isCheckboxChecked,
                                    onChanged: (value) {
                                      cubit.toggleCheckbox(value ?? false);
                                    },

                                    activeColor: Color(0xFF308BF9),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "I confirm my Clinical Name is correct.",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),

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
                _validateAndProceed(
                  context,
                  context.read<ProfileCubit>().state,
                );
              },
              nextLabel: "Finished Up",
            );
          },
        ),
      ),
    );
  }
}
