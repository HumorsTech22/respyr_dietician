import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart' as law;
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/coach_sign_in/data/model/dietitian_data_model.dart';
import 'package:respyr_dietitian/features/menu/presentation/pages/profile.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/add_habits_request_model.dart';
import 'package:respyr_dietitian/features/user_habits/data/services/add_habits_service.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import '../../../../client_login_manager/client_login_manager.dart';
import '../cubit/create_profile_cubit.dart';
import '../cubit/create_profile_state.dart';

class ProfileWelcomeScreen extends StatefulWidget {
  final String foodType;
  final String activityType;
  final String goal;
  const ProfileWelcomeScreen({super.key, required this.foodType, required this.activityType, required this.goal});

  @override
  State<ProfileWelcomeScreen> createState() => _ProfileWelcomeScreenState();
}

class _ProfileWelcomeScreenState extends State<ProfileWelcomeScreen> {
  double _circleBottom = -400;
  bool _profileCreated = false;
  bool isProfileCreationErrorOccurred = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 10), () {
      if (mounted) {
        setState(() => _circleBottom = -150);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_profileCreated) {
      final profileState = context.read<ProfileCubit>().state;

      if (profileState.age != null && profileState.height != null && profileState.weight != null) {
        final dietitianId = profileState.dietitianId;
        final phoneNo = profileState.phoneNo;
        final email = profileState.email;
        final clientName = profileState.name;
        final age = profileState.age!;
        final height = profileState.height!;
        final weight = profileState.weight!;
        final region = profileState.location;
        final location = profileState.location;
        final gender = profileState.gender;
        final dob = profileState.dateOfBirth;
        final password = "1234"; // Default password

        final profileImagePath = profileState.profileImagePath ?? 'assets/images/icons/default2.png';

        context.read<CreateProfileCubit>().createProfile(
          dietitianId: dietitianId!,
          phoneNo: phoneNo,
          email: email,
          profileName: clientName,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          region: region,
          location: location,
          password: password,
          profileImagePath: profileImagePath,
          imageIsAvailable: profileImagePath == "assets/images/icons/default2.png" ? false : true, dateOfBirth: dob!,
        );

        _profileCreated = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    final loader = law.LoadingAnimationWidget.staggeredDotsWave(
      color: Colors.blue,
      size: 50,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20),
        actions: [
          Visibility(
            visible: isProfileCreationErrorOccurred,
            child: ElevatedButton(
              onPressed: () {
                // Show help
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 0),
                backgroundColor: Colors.white,
              ),
              child: Text(
                "Help?",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.10,
                  letterSpacing: 0.30,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<CreateProfileCubit, CreateProfileState>(
          listener: (BuildContext context, CreateProfileState state) {
            if (state is CreateProfileFailure) {
              setState(() {
                isProfileCreationErrorOccurred = true;
              });
            }

            if (state is CreateProfileSuccess) {
              _callAddHabitsApi(state.profile);
            }
          },
          child: BlocBuilder<CreateProfileCubit, CreateProfileState>(
            builder: (BuildContext context, CreateProfileState state) {
              if (state is CreateProfileLoading) {
                return SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        loader,
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Please hold on while we create your profile",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is CreateProfileFailure) {
                return SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Text(
                            "Oh No!",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Profile creation failed ",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                  "Status code: ${state.statusCode} ${state.error}. Please try again. If this occurs repeatedly, contact our team for further assistance.",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 0,
                                backgroundColor: const Color(0xFF308BF9),
                              ),
                              child: Text(
                                "Try again",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1.10,
                                  letterSpacing: 0.30,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  void _callAddHabitsApi(ClientProfileModel profile) async {
    // Call the AddHabits API after the profile is successfully created
    final addHabitsService = AddHabitsService();

    // Create the request model
    final requestModel = AddHabitsRequestModel(
      profileId: profile.profileId,
      goal: widget.goal,
      activity: widget.activityType,
      foodType: widget.foodType,
    );

    // Make the API call
    final response = await addHabitsService.addHabits(requestModel);

    // Check if the API call was successful
    if (response.status == true) {
      // Navigate to the next screen after habits are added successfully
      ClientLoginManager().clearClientProfile();
      bool isSaved = await ClientLoginManager().saveClientProfile(profile);
      if(isSaved){

      }
      context.go(AppRoutes.profileCreationGreeting, extra:profile,);
    } else {
      // Handle failure (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to add habits. Please try again.')),
      );
    }
  }
}