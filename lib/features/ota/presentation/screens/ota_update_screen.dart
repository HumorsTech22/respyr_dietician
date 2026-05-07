import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:respyr_dietitian/features/ota/bloc/ota_update_cubit.dart';
import 'package:respyr_dietitian/features/ota/bloc/ota_update_state.dart';

class OtaUpdateScreen extends StatelessWidget {
  const OtaUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtaUpdateCubit(),
      child: const _OtaUpdateBody(),
    );
  }
}

class _OtaUpdateBody extends StatelessWidget {
  const _OtaUpdateBody();

  String _deviceName(ScanResult result) {
    final advName = result.advertisementData.advName.trim();
    final platformName = result.device.platformName.trim();

    if (advName.isNotEmpty) return advName;
    if (platformName.isNotEmpty) return platformName;
    return "Unknown Device";
  }

  Color _statusColor(OtaUpdateState state) {
    final status = state.status.toLowerCase();

    if (status.contains("failed") || status.contains("abort")) {
      return Colors.red;
    }
    if (status.contains("complete")) {
      return Colors.green;
    }
    if (state.isConnected) {
      return Colors.green;
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTA Update"),
      ),
      body: BlocBuilder<OtaUpdateCubit, OtaUpdateState>(
        builder: (context, state) {
          final cubit = context.read<OtaUpdateCubit>();
          final progress = state.progressTotal > 0
              ? state.progressCurrent / state.progressTotal
              : 0.0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusColor(state).withOpacity(0.08),
                    border: Border.all(color: _statusColor(state)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.status,
                    style: TextStyle(
                      color: _statusColor(state),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Connection: ${state.isConnected ? "Connected" : "Disconnected"}",
                  style: TextStyle(
                    color: state.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.connectedDeviceName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text("Device: ${state.connectedDeviceName}"),
                  Text("ID: ${state.connectedDeviceId}"),
                ],

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.isScanning
                            ? null
                            : () {
                          cubit.startScan();
                        },
                        child: Text(
                          state.isScanning ? "Scanning..." : "Scan Respyr",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (state.isConnected && !state.isRunningOta)
                            ? () {
                          cubit.startOtaFromAssets(
                            "assets/firmware/SLOTB_MAIN.ino.bin",
                          );
                        }
                            : null,
                        child: Text(
                          state.isRunningOta ? "Running OTA..." : "Start OTA",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (state.progressTotal > 0) ...[
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text("${state.progressCurrent}/${state.progressTotal}"),
                  Text("Elapsed: ${state.elapsedSeconds}s"),
                  Text(
                    "Speed: ${state.speedKbPerSec.toStringAsFixed(2)} KB/s",
                  ),
                ],

                const SizedBox(height: 16),

                const Text(
                  "Respyr Devices",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: state.devices.isEmpty
                      ? Center(
                    child: Text(
                      state.isScanning
                          ? "Scanning..."
                          : "No Respyr device found",
                    ),
                  )
                      : ListView.separated(
                    itemCount: state.devices.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = state.devices[index];
                      return ListTile(
                        title: Text(_deviceName(item)),
                        subtitle: Text(item.device.remoteId.str),
                        trailing: ElevatedButton(
                          onPressed: () {
                            cubit.connect(item);
                          },
                          child: const Text("Connect"),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Received",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.receivedText.isEmpty ? "-" : state.receivedText,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Logs",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 180,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      state.logText.isEmpty ? "-" : state.logText,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isConnected
                        ? () {
                      cubit.disconnect();
                    }
                        : null,
                    child: const Text("Disconnect"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}