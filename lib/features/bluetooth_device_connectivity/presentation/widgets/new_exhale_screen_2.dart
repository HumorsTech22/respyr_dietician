import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_state.dart';
import 'breathing_graph.dart';

class NewExhaleScreen2 extends StatelessWidget {
  final BluetoothExhaleState state;
  const NewExhaleScreen2({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: rh(context: context, px: 20)),
        SizedBox(
          width: double.infinity,
          child: _buildMainTitle(context, 1),
        ),
        SizedBox(height: rh(context: context, px: 20)),

        SizedBox(height: rh(context: context, px: 20)),

        SizedBox(
          width: double.infinity,
          child: Text(
            "Exhale through your Respyr device",
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
                  hold: false,
                  holdCounter: 0,
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

    if (!state.exhaleStarted) {
      // final remainingMs = (state.inhaleNeedTotalMillis - (state.inBandSeconds * 1000).round())
      //     .clamp(0, state.inhaleNeedTotalMillis);
      // final remainingSec = (remainingMs / 1000).ceil();

      int remainingSec= 1;

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
      "Exhale to move\nthe ball into range",
      textAlign: TextAlign.center,
      style: baseStyle,
    );
  }
}
