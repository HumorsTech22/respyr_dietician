import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_state.dart';
import 'breathing_graph.dart';

class NewExhaleScreen2 extends StatefulWidget {
  final BluetoothExhaleState state;
  const NewExhaleScreen2({super.key, required this.state});

  @override
  State<NewExhaleScreen2> createState() => _NewExhaleScreen2State();
}

class _NewExhaleScreen2State extends State<NewExhaleScreen2> {
  final ValueNotifier<double> _reading = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _reading.value = widget.state.progress;
  }

  @override
  void didUpdateWidget(covariant NewExhaleScreen2 oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ only update the notifier (no full rebuild needed for graph)
    if (oldWidget.state.progress != widget.state.progress) {
      _reading.value = widget.state.progress;
    }
  }

  @override
  void dispose() {
    _reading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final bool isHolding = state.exhaleStarted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: rh(context: context, px: 20)),

        /// TITLE
        SizedBox(
          width: double.infinity,
          child: _buildMainTitle(context, state),
        ),

        SizedBox(height: rh(context: context, px: 20)),

        /// SUB TITLE
        SizedBox(
          width: double.infinity,
          child: Text(
            isHolding
                ? "Exhale until timer ends"
                : "Exhale through your Respyr device",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 15),
              fontWeight: FontWeight.w400,
              height: 1.30,
              letterSpacing: -0.30,
            ),
          ),
        ),

        SizedBox(height: rh(context: context, px: 22)),

        /// GRAPH
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final safeH = (constraints.maxHeight <= 0)
                  ? rh(context: ctx, px: 300)
                  : constraints.maxHeight;

              return Center(
                child: RepaintBoundary( // ✅ isolates paint work
                  child: BreathingTargetGraph(
                    reading: _reading, // ✅ changed
                    height: safeH,
                    targetMin: 40,
                    targetMax: 80,
                    hold: false,
                    holdCounter: 0,
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: rh(context: context, px: 51)),
        IconButton(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.speaker),
        ),
        SizedBox(height: rh(context: context, px: 52)),
      ],
    );
  }

  Widget _buildMainTitle(BuildContext context, BluetoothExhaleState state) {
    final baseStyle = GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: rh(context: context, px: 25),
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -1,
    );

    if (!state.exhaleStarted) {
      return Text(
        "Exhale to move\nthe ball into range",
        textAlign: TextAlign.center,
        style: baseStyle,
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: "Keep the ball in\nrange for "),
          TextSpan(
            text: "${state.holdSecondsLeft}",
            style: const TextStyle(color: Color(0xFF308BF9)),
          ),
          const TextSpan(text: " seconds"),
        ],
      ),
    );
  }
}
