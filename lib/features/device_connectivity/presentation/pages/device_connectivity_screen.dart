// usb_device_connectivity.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietician/features/device_connectivity/presentation/cubit/usb_connection_cubit.dart';
import 'package:respyr_dietician/features/device_connectivity/presentation/cubit/usb_connection_state.dart';
import 'package:respyr_dietician/features/profile_info/presentation/pages/profile_info_screen.dart';

class UsbDeviceConnectivity extends StatelessWidget {
  final int stepCompleted;
  const UsbDeviceConnectivity({super.key, required this.stepCompleted});

  final int totalStep = 5;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<UsbCubit, UsbState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  Row(
                    children: List.generate(totalStep, (index) {
                      final isFilled = index < stepCompleted;
                      return Expanded(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(
                            right: index < totalStep - 1 ? 4.0 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: isFilled ? Colors.black : Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Connect Device',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Connect the device to mobile phone using C-type cable.',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height:
                        300, // Set this to the height of your image or container
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered SVG Image
                        Center(
                          child: SvgPicture.asset(
                            state.isConnected
                                ? "assets/images/device_connection/connected.svg"
                                : "assets/images/device_connection/not_connected.svg",
                          ),
                        ),

                        if (state.isConnected)
                          Positioned(
                            bottom: 30,
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.5, // responsive width
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xFFD9D9D9),
                                border: Border.all(color: Color(0xFFB9B9B9)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/device_connection/device_id.svg',
                                  ),

                                  Text(
                                    'Device Id:',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF535359),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 1.10,
                                      letterSpacing: -0.24,
                                    ),
                                  ),

                                  Text(
                                    "RESPYR${state.deviceId}", // ← this should be dynamic if you're using Cubit
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF535359),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 1.10,
                                      letterSpacing: -0.24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  Center(
                    child: Text(
                      state.isConnected
                          ? 'Device Connected'
                          : 'Device Not Connected',
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  Center(
                    child: SizedBox(
                      width: 200,
                      child: TextButton(
                        onPressed: () {
                          // Handle help
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Issue With Connection?",
                              style: GoogleFonts.mulish(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_outlined,
                              size: 16,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 26, right: 26),
        child: BlocBuilder<UsbCubit, UsbState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left_outlined,
                    size: 26,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<UsbCubit>().checkDevice();

                      if (context.read<UsbCubit>().state.deviceId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ProfileInfoScreen(
                                  stepCompleted: stepCompleted + 1,
                                ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Device ID not received. Please try again.",
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF308BF9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 13,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Text(
                          "Finish up",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right_outlined,
                          size: 26,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
