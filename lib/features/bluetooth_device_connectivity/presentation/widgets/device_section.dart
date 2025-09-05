import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
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

class DeviceList extends StatelessWidget {
  final BluetoothConnectionState state;

  const DeviceList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.devices.isEmpty) {
      return Container(
        height: 111,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Nearby devices will only be visible if you keep it on while connecting',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 15,
          ),
        ),
      );
    }

    return Container(
      height: 111,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView.separated(
        itemCount: state.devices.length,
        separatorBuilder: (_, index) {
          return SizedBox(height: 10);
        },
        itemBuilder: (_, i) {
          final d = state.devices[i];
          return InkWell(
            onTap:
                () =>
                    context.read<BluetoothConnectionCubit>().connectById(d.id),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: Icon(Icons.bluetooth, color: Color(0xFF308BF9)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name.isEmpty ? '(no name)' : d.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (state.connectingDeviceId == d.id &&
                        state.status == BluetoothConnectionStatus.connecting)
                      Text(
                        'Connecting...',
                        style: GoogleFonts.poppins(fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
