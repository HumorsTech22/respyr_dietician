import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/common/dialogs/bluetooth_enable_dialog.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/device_section.dart';


import 'bluetooth_breathe_tube.dart';

class BluetoothDeviceConnectivity extends StatelessWidget {

  final ClientProfileModel clientProfileModel;
  const BluetoothDeviceConnectivity({super.key, required this.clientProfileModel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (ctx) =>
              BluetoothConnectionCubit(ctx.read<BluetoothRepository>())..init(),
      child:  _BluetoothDeviceConnectivityView(clientProfileModel:clientProfileModel,),
    );
  }
}

class _BluetoothDeviceConnectivityView extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const _BluetoothDeviceConnectivityView({required this.clientProfileModel});

  @override
  State<_BluetoothDeviceConnectivityView> createState() =>
      __BluetoothDeviceConnectivityViewState();
}

class __BluetoothDeviceConnectivityViewState
    extends State<_BluetoothDeviceConnectivityView> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fbp.BluetoothAdapterState>(
      stream: fbp.FlutterBluePlus.adapterState,
      initialData: fbp.BluetoothAdapterState.unknown,
      builder: (context, snapshot) {
        final adapterState = snapshot.data;

        if (adapterState == fbp.BluetoothAdapterState.unknown) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF308BF9)),
            ),
          );
        }

        if (adapterState != fbp.BluetoothAdapterState.on && !_dialogShown) {
          _dialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showBluetoothEnableDialog(
              context: context,
              onButtonPressed: () {
                fbp.FlutterBluePlus.turnOn();
              },
            ).then((_) {
              _dialogShown = false;
            });
          });
        }

        if (adapterState == fbp.BluetoothAdapterState.on && _dialogShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            _dialogShown = false;
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Connect Device',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 34,
                fontWeight: FontWeight.w400,
                letterSpacing: -2.04,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: SvgPicture.asset("assets/images/common/closeicon.svg"),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          backgroundColor: Colors.white,
          body: BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
            builder: (context, state) {
              if (adapterState != fbp.BluetoothAdapterState.on) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/images/device_connection/bluetooth_disconnected.svg",
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Bluetooth is Off',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please enable Bluetooth to connect a device',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return DeviceSection(state: state);
            },
          ),

          bottomNavigationBar: SafeArea(
            top: false,
            child:
                BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (state.isConnected &&
                                          state.connectingDeviceId != null)
                                      ? () {

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => RepositoryProvider<BluetoothRepository>.value(
                                          value: context.read<BluetoothRepository>(), // or create(...) if none above
                                          child:  BluetoothBreatheTube(clientProfileModel: widget.clientProfileModel,),
                                        ),
                                      ),
                                    );

                                  }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 16,
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                backgroundColor:
                                    state.isConnected
                                        ? const Color(0xFF308BF9)
                                        : const Color(0xFFD9D9D9),
                              ),
                              child: Text(
                                'Start',
                                style: GoogleFonts.poppins(
                                  color:
                                      state.isConnected
                                          ? Colors.white
                                          : const Color(0xFF959595),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Visibility(
                            visible: false,
                            child: GestureDetector(
                              onTap: () {
                                // context.push(
                                //   AppRoutes.issueWithConnectionScreen,
                                // );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25.5),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFC7C6CE),
                                  ),
                                ),
                                child: Text(
                                  'issue with connection?',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        );
      },
    );
  }
}
