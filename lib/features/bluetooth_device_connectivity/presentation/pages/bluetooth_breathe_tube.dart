import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/common/widgets/internet_connectivity_handler.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_breathe_tube_cubit/bluetooth_breathe_tube_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_breathe_tube_cubit/bluetooth_breathe_tube_state.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import 'bluetooth_calibration_screen.dart';

class BluetoothBreatheTube extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const BluetoothBreatheTube({super.key, required this.clientProfileModel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (ctx) => BluetoothBreatheTubeCubit(
            ctx.read<BluetoothRepository>(),
            AudioHelper(),
          ),
      child: BlocConsumer<BluetoothBreatheTubeCubit, BluetoothBreatheTubeState>(
        listener: (context, state) {
          final cubit = context.read<BluetoothBreatheTubeCubit>();

          if (state.isDialogShown) {
            // Disconnection Dialog
            showDeviceDisconnectedBox(
              context: context,
              onButtonPressed: () {
                cubit.dialogDismissed();
                cubit.disconnect();
                context.go(AppRoutes.clientDashboard);
              },
            );
          }

          if (state.isCompleted) {
            cubit.close();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RepositoryProvider<BluetoothRepository>.value(
                  value: context.read<BluetoothRepository>(), // or create(...) if none above
                  child:  BluetoothCalibrationScreen(clientProfileModel: clientProfileModel,),
                ),
              ),
            );
          }
        },

        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: InternetConnectivityHandler(
              onConnectivityChanged: (hasInternet) {
                context.read<BluetoothBreatheTubeCubit>().handleInternetChanged(
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
                            onPressed:
                                () => showCancelTestDialog(context, () {

                                  context.go(
                                    AppRoutes.clientDashboard,
                                    extra: clientProfileModel,
                                  );

                                  context
                                      .read<BluetoothBreatheTubeCubit>()
                                      .dialogDismissed();
                                }),
                            icon: SvgPicture.asset(
                              "assets/images/common/closeicon.svg",
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              context
                                  .read<BluetoothBreatheTubeCubit>()
                                  .audioHelper
                                  .toggleMute();
                            },
                            icon: BlocBuilder<
                              BluetoothBreatheTubeCubit,
                              BluetoothBreatheTubeState
                            >(
                              builder: (context, state) {
                                return Icon(
                                  context
                                          .read<BluetoothBreatheTubeCubit>()
                                          .audioHelper
                                          .isMuted
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
