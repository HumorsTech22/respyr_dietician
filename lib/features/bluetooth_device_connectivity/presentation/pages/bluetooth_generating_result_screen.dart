import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit/bluetooth_generating_result_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit/bluetooth_generating_result_state.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class BluetoothGeneratingResultScreen extends StatelessWidget {
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;
  final List<double> blowValuesList;

  const BluetoothGeneratingResultScreen({
    super.key,
    required this.maxPressure,
    required this.bestPressure,
    required this.blowDuration,
    required this.blowValuesList,
  });

  @override
  Widget build(BuildContext context) {
    print("MaxPressure: $maxPressure");
    print("bestPressure: $bestPressure");
    print("BlowDuration: $blowDuration");
    print("BlowValueList: $blowValuesList");
    return BlocProvider(
      create:
          (_) => BluetoothGeneratingResultCubit(
            repo: context.read<BluetoothRepository>(),
            maxPressure: maxPressure,
            bestPressure: bestPressure,
            blowDuration: blowDuration,
            blowValuesList: blowValuesList,
          ),
      child: BlocConsumer<
        BluetoothGeneratingResultCubit,
        BluetoothGeneratingResultState
      >(
        listener: (context, state) {
          if (state.isDialogShown) {
            showDeviceDisconnectedBox(
              context: context,
              onButtonPressed: () {
                context
                    .read<BluetoothGeneratingResultCubit>()
                    .dialogDismissed();
                context.go(AppRoutes.dieitianDashboardPage);
              },
            );
          }

          if (state.navigateToResultScreen) {
            context.pushReplacement(AppRoutes.dietitianResultScreen);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed:
                            () => showCancelTestDialog(
                              context,
                              () => context.go(AppRoutes.dieitianDashboardPage),
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
                      _buildProgressIndicator(
                        1,
                        "Calculating your result",
                        state.completedSteps,
                      ),
                      _buildProgressIndicator(
                        2,
                        "Analyzing your result",
                        state.completedSteps,
                      ),
                      _buildProgressIndicator(
                        3,
                        "Generating your report",
                        state.completedSteps,
                      ),

                      const Spacer(),
                      const Image(
                        image: AssetImage(
                          "assets/images/gif_images/searching_file.gif",
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

  Widget _buildProgressIndicator(int step, String text, int completedSteps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (completedSteps == step)
                  const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF595959),
                      ),
                      strokeWidth: 3.0,
                    ),
                  ),
                SvgPicture.asset(
                  completedSteps > step
                      ? "assets/images/device_connection/verified.svg"
                      : "assets/images/device_connection/unverified.svg",
                  height: 25,
                  width: 25,
                ),
              ],
            ),
            const SizedBox(width: 30),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF595959),
              ),
            ),
          ],
        ),
        if (step < 3)
          SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 11),
                width: 3,
                decoration: BoxDecoration(
                  color:
                      completedSteps > step
                          ? const Color(0xFF3FAF58)
                          : const Color(0xFFE0E0E0),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
