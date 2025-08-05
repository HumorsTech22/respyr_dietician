import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietician/features/profile_info/data/repository/dietician_repository.dart';
import 'package:respyr_dietician/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietician/core/services/usb_communication_service.dart';
import 'package:respyr_dietician/features/account_setting_screen/presentation/pages/account_setting_screen.dart';
import 'package:respyr_dietician/features/device_connectivity/data/usb_repository_impl.dart';
import 'package:respyr_dietician/features/device_connectivity/presentation/cubit/usb_connection_cubit.dart';
import 'package:respyr_dietician/features/device_connectivity/presentation/pages/device_connectivity_screen.dart';
import 'package:respyr_dietician/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietician/features/profile_info/domain/usecases/calculate_bmr.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietician/features/profile_info/presentation/pages/profile_info_screen.dart';
import 'package:respyr_dietician/features/profile_info/presentation/widgets/image_cropper_screen.dart';
import 'package:respyr_dietician/features/result_screen/presentation/pages/result_screen.dart';
import 'package:respyr_dietician/routes/app_router.dart';

void main() {
  final calculateBMI = CalculateBMI();
  final calculateBMR = CalculateBMR();
  final dieticianRepository = DieticianRepository();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create:
              (_) =>
                  ProfileCubit(calculateBMI, calculateBMR, dieticianRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
  // import 'dart:io';
  // import 'package:flutter/material.dart';
  // import 'package:google_fonts/google_fonts.dart';
  // import 'package:image_picker/image_picker.dart';
  // import 'package:permission_handler/permission_handler.dart';

  // void main() {
  //   runApp(const MyApp());
  // }

  // class MyApp extends StatelessWidget {
  //   const MyApp({super.key});
  //   @override
  //   Widget build(BuildContext context) {
  //     return MaterialApp(
  //       title: 'Profile Picker App',
  //       debugShowCheckedModeBanner: false,
  //       theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
  //       home: const ProfilePickerScreen(),
  //     );
  //   }
  // }

  // class ProfilePickerScreen extends StatefulWidget {
  //   const ProfilePickerScreen({super.key});

  //   @override
  //   State<ProfilePickerScreen> createState() => _ProfilePickerScreenState();
  // }

  // class _ProfilePickerScreenState extends State<ProfilePickerScreen> {
  //   File? _profileImage;

  //   Future<bool> _checkPermission(ImageSource source) async {
  //     if (source == ImageSource.camera) {
  //       var cameraStatus = await Permission.camera.status;
  //       if (!cameraStatus.isGranted) {
  //         cameraStatus = await Permission.camera.request();
  //         if (!cameraStatus.isGranted) return false;
  //       }
  //     } else {
  //       if (Platform.isAndroid) {
  //         if (await Permission.photos.isGranted ||
  //             await Permission.storage.isGranted) {
  //           return true;
  //         }
  //         if (await Permission.photos.request().isGranted ||
  //             await Permission.storage.request().isGranted) {
  //           return true;
  //         }
  //         return false;
  //       } else if (Platform.isIOS) {
  //         return await Permission.photos.request().isGranted;
  //       }
  //     }
  //     return true;
  //   }

  //   Future<void> _pickImage(ImageSource source) async {
  //     final hasPermission = await _checkPermission(source);
  //     if (!hasPermission) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Permission not granted. Cannot open camera/gallery.'),
  //         ),
  //       );
  //       return;
  //     }

  //     try {
  //       final picker = ImagePicker();
  //       final pickedFile = await picker.pickImage(
  //         source: source,
  //         imageQuality: 85,
  //       );

  //       if (pickedFile != null) {
  //         setState(() => _profileImage = File(pickedFile.path));
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Image selection canceled')),
  //         );
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
  //     }
  //   }

  //   void _showImageSourceDialog() {
  //     showModalBottomSheet(
  //       context: context,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //       ),
  //       builder:
  //           (_) => SafeArea(
  //             child: Wrap(
  //               children: [
  //                 ListTile(
  //                   leading: const Icon(Icons.camera_alt),
  //                   title: const Text("Take a photo"),
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     _pickImage(ImageSource.camera);
  //                   },
  //                 ),
  //                 ListTile(
  //                   leading: const Icon(Icons.photo_library),
  //                   title: const Text("Choose from gallery"),
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     _pickImage(ImageSource.gallery);
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //     );
  //   }

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(title: const Text('Profile Picker'), centerTitle: true),
  //       body: Center(
  //         child: SizedBox(
  //           height: 140,
  //           width: 140,
  //           child: Stack(
  //             alignment: Alignment.center,
  //             children: [
  //               CircleAvatar(
  //                 radius: 65,
  //                 backgroundColor: Colors.grey.shade300,
  //                 backgroundImage:
  //                     _profileImage != null ? FileImage(_profileImage!) : null,
  //                 child:
  //                     _profileImage == null
  //                         ? Text(
  //                           'Upload\nPhoto',
  //                           textAlign: TextAlign.center,
  //                           style: GoogleFonts.poppins(
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.black54,
  //                           ),
  //                         )
  //                         : null,
  //               ),
  //               Positioned(
  //                 bottom: 0,
  //                 right: 8,
  //                 child: GestureDetector(
  //                   onTap: _showImageSourceDialog,
  //                   child: const CircleAvatar(
  //                     radius: 20,
  //                     backgroundColor: Colors.blue,
  //                     child: Icon(
  //                       Icons.camera_alt_outlined,
  //                       color: Colors.white,
  //                       size: 20,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

