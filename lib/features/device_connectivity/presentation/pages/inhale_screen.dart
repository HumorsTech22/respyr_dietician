import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/core/services/usb_communication_service.dart';

import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/inhale_screen/inhale_cubit.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/inhale_screen/inhale_state.dart';

class InhaleScreen extends StatelessWidget {
  const InhaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = InhaleCubit(UsbCommunicationService(), AudioHelper());
        cubit.init();
        return cubit;
      },
      child: const _InhaleView(),
    );
  }
}

class _InhaleView extends StatelessWidget {
  const _InhaleView();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return BlocConsumer<InhaleCubit, InhaleState>(
      listenWhen:
          (prev, curr) =>
              prev.navigationToExhaleScreen != curr.navigationToExhaleScreen ||
              prev.dialogShown != curr.dialogShown,
      listener: (context, state) {
        if (state.dialogShown) {
          // ⚠️ Show disconnected popup (UI-level)
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text("Device Disconnected"),
                  content: const Text("The device has been disconnected."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: navigate back to dashboard if required
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
        }

        if (state.navigationToExhaleScreen) {
          // ⚡ Navigate to Exhale screen when cubit triggers
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => Scaffold(
                    body: Center(
                      child: Text(
                        "➡️ Exhale Screen (baseValue: ${state.lastExtractedValue})",
                      ),
                    ),
                  ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<InhaleCubit>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              state.isConnected
                  ? "USB device connected"
                  : "USB device not connected",
              style: GoogleFonts.mulish(
                fontSize: 15,
                color: state.isConnected ? Colors.green : Colors.red,
              ),
            ),
            actions: [
              IconButton(
                onPressed: cubit.toggleMute,
                icon: Icon(state.isMuted ? Icons.volume_off : Icons.volume_up),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Center(
                      child:
                          state.counter > 4
                              ? const SizedBox(
                                height: 350,
                                width: 375,
                                child: Image(
                                  image: AssetImage(
                                    'assets/gif_images/inhale.gif',
                                  ),
                                ),
                              )
                              : SvgPicture.asset("assets/inhale_hold.svg"),
                    ),
                    Positioned(
                      top: 10,
                      left: 20,
                      child: IconButton(
                        onPressed: () {
                          // Cancel test (UI responsibility)
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text("Cancel Test"),
                                  content: const Text(
                                    "Are you sure you want to cancel the test?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        cubit.stopAllProcesses();
                                        Navigator.pop(
                                          context,
                                        ); // back to dashboard
                                      },
                                      child: const Text("Yes"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("No"),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg_icons/close_icon.svg",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  state.counter > 4 ? 'Deep Inhale' : 'Hold',
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFA1A1A1),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '0${state.counter}',
                      style: GoogleFonts.roboto(
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'sec',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
