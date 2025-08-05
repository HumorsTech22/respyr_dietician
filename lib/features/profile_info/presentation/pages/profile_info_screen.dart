import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:respyr_dietician/common/widgets/text_input_decoration.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietician/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietician/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietician/features/profile_info/presentation/widgets/region_selector.dart';
import 'package:respyr_dietician/routes/app_routes.dart';

class ProfileInfoScreen extends StatefulWidget {
  final int stepCompleted;

  const ProfileInfoScreen({super.key, required this.stepCompleted});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Uint8List? _croppedData;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileCubit>().state;
    nameController.text = state.name;
    emailController.text = state.email;
    locationController.text = state.location;
  }

  Future<bool> _checkPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) return false;
      }
    } else {
      if (Platform.isAndroid) {
        var photosStatus = await Permission.photos.status;
        var storageStatus = await Permission.storage.status;
        if (!photosStatus.isGranted && !storageStatus.isGranted) {
          photosStatus = await Permission.photos.request();
          storageStatus = await Permission.storage.request();
        }
        return photosStatus.isGranted || storageStatus.isGranted;
      } else if (Platform.isIOS) {
        return await Permission.photos.request().isGranted;
      }
    }
    return true;
  }

  final regions = ['North', 'South', 'East', 'West'];

  Future<void> _pickImage(BuildContext context) async {
    final hasPermission = await _checkPermission(ImageSource.gallery);
    if (!context.mounted) return;
    if (!hasPermission) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Permission not granted.')));
      return;
    }

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      final imagebytes = await pickedFile.readAsBytes();
      if (!context.mounted) return;
      final result = await context.push(
        AppRoutes.imageCropperScreen,
        extra: imagebytes,
      );

      if (result != null && result is Uint8List) {
        setState(() {
          _croppedData = result;
        });
        if (!context.mounted) return;
        // Optionally update your cubit here
        context.read<ProfileCubit>().updateProfileImage(result);
      } else {
        // Optional: Show a message if user cancels
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        nameController.text = state.name;
        emailController.text = state.email;
        locationController.text = state.location;
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,

          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileProgressBar(stepCompleted: widget.stepCompleted),

                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: SingleChildScrollView(
                      reverse: true,
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: MediaQuery.of(context).viewInsets.top,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Title
                          Text(
                            'Basic Info',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 34,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 47),

                          /// Avatar
                          Center(
                            child: SizedBox(
                              height: 140,
                              width: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_croppedData != null) {
                                        context.push(
                                          AppRoutes.fullScreenImageView,
                                          extra: _croppedData,
                                        );
                                      } else {
                                        _pickImage(
                                          context,
                                        ); // Open picker if no image is cropped yet
                                      }
                                    },

                                    child: CircleAvatar(
                                      radius: 65,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage:
                                          _croppedData != null
                                              ? MemoryImage(_croppedData!)
                                              : null,
                                      child:
                                          _croppedData == null
                                              ? Text(
                                                'Upload\nPhoto',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54,
                                                ),
                                              )
                                              : null,
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 0,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        _pickImage(context);
                                      },
                                      child: const CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.blue,
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 42),

                          /// Form
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: nameController,
                                  keyboardType: TextInputType.name,
                                  cursorColor: Colors.blue,
                                  maxLength: 16,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textCapitalization: TextCapitalization.words,
                                  buildCounter:
                                      (
                                        _, {
                                        required currentLength,
                                        required isFocused,
                                        required maxLength,
                                      }) => null,
                                  onChanged:
                                      (value) => context
                                          .read<ProfileCubit>()
                                          .updateName(value.trim()),
                                  validator: (value) {
                                    value = value?.trim();
                                    if (value == null || value.isEmpty) {
                                      return 'Name should not be empty';
                                    }
                                    if (value.length < 3) {
                                      return 'Name must be at least 3 characters long';
                                    }
                                    final nameExp = RegExp(r'^[a-zA-Z\s]+$');
                                    if (!nameExp.hasMatch(value)) {
                                      return 'Name cannot contain numbers or special characters';
                                    }
                                    return null;
                                  },
                                  decoration: buildInputDecoration(
                                    hintText: "Enter name",
                                    prefixIcon:
                                        "assets/images/common/profile_name_icon.svg",
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: Colors.blue,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  onChanged:
                                      (value) => context
                                          .read<ProfileCubit>()
                                          .updateEmail(value.trim()),
                                  validator: (value) {
                                    value = value?.trim();
                                    if (value == null || value.isEmpty) {
                                      return 'Email should not be empty';
                                    }
                                    final emailExp = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                                    );
                                    if (!emailExp.hasMatch(value)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                  decoration: buildInputDecoration(
                                    hintText: "Enter email",
                                    prefixIcon:
                                        "assets/images/common/profile_mail_icon.svg",
                                  ),
                                ),
                                const SizedBox(height: 16),
                                RegionSelectorField(
                                  controller: locationController,
                                  regions: regions,
                                  selectedRegion: locationController.text,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Bottom navigation
          bottomNavigationBar: ProfileBottomNavigation(
            onNext: () {
              if (formKey.currentState!.validate()) {
                final cubit = context.read<ProfileCubit>();
                cubit.updateName(nameController.text.trim());
                cubit.updateEmail(emailController.text.trim());
                cubit.updateLocation(locationController.text.trim());
                // Navigate to next screen
                context.push(
                  AppRoutes.genderScreen,
                  extra: widget.stepCompleted + 1,
                );
              }
            },
            onBack: () {
              // context.pop();
            },
          ),
        );
      },
    );
  }
}
