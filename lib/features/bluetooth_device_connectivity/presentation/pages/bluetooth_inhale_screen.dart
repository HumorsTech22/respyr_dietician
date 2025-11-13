import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/exhale_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_inhale_cubit/bluetooth_inhale_cubit.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_inhale_cubit/bluetooth_inhale_state.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class BluetoothInhaleScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const BluetoothInhaleScreen({super.key, required this.clientProfileModel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (ctx) => BluetoothInhaleCubit(
            ctx.read<BluetoothRepository>(),
            AudioHelper(),
          ),
      child: _BluetoothInhaleView(clientProfileModel: clientProfileModel),
    );
  }
}

class _BluetoothInhaleView extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const _BluetoothInhaleView({required this.clientProfileModel});

  Future<bool> showCancelTestDialogBox(BuildContext context) async {
    bool didCancel = false;

    showCancelTestDialog(context, () async {
      context.read<BluetoothInhaleCubit>().sendAbort();

      context.go(AppRoutes.clientDashboard, extra: clientProfileModel);
      context.read<BluetoothInhaleCubit>().dialogDismissed();
      await context.read<BluetoothInhaleCubit>().setCancelOrDisconnectFlag();
    });

    return didCancel;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await showCancelTestDialogBox(context);

          if (shouldExit) {}
        }
      },
      child: BlocConsumer<BluetoothInhaleCubit, BluetoothInhaleState>(
        listenWhen:
            (prev, curr) =>
                prev.isDialogShown != curr.isDialogShown ||
                prev.navigateToExhaleScreen != curr.navigateToExhaleScreen,
        listener: (context, state) {
          final cubit = context.read<BluetoothInhaleCubit>();
          if (state.isDialogShown) {
            showDeviceDisconnectedBox(
              context: context,
              onButtonPressed: () async {
                context.pop();
                await cubit.setCancelOrDisconnectFlag();
                cubit.dialogDismissed();

                context.go(
                  AppRoutes.clientDashboard,
                  extra: clientProfileModel,
                );
              },
            ).then((_) {
              cubit.dialogDismissed();
            });
          }

          if (state.navigateToExhaleScreen &&
              state.lastExtractedValue != null) {
            // context.pushReplacement(
            //   AppRoutes.bluetoothExhaleScreen,
            //   extra: state.lastExtractedValue!,
            // );
            // Where you previously had Navigator.push
            context.pushReplacement(
              AppRoutes.bluetoothExhaleScreen,
              extra: ExhaleScreenParams(
                clientProfileModel: clientProfileModel,
                baseValue: state.lastExtractedValue ?? '',
              ),
            );
          }
        },
        buildWhen:
            (prev, curr) =>
                prev.counter != curr.counter ||
                prev.isBluetoothConnected != curr.isBluetoothConnected,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Center(
                        child:
                            state.counter > 4
                                ? Image.asset(
                                  'assets/images/gif_images/inhale.gif',
                                  height: 350,
                                  width: 375,
                                )
                                : SvgPicture.asset(
                                  "assets/images/device_connection/inhale_hold.svg",
                                ),
                      ),
                      Positioned(
                        top: 10,
                        left: 20,
                        child: IconButton(
                          onPressed: () => showCancelTestDialogBox(context),
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
      ),
    );
  }
}
