import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart';
import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_new_state.dart';
import 'breathing_graph.dart';

class NewInhaleScreen extends StatelessWidget {
  final BluetoothInhaleCubitNewState state;
  const NewInhaleScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Hold constants
    const int totalHoldTime = 8;
    final holdRemaining = (totalHoldTime - state.holdSeconds).ceil().clamp(0, totalHoldTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: rh(context: context, px: 20)),

        // Main Header Text
        SizedBox(
          width: double.infinity,
          child: _buildMainTitle(context, holdRemaining),
        ),

        SizedBox(height: rh(context: context, px: 20)),

        // Sub-text Label
        SizedBox(
          width: double.infinity,
          child: Text(
            _buildSubTitle(holdRemaining),
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

        // Graph Section
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final safeH = (constraints.maxHeight <= 0)
                  ? rh(context: ctx, px: 300)
                  : constraints.maxHeight;

              return Center(
                child: BreathingTargetGraph(
                  currentReading: state.progress,
                  height: safeH,
                  targetMin: 20,
                  targetMax: 80,
                  hold: state.holdSeconds==1 ? false : state.holdStarted   ,
                  holdCounter: holdRemaining,
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

  Widget _buildMainTitle(BuildContext context, int holdRemaining) {
    final baseStyle = GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: rh(context: context, px: 25),
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -1,
    );

    // 1. Hold Phase Logic
    if (state.holdStarted) {
      if (holdRemaining > 3) {
        return Text("Hold your breath", textAlign: TextAlign.center, style: baseStyle);
      } else {
        return Text("Start exhaling in..", textAlign: TextAlign.center, style: baseStyle);
      }
    }

    // 2. Inhale Progress Logic
    if (state.inhaleNeedRunning) {
      final remainingMs = (state.inhaleNeedTotalMillis - (state.inBandSeconds * 1000).round())
          .clamp(0, state.inhaleNeedTotalMillis);
      final remainingSec = (remainingMs / 1000).ceil();

      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: "Keep the ball\nin range for "),
            TextSpan(
              text: "$remainingSec",
              style: const TextStyle(color: Color(0xFF308BF9)),
            ),
            const TextSpan(text: " seconds"),
          ],
        ),
      );
    }

    // 3. Default Start Logic
    return Text(
      "Inhale to move\nthe ball into range",
      textAlign: TextAlign.center,
      style: baseStyle,
    );
  }

  String _buildSubTitle(int holdRemaining) {
    if (state.holdStarted) {
      return holdRemaining > 3
          ? "Remove device from your mouth"
          : "Exhale through your Respyr device";
    }

    if (state.inhaleNeedRunning) {
      return "Inhale until timer ends";
    }

    return "Inhale through your Respyr device";
  }
}