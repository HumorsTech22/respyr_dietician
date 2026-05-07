import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/coach_sign_in/data/model/dietitian_data_model.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../common/widgets/text_input_decoration.dart';

class DobScreen extends StatefulWidget {
  final int stepCompleted;
  const DobScreen({super.key, required this.stepCompleted});

  @override
  State<DobScreen> createState() => _DobScreenState();
}

class _DobScreenState extends State<DobScreen> {
  String _dob = "MM/DD/YYYY";
  TextEditingController _monthController = TextEditingController();
  TextEditingController _dayController = TextEditingController();
  TextEditingController _yearController = TextEditingController();

  String _errorMessage = "";

  // Focus nodes to manage the keyboard behavior and field focus
  FocusNode _monthFocusNode = FocusNode();
  FocusNode _dayFocusNode = FocusNode();
  FocusNode _yearFocusNode = FocusNode();

  int? _age;

  void _validateDate() {
    setState(() {
      _errorMessage = "";

      // Extract values from controllers
      String month = _monthController.text;
      String day = _dayController.text;
      String year = _yearController.text;

      // Validate Month (MM)
      if (month.isEmpty || int.tryParse(month) == null || int.parse(month) < 1 || int.parse(month) > 12) {
        _errorMessage = "Please enter a valid month (01-12).";
        return;
      }

      // Validate Day (DD)
      if (day.isEmpty || int.tryParse(day) == null || int.parse(day) < 1 || int.parse(day) > 31) {
        _errorMessage = "Please enter a valid day (01-31).";
        return;
      }

      // Validate Year (YYYY)
      if (year.isEmpty || int.tryParse(year) == null || int.parse(year) < 1900 || int.parse(year) > DateTime.now().year) {
        _errorMessage = "Please enter a valid year (1900-${DateTime.now().year}).";
        return;
      }

      // Calculate age based on the DOB
      DateTime dob = DateTime(int.parse(year), int.parse(month), int.parse(day));
      _age = DateTime.now().year - dob.year;
      if (DateTime.now().month < dob.month || (DateTime.now().month == dob.month && DateTime.now().day < dob.day)) {
        _age = _age! - 1; // Subtract 1 if birthday hasn't occurred yet this year
      }

      // Validate age between 18 and 100
      if (_age! < 18) {
        _errorMessage = "You must be at least 18 years old.";
        return;
      } else if (_age! > 100) {
        _errorMessage = "Age cannot be more than 100.";
        return;
      }

      // If all fields are valid, update DOB
      if (_errorMessage.isEmpty) {
        _dob = "$month/$day/$year";
      }
    });
  }

  // Handle Focus when text length is 2 for MM/DD
  void _moveFocusToNextField(FocusNode currentFocusNode, FocusNode nextFocusNode, String text) {
    if (text.length == 2 && int.tryParse(text) != null) {
      FocusScope.of(context).requestFocus(nextFocusNode);
    }
  }

  // Handle Focus when fields are cleared (move focus backward)
  void _moveFocusBackward(FocusNode currentFocusNode, FocusNode previousFocusNode, String text) {
    if (text.isEmpty) {
      FocusScope.of(context).requestFocus(previousFocusNode);
    }
  }

  void nextProcess(ProfileCubit cubit) {
    // If DOB is valid and age is between 18 and 100, proceed to the next process
    if (_errorMessage.isEmpty) {
      print("Selected DOB: $_dob, Age: $_age");

      cubit.updateAge(_age!);
      cubit.updateDob(_dob!);

      context.push(
        AppRoutes.heightScreen,
        extra: widget.stepCompleted + 1,
      );


      // Continue to the next process (you can update this with actual navigation logic)
    } else {
      print("Error: $_errorMessage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileProgressBar(stepCompleted: widget.stepCompleted),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 24.0)),
                child : BlocBuilder<ProfileCubit, ProfileState>(builder: (BuildContext context, ProfileState state) {

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'What’s your date of birth?',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 34,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -2.04,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        spacing: 10,
                        children: [
                          // Month Field (MM)
                          Expanded(
                            child: TextField(
                              controller: _monthController,
                              focusNode: _monthFocusNode,
                              maxLength: 2,
                              decoration: buildInputDecoration(
                                hintText: "MM",
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) {
                                // Move focus to day if 2 valid digits are entered
                                _moveFocusToNextField(_monthFocusNode, _dayFocusNode, _monthController.text);
                                _moveFocusBackward(_monthFocusNode, _monthFocusNode, _monthController.text); // If cleared, stay in the same field
                                _validateDate();
                              },
                            ),
                          ),

                          Transform.rotate(
                            angle: 90 * 0.8 / 180, // Rotate 90 degrees in radians
                            child: Container(
                              width: 1,
                              height: 30,
                              color: const Color(0xFF252525),
                            ),
                          ),

                          // Day Field (DD)
                          Expanded(
                            child: TextField(
                              controller: _dayController,
                              focusNode: _dayFocusNode,
                              maxLength: 2,
                              decoration: buildInputDecoration(
                                hintText: "DD",
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) {
                                // Move focus to year if 2 valid digits are entered
                                _moveFocusToNextField(_dayFocusNode, _yearFocusNode, _dayController.text);
                                _moveFocusBackward(_dayFocusNode, _monthFocusNode, _dayController.text); // If cleared, go back to month
                                _validateDate();
                              },
                            ),
                          ),

                          // Vertical Divider
                          Transform.rotate(
                            angle: 90 * 0.8 / 180, // Rotate 90 degrees in radians
                            child: Container(
                              width: 1,
                              height: 30,
                              color: const Color(0xFF252525),
                            ),
                          ),

                          // Year Field (YYYY)
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _yearController,
                              focusNode: _yearFocusNode,
                              maxLength: 4,  // Limit the input to 4 digits
                              decoration: buildInputDecoration(
                                hintText: "YYYY",
                              ),
                              keyboardType: TextInputType.number,  // Show numeric keypad
                              textInputAction: TextInputAction.done,  // Close keyboard on 'done'
                              onChanged: (_) {
                                // If the year is cleared, focus back to the day field
                                _moveFocusBackward(_yearFocusNode, _dayFocusNode, _yearController.text);
                                _validateDate();
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,  // Allow only digits
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  );
                },
                )

              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final cubit = context.read<ProfileCubit>();

            return ProfileBottomNavigation(
              onBack: () {
                context.pop();
              },
              onNext: (){
                nextProcess(cubit);
              },  // Call the nextProcess method to validate DOB and age
            );
          },
        ),
      ),
    );
  }
}