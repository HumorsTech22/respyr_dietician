import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/terminal/cubit/ble_terminal_cubit.dart';

class BleTerminalScreen extends StatefulWidget {
  const BleTerminalScreen({super.key});

  @override
  State<BleTerminalScreen> createState() => _BleTerminalScreenState();
}

class _BleTerminalScreenState extends State<BleTerminalScreen> {

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  Color logColor(String log) {
    if (log.startsWith("RX")) return Colors.lightGreenAccent;
    if (log.startsWith("TX")) return Colors.orangeAccent;
    if (log.contains("CONNECTED")) return Colors.green;
    if (log.contains("DISCONNECTED")) return Colors.redAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: BlocProvider(
        create: (_) =>
        BleTerminalCubit(context.read<BluetoothRepository>())..init(),

        child: Builder(
          builder: (context) {

            return Scaffold(

              backgroundColor: Colors.black,

              appBar: AppBar(
                backgroundColor: Colors.black,
                title: const Text(
                  "BLE TERMINAL",
                  style: TextStyle(
                    fontFamily: "monospace",
                    color: Colors.greenAccent,
                  ),
                ),

                actions: [

                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.greenAccent),
                    onPressed: () {
                      context.read<BleTerminalCubit>().scan();
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () {
                      context.read<BleTerminalCubit>().clearLogs();
                    },
                  ),
                ],
              ),

              body: Column(
                children: [

                  /// DEVICE LIST
                  Container(
                    height: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.greenAccent),
                      ),
                    ),

                    child: BlocBuilder<BleTerminalCubit, BleTerminalState>(
                      builder: (context, state) {

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.devices.length,
                          itemBuilder: (context, index) {

                            final device = state.devices[index];

                            if (!device.name.contains("Respyr")) {
                              return const SizedBox();
                            }

                            return GestureDetector(
                              onTap: () {
                                context.read<BleTerminalCubit>().connect(device);
                              },

                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 10),

                                padding: const EdgeInsets.all(10),

                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.greenAccent,
                                  ),
                                ),

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    Text(
                                      device.name,
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontFamily: "monospace",
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      device.id,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 10,
                                        fontFamily: "monospace",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  /// TERMINAL OUTPUT
                  Expanded(
                    child: BlocListener<BleTerminalCubit, BleTerminalState>(
                      listenWhen: (p, c) => p.logs.length != c.logs.length,
                      listener: (_, __) => scrollToBottom(),

                      child: BlocBuilder<BleTerminalCubit, BleTerminalState>(
                        builder: (context, state) {

                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(10),
                            itemCount: state.logs.length,
                            itemBuilder: (_, i) {

                              final log = state.logs[i];

                              return Text(
                                log,
                                style: TextStyle(
                                  color: logColor(log),
                                  fontFamily: "monospace",
                                  fontSize: 14,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  /// COMMAND INPUT
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.greenAccent),
                      ),
                    ),

                    child: Row(
                      children: [

                        const Text(
                          "> ",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: "monospace",
                            fontSize: 16,
                          ),
                        ),

                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: "monospace",
                            ),

                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "type command",
                              hintStyle: TextStyle(color: Colors.white38),
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.greenAccent,
                          ),

                          onPressed: () {

                            final text = controller.text.trim();

                            context.read<BleTerminalCubit>().send(text);

                            controller.clear();
                          },
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.link_off,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            context.read<BleTerminalCubit>().disconnect();
                          },
                        ),
                      ],
                    ),
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