import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';

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
      child: Scrollbar(
        thumbVisibility: true,
        radius: const Radius.circular(10),
        thickness: 6,
        child: ListView.separated(
          itemCount: state.devices.length,
          separatorBuilder: (_, index) {
            return SizedBox(height: 10);
          },
          itemBuilder: (_, i) {
            final d = state.devices[i];
            return InkWell(
              onTap:
                  () => context.read<BluetoothConnectionCubit>().connectById(
                d.id,
              ),
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
      ),
    );
  }
}