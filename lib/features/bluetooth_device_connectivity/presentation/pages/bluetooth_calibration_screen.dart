import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/core/audio/audio_cubit.dart';
import 'package:respyr_dietitian/core/audio/audio_state.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository_impl.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_state.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/calibration/calibration_cubit.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class BluetoothCalibrationScreen extends StatelessWidget {
  const BluetoothCalibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> calibrationGifs = [
      "assets/images/gif_images/cal0.gif",
      "assets/images/gif_images/cal1.gif",
      "assets/images/gif_images/cal2.gif",
      "assets/images/gif_images/cal3.gif",
      "assets/images/gif_images/cal4.gif",
    ];

    final List<String> progressMessage = [
      "Cleaning inner\nChamber of Device",
      "Verifying Cleanlliness",
      "Initialing Calibration",
      "Activating Sensors",
      "Getting Device Ready",
    ];

    return BlocProvider(
      create: (_) {
        final cubit = BluetoothCalibrationCubit(
          BluetoothRepositoryImpl(UuidBluetoothManager()),
          AudioHelper(),
        );
        cubit.init();
        return cubit;
      },
      child: BlocListener<BluetoothCalibrationCubit, BluetoothCalibrationState>(
        listenWhen:
            (prev, curr) =>
                prev.navigateToInhaleScreen != curr.navigateToInhaleScreen ||
                prev.textError != curr.textError ||
                prev.isDialogShown != curr.isDialogShown,
        listener: (context, state) {
          if (state.navigateToInhaleScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<CalibrationCubit>().resetNavigationFlag();
              context.push(AppRoutes.inhaleScreen);
            });
          }

          if (state.textError != null) {
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text("Error"),
                    content: Text(state.textError!),
                  ),
            );
          }

          if (state.isDialogShown) {
            // 👇 same disconnection handler as in BreatheTubeScreen
            showDeviceDisconnectedBox(
              context: context,
              onButtonPressed:
                  () => context.read<BluetoothCalibrationCubit>().stop(),
            );
          }
        },
        child:
            BlocBuilder<BluetoothCalibrationCubit, BluetoothCalibrationState>(
              builder: (context, state) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    child: Column(
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
                        Image(
                          image: ResizeImage(
                            AssetImage(
                              state.completedSteps > 4
                                  ? calibrationGifs[4]
                                  : calibrationGifs[state.completedSteps],
                            ),
                            width: 200,
                            height: 200,
                          ),
                        ),
                        Text(
                          state.completedSteps > 4
                              ? progressMessage[4]
                              : progressMessage[state.completedSteps],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF595959),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (i) => _buildProgressIndicator(i, context, state),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}

Widget _buildProgressIndicator(
  int step,
  BuildContext context,
  BluetoothCalibrationState state,
) {
  final bool isCurrentStep = state.completedSteps == step;
  final bool isCompleted = state.completedSteps > step;

  final double screenWidth = MediaQuery.of(context).size.width;
  final double circleSize = screenWidth * 0.06;
  final double lineWidth = screenWidth * 0.12;

  return Row(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          if (isCurrentStep)
            SizedBox(
              height: circleSize,
              width: circleSize,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF595959)),
                strokeWidth: 3.0,
              ),
            ),
          SvgPicture.asset(
            isCompleted
                ? "assets/images/device_connection/verified.svg"
                : "assets/images/device_connection/unverified.svg",
            height: circleSize,
            width: circleSize,
          ),
        ],
      ),
      if (step < 4)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4,
          width: lineWidth,
          decoration: BoxDecoration(
            color: isCompleted ? Color(0xFF3FAF58) : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
    ],
  );
}
