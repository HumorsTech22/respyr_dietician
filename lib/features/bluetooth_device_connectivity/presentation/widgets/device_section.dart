import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/battery_indicator_widget.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/device_list.dart';

import '../../../../common/widgets/assets_video_play.dart';

class DeviceSection extends StatelessWidget {
  final BluetoothConnectionState state;

  const DeviceSection({super.key, required this.state});

  bool get isConnected =>
      state.isConnected || state.status == BluetoothConnectionStatus.connected;

  bool get isScanning =>
      state.isScanning || state.status == BluetoothConnectionStatus.scanning;

  bool get hasDevices => state.devices.isNotEmpty;

  bool get validDeviceId =>
      state.connectingDeviceId != null &&
          RegExp(r'^\d+$').hasMatch(state.connectingDeviceId!);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 82),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildTopVisualSmooth(),
        ),
        if (!isConnected) _buildContent(context),
        if (isConnected) ...[
          const SizedBox(height: 20),
          if (validDeviceId)
            _buildDeviceInfo()
          else
            Text(
              "Checking battery info...",
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.24,
              ),
            ),
          const SizedBox(height: 30),
          Text(
            "Device Connected",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (!isConnected) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DeviceList(state: state),
          ),
        ],
      ],
    );
  }

  Widget _buildTopVisualSmooth() {
    final Widget child = _buildTopVisualWithThumbnailFallback();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: SizedBox(
        key: ValueKey<String>(_topVisualKey()),
        width: double.infinity,
        child: child,
      ),
    );
  }

  String _topVisualKey() {
    if (isConnected) return "connected";
    if (isScanning) return "scanning";
    return "not_connected";
  }

  Widget _buildTopVisualWithThumbnailFallback() {
    const thumb =
        "assets/images/device_connection/new_device_not_connected.png";

    if (isConnected) {
      return Image.asset(
        "assets/images/device_connection/new_device_connected.png",
        fit: BoxFit.contain,
      );
    }

    if (isScanning) {
      return Stack(
        alignment: Alignment.center,
        children: const [
          Image(
            image: AssetImage(thumb),
            fit: BoxFit.contain,
          ),
          AssetVideoWidget(
            videoPath: 'assets/images/device_connection/device_scanning.mp4',
            thumbnailPath: thumb,
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: const [
        Image(
          image: AssetImage(thumb),
          fit: BoxFit.contain,
        ),
        AssetVideoWidget(
          videoPath:
          'assets/images/device_connection/device_not_connected_video.mp4',
          thumbnailPath: thumb,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isScanning) {
      return Center(
        child: Text(
          "Finding...",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (!hasDevices) {
      return _buildNoDevice(context);
    }

    return _buildDeviceList(context);
  }

  Widget _buildDeviceInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/images/device_connection/device_id.svg'),
        const SizedBox(width: 4),
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
        const SizedBox(width: 4),
        Text(
          'RESPYR${state.connectingDeviceId}',
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.10,
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(width: 10),
        if ((state.batteryPercentage ?? 0) > 0)
          BatteryIconWidget(
            batteryPercentage: state.batteryPercentage!,
          ),
      ],
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
        _retryButton(context),
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
        _retryButton(context),
      ],
    );
  }

  Widget _retryButton(BuildContext context) {
    return InkWell(
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
    );
  }
}
