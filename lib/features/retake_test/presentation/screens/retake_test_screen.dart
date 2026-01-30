import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../routes/app_routes.dart';
import '../../bloc/retake_test_cubit.dart';
import '../../bloc/retake_test_state.dart';
import '../widgets/screen_radio_button.dart';

class RetakeTestScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const RetakeTestScreen({super.key, required this.clientProfileModel});

  @override
  State<RetakeTestScreen> createState() => _RetakeTestScreenState();
}

class _RetakeTestScreenState extends State<RetakeTestScreen> {
  late final TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RetakeTestCubit(),
      child: BlocListener<RetakeTestCubit, RetakeTestState>(
        listenWhen: (p, n) => p.submitted != n.submitted && n.submitted == true,
        listener: (context, state) {
          // ✅ navigate to next screen here
          // Example:
          context.push(AppRoutes.testConditionScreen, extra: widget.clientProfileModel);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () => context.go(
                  AppRoutes.clientDashboard,
                  extra: widget.clientProfileModel,
                ),
                icon: const Icon(Icons.close),
              ),
              const SizedBox(width: 10),
            ],
          ),

          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Reason for retaking the test?",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ only rebuild options when selectedReason/details changes
                BlocBuilder<RetakeTestCubit, RetakeTestState>(
                  buildWhen: (p, n) =>
                  p.selectedReason != n.selectedReason ||
                      p.details != n.details,
                  builder: (context, state) {
                    final cubit = context.read<RetakeTestCubit>();

                    // ✅ keep controller in sync with cubit state (only when needed)
                    final shouldShowInput =
                        state.selectedReason == "not_satisfied" ||
                            state.selectedReason == "other";

                    if (!shouldShowInput && _detailsController.text.isNotEmpty) {
                      _detailsController.clear();
                    }

                    if (shouldShowInput &&
                        _detailsController.text != state.details) {
                      _detailsController.value = TextEditingValue(
                        text: state.details,
                        selection: TextSelection.collapsed(
                          offset: state.details.length,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ScreenRadioButton(
                          label: "Just curious",
                          value: "curious",
                          selectedValue: state.selectedReason,
                          showInput: false,
                          controller: _detailsController,
                          onSelected: (v) {
                            cubit.selectReason(v);
                            _detailsController.clear(); // ✅ clear on curious
                          },
                          onTextChanged: () {},
                        ),

                        ScreenRadioButton(
                          label: "Not satisfied with the first test",
                          value: "not_satisfied",
                          selectedValue: state.selectedReason,
                          showInput: true,
                          controller: _detailsController,
                          onSelected: cubit.selectReason,
                          onTextChanged: () =>
                              cubit.updateDetails(_detailsController.text),
                        ),

                        ScreenRadioButton(
                          label: "Other",
                          value: "other",
                          selectedValue: state.selectedReason,
                          showInput: true,
                          controller: _detailsController,
                          onSelected: cubit.selectReason,
                          onTextChanged: () =>
                              cubit.updateDetails(_detailsController.text),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          bottomNavigationBar: BlocSelector<RetakeTestCubit, RetakeTestState, bool>(
            selector: (state) => state.isButtonEnabled,
            builder: (context, enabled) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: enabled
                          ? () => context.read<RetakeTestCubit>().submit()
                          : null,
                      style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 14),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (states) {
                            if (states.contains(WidgetState.disabled)) {
                              return const Color(0xFFCAE1FF);
                            }
                            return const Color(0xFF308BF9);
                          },
                        ),
                      ),
                      child: Text(
                        "Continue",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
