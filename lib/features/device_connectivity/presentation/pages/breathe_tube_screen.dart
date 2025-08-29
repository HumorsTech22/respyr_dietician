import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/common/widgets/internet_connectivity_handler.dart';
import 'package:respyr_dietitian/core/audio/audio_cubit.dart';
import 'package:respyr_dietitian/core/audio/audio_state.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/breathe_tube/breathe_tube_cubit.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/breathe_tube/breathe_tube_state.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/widgets/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/widgets/disconnection_dialog.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class BreatheTubeScreen extends StatelessWidget {
  const BreatheTubeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BreatheTubeCubit(UsbCommunicationService(), AudioHelper()),
      child: BlocConsumer<BreatheTubeCubit, BreatheTubeState>(
        listener: (context, state) {
          if (state.isDialogShown) {
            showDeviceDisconnectedBox(
              context: context,
              onButtonPressed:
                  () => context.read<BreatheTubeCubit>().cancelTest(),
            );
          }
          if (state.isTestCancelled) {
            context.pushReplacement(AppRoutes.profileInfoScreen);
          }
          if (state.isCompleted) {
            context.pushReplacement(AppRoutes.calibrationScreen);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: InternetConnectivityHandler(
              onConnectivityChanged: (hasInternet) {
                context.read<BreatheTubeCubit>().handleInternetChanged(
                  hasInternet,
                );
              },
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => showCancelTestDialog(context),
                            icon: SvgPicture.asset(
                              "assets/images/common/closeicon.svg",
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              context.read<AudioCubit>().toggleMute();
                            },
                            icon: BlocBuilder<AudioCubit, AudioState>(
                              builder: (context, audioState) {
                                return Icon(
                                  audioState.isMuted
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 80),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Place the mouth tube in the slot",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.mulish(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF595959),
                          ),
                        ),
                      ),
                      Image.asset("assets/images/gif_images/mouth_tube.gif"),
                      SizedBox(height: 50),
                      LinearProgressIndicator(
                        value: state.progress,
                        backgroundColor: const Color(0xFFE0E0E0),
                        color: Color(0xFF308BF9),
                        minHeight: 15,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading... ${(state.progress * 100).toInt()}%',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF308BF9),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
