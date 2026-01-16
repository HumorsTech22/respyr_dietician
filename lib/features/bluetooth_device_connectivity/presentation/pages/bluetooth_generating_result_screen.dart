import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/generating_result_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/result_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit/bluetooth_generating_result_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit/bluetooth_generating_result_state.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import 'package:simple_horizontal_calendar/utils/app_color.dart';

import '../../../../common/dialogs/floating_message.dart';
import '../../../../common/widgets/battery_indicator_widget.dart';
import '../../../../core/battery/device_battery_manager.dart';

class BluetoothGeneratingResultScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;
  final List<double> blowValuesList;

  final double minRange;
  final double maxRange;

  const BluetoothGeneratingResultScreen({
    super.key,
    required this.maxPressure,
    required this.bestPressure,
    required this.blowDuration,
    required this.blowValuesList,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  Future<bool> showCancelTestDialogBox(BuildContext context) async {
    bool didCancel = false;

    showCancelTestDialog(context, () async {
      context.read<BluetoothGeneratingResultCubit>().sendAbort();
      await context
          .read<BluetoothGeneratingResultCubit>();

      context.go(AppRoutes.clientDashboard, extra: clientProfileModel);
      context.read<BluetoothGeneratingResultCubit>().dialogDismissed();
    });

    return didCancel;
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => BluetoothGeneratingResultCubit(
            repo: context.read<BluetoothRepository>(),
            maxPressure: maxPressure,
            bestPressure: bestPressure,
            blowDuration: blowDuration,
            blowValuesList: blowValuesList,
            clientProfileModel: clientProfileModel,
            repository: context.read<GeneratingResultRepository>(), dietPlanStrategyModel: dietPlanStrategyModel, minRange: minRange, maxRange: maxRange,
          ),
      child: BlocConsumer<
        BluetoothGeneratingResultCubit,
        BluetoothGeneratingResultState
      >(
        listener: (context, state) async {
          // ✅ 1) TIMEOUT should be checked FIRST (always)
          if (state.isTimedOut) {
            print("Timed out");

            return;
          }

          // ✅ 2) disconnected dialog
          if (state.isDialogShown) {
            showDeviceDisconnectedBox(
              context: context,
              onButtonPressed: () async {
                context.read<BluetoothGeneratingResultCubit>().dialogDismissed();
                await context.read<BluetoothGeneratingResultCubit>();
                context.push(AppRoutes.clientDashboard, extra: clientProfileModel);
              },
            );
          }

          // ✅ 3) navigate to result
          if (state.navigateToResultScreen) {


            context.read<BluetoothGeneratingResultCubit>().sendAbort();
            FloatingMessage.show(context, message: "Device turning off");
            context.read<BluetoothGeneratingResultCubit>().resetNavigationFlag();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.go(
                AppRoutes.dietitianResultScreen,
                extra: ResultScreenParams(
                  result: state.dietitianResult!,
                  clientProfileModel: clientProfileModel,
                ),
              );
            });
          }
        },

        builder: (context, state) {
          return PopScope(
            canPop: false,
            // onPopInvokedWithResult: (didPop, result) async {
            //   if (!didPop) {
            //     final shouldExit = await showCancelTestDialogBox(context);
            //
            //     if (shouldExit) {}
            //   }
            // },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                leading: SizedBox.shrink(),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Row(),
                    Spacer(),
                    Text(
                      "Generating result...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 34,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -2.04,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: AspectRatio(
                        aspectRatio: 1, // perfect circle
                        child: CircularProgressIndicator(
                          color: const Color(0xFF308BF9),
                          backgroundColor: const Color(0xFFE1E6ED),
                        ),
                      ),
                    ),

                    Spacer(flex:3 ,),



                    // Text(
                    //   state.completedSteps > 4
                    //       ? progressMessage[4]
                    //       : progressMessage[state.completedSteps],
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.roboto(
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w400,
                    //     color: Color(0xFF595959),
                    //   ),
                    // ),
                    // Text(
                    //   state.showPleaseWaitMessage
                    //       ? "Please wait… still searching for inhale signal"
                    //       : "",
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.roboto(
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w400,
                    //     color: Color(0xFF595959),
                    //   ),
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: List.generate(
                    //     5,
                    //     (i) => _buildProgressIndicator(i, context, state),
                    //   ),
                    // ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                  ],
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
