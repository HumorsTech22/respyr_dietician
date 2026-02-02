
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_state.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import '../../../../common/dialogs/exhale_timeout_dialog.dart';


class BluetoothCalibrationScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  const BluetoothCalibrationScreen({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel, required this.minRange, required this.maxRange,
  });

  @override
  Widget build(BuildContext context) {


    Future<bool> showCancelTestDialogBox(BuildContext context, bool allSignalSent) async {
      bool didCancel = false;

      showCancelTestDialog(context, () async {
      if(allSignalSent)  context.read<BluetoothCalibrationCubit>().sendAbort();
        context.go(
          AppRoutes.clientDashboard,
          extra: clientProfileModel,
        );

        context.read<BluetoothCalibrationCubit>().dialogDismissed();
      });

      return didCancel;
    }


    void navigateToDashboard(){
      context.go(AppRoutes.clientDashboard, extra: clientProfileModel);
      context.read<BluetoothCalibrationCubit>().dialogDismissed();
    }



    return BlocProvider(
      create:
          (ctx) => BluetoothCalibrationCubit(
        ctx.read<BluetoothRepository>(),
        AudioHelper(),
      ),

      child: BlocListener<
          BluetoothCalibrationCubit,
          BluetoothCalibrationState
      >(
        listenWhen:
            (prev, curr) =>
        prev.navigateToInhaleScreen != curr.navigateToInhaleScreen ||
            prev.textError != curr.textError ||
            prev.isDialogShown != curr.isDialogShown ||
            prev.isTimeOver != curr.isTimeOver,
        listener: (context, state) {
          final cubit = context.read<BluetoothCalibrationCubit>();
          if (state.navigateToInhaleScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {cubit.stopScreenOperation();
            context.go(
              AppRoutes.bluetoothInhaleScreen,
              extra: {
                "client" : clientProfileModel,
                "strategy" : dietPlanStrategyModel,
                "min_range" : minRange,
                "max_range" : maxRange,
              },
            );
            });
          }

          if(state.isTimeOver && !state.navigateToInhaleScreen){
            context.read<BluetoothCalibrationCubit>().stopScreenOperation();


            showExhaleSessionTimeOutDialog(
                context: context,
                onButtonPressed: () {
                  if(state.allSignalSent) {  context.read<BluetoothCalibrationCubit>().sendAbort();}
                  navigateToDashboard();
                },
                message: "Session timed out",
                description: "No response was received from the device. Please restart the test."
            );

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
            showDeviceDisconnectedBox(
              context: context,
              onButtonPressed: () {
                cubit.dialogDismissed();
                context.pop();
                cubit.disconnect();

                context.go(
                  AppRoutes.clientDashboard,
                  extra: clientProfileModel,
                );
              },
            ).then((_) {
              context.read<BluetoothCalibrationCubit>().dialogDismissed();
            });
          }
        },
        child: BlocBuilder<
            BluetoothCalibrationCubit,
            BluetoothCalibrationState
        >(
          builder: (context, state) {




            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {

                if (!didPop) {
                  if(state.isTimeOver && !state.navigateToInhaleScreen){
                    if(state.allSignalSent) {  context.read<BluetoothCalibrationCubit>().sendAbort();}
                    navigateToDashboard();
                    return;
                  }

                  final shouldExit = await showCancelTestDialogBox(context,state.allSignalSent);
                  if (shouldExit) {

                  }
                }
              },

              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  leading: IconButton(
                    onPressed: () => showCancelTestDialogBox(context, state.allSignalSent),
                    icon: SvgPicture.asset(
                      "assets/images/common/closeicon.svg",
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Row(),
                      Spacer(),
                      Text("Please wait...${state.remainingSeconds}",
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
      ),
    );
  }
}


