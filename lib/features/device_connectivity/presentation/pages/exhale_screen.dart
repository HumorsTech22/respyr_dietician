import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/generating_result_params.dart';
import 'package:respyr_dietitian/features/device_connectivity/domain/processor/usb_blow_processor.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/exhale_screen/exhale_cubit.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/exhale_screen/exhale_state.dart';
import 'package:respyr_dietitian/common/dialogs/improper_exhale_dialog.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class ExhaleScreen extends StatelessWidget {
  final String baseValue;

  const ExhaleScreen({super.key, required this.baseValue});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ExhaleCubit(
            processor: UsbBlowProcessor(),
            usbService: UsbCommunicationService(),
            baseValue: baseValue,
          ),
      child: BlocListener<ExhaleCubit, ExhaleState>(
        listener: (context, state) {
          if (state is ExhaleDone) {
            final processor = context.read<ExhaleCubit>().processor;

            final maxPR =
                processor.blowValuesList.isNotEmpty
                    ? processor.blowValuesList.reduce((a, b) => a > b ? a : b)
                    : 0.0;

            final bestPR =
                processor.blowValuesList.isNotEmpty
                    ? processor.blowValuesList.reduce((a, b) => a + b) /
                        processor.blowValuesList.length
                    : 0.0;

            final duration = processor.blowDuration;
            final allValues = [
              ...processor.baseBlowValueList,
              ...processor.blowValuesList,
            ];

            final params = GeneratingResultParams(
              maxPressure: maxPR,
              bestPressure: bestPR,
              blowDuration: duration,
              blowValuesList: allValues,
            );

            // Navigate to your result screen properly
            context.pushReplacement(
              AppRoutes.generatingResultScreen,
              extra: params,
            );

            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder:
            //           (_) => Scaffold(
            //             appBar: AppBar(title: const Text("Blow Results")),
            //             body: Padding(
            //               padding: const EdgeInsets.all(16.0),
            //               child: Column(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: [
            //                   Text(
            //                     "✅ Blow Complete!",
            //                     style: Theme.of(context).textTheme.headlineLarge,
            //                   ),
            //                   const SizedBox(height: 20),
            //                   Text("Max Pressure: $maxPR"),
            //                   Text("Best Pressure: $bestPR"),
            //                   Text("Blow Duration: $duration ms"),
            //                   const SizedBox(height: 20),
            //                   Text("Captured Values: $allValues"),
            //                 ],
            //               ),
            //             ),
            //           ),
            //     ),
            //   );
          }

          if (state is ExhaleImproper) {
            showImproperExhale(
              context: context,
              tryAgainButtonClicked: () {},
              needHelpButtonCancel: () {},
            );
          }
        },
        child: BlocBuilder<ExhaleCubit, ExhaleState>(
          builder: (context, state) {
            if (state is ExhaleInProgress) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up, color: Colors.black),
                    ),
                  ],
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // // GIF
                        Stack(
                          children: [
                            SizedBox(
                              height: 350,
                              width: MediaQuery.of(context).size.width * 0.96,
                              child: Image.asset(
                                'assets/images/gif_images/exhale.gif',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed:
                                        () => showCancelTestDialog(
                                          context,
                                          () => context.pushReplacement(
                                            AppRoutes.usbDeviceConnectivity,
                                          ),
                                        ),
                                    icon: Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/images/common/closeicon.svg",
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.volume_up),
                                  ),
                                ],
                              ),
                            ),
                            if (state.progress > 0.2 && state.progress < 0.49)
                              Positioned(
                                bottom: 50,
                                left: 40,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Having trouble with exhale?\t",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF595959),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        child: Text(
                                          "Try practice test",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.mulish(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF308BF9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Instruction text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                              children: [
                                const TextSpan(
                                  text: "Exhale into device until scale turns ",
                                ),
                                TextSpan(
                                  text: "GREEN",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF3EAF58),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Stack(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              child: LinearProgressIndicator(
                                value: state.progress,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                backgroundColor: const Color(0xFFF3F3F3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  state.progress < 0.10
                                      ? Colors.grey
                                      : state.progress <
                                          (state.thresholdPercentage ?? 1) / 120
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ),
                            Positioned(
                              left:
                                  ((state.thresholdPercentage ?? 0) / 120) *
                                  MediaQuery.of(context).size.width,
                              top: 0,
                              bottom: 0,
                              child: Container(width: 2, color: Colors.black),
                            ),
                          ],
                        ),

                        Text(
                          state.infoText,
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            color:
                                state.progress < 0.10
                                    ? Colors.grey
                                    : state.progress <
                                        (state.thresholdPercentage ?? 1) / 120
                                    ? Colors.red
                                    : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Countdown timer
                        Column(
                          children: [
                            Text(
                              "${state.secondsRemaining}",
                              style: GoogleFonts.roboto(
                                fontSize: 40,
                                fontWeight: FontWeight.w400,
                                color:
                                    state.secondsRemaining <= 10
                                        ? Colors.red
                                        : Colors.black,
                              ),
                            ),
                            Text(
                              'sec',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color:
                                    state.secondsRemaining <= 10
                                        ? Colors.red
                                        : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is ExhaleError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    state.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
