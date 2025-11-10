import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/device_list.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/radar_animation.dart';

class DeviceSection extends StatelessWidget {
  final BluetoothConnectionState state;

  const DeviceSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (state.isScanning) {
      content = Center(
        child: Text(
          "Searching...",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (!state.isScanning && state.devices.isEmpty) {
      content = _buildNoDevice(context);
    } else {
      content = _buildDeviceList(context);
    }

    final validDeviceId =
        state.connectingDeviceId != null &&
        RegExp(r'^\d+$').hasMatch(state.connectingDeviceId!);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (!state.isConnected && state.isScanning)
                const RadarAnimation(color: Color(0xFF308BF9), size: 300),
              SvgPicture.asset(
                state.isConnected
                    ? "assets/images/device_connection/connected.svg"
                    : "assets/images/device_connection/bluetooth_disconnected.svg",
              ),

              if (state.devices.isNotEmpty && !state.isConnected)
                Positioned(
                  right: 110,
                  top: 110,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF308BF9),
                    radius: 20,
                    child: Text(
                      '${state.devices.length}',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),
          if (!state.isConnected) content,
          if (state.isConnected && validDeviceId)
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFD9D9D9),
                border: Border.all(color: const Color(0xFFB9B9B9)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SvgPicture.asset(
                    'assets/images/device_connection/device_id.svg',
                  ),
                  Text(
                    'Device Id:',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.10,
                      letterSpacing: -0.24,
                    ),
                  ),
                  Text(
                    'RESPYR${state.connectingDeviceId ?? ""}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.10,
                      letterSpacing: -0.24,
                    ),
                  ),
                ],
              ),
            ),

          if (state.isConnected)
            Text(
              'Device Connected',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 25,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
              ),
            ),
          const SizedBox(height: 30),
          if (!state.isConnected) DeviceList(state: state),
        ],
      ),
    );
  }

  Widget _buildNoDevice(BuildContext context) {
    return Column(
      children: [
        Text(
          'No Device Found',
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            context.read<BluetoothConnectionCubit>().startScan();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/images/device_connection/retry.svg"),
              const SizedBox(width: 5),
              Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF308BF9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceList(BuildContext context) {
    return Column(
      children: [
        Text(
          'Found ${state.devices.length} Devices',
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            context.read<BluetoothConnectionCubit>().startScan();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/images/device_connection/retry.svg"),
              const SizedBox(width: 5),
              Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF308BF9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
