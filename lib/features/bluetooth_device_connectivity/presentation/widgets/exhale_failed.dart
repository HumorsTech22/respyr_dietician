import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/test_failed_suggestion_item.dart';

import '../../../../core/size/get_height.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_state.dart';

class ExhaleFailed extends StatelessWidget {
  final BluetoothExhaleState state;
  final VoidCallback onStartAgain;

  const ExhaleFailed({
    super.key,
    required this.state,
    required this.onStartAgain,
  });

  bool _contains(String s, String q) => s.toLowerCase().contains(q.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final err = (state.error ?? "").trim();
    final e = err.toLowerCase();
    final isInhale = _contains(e, "inhaled") || _contains(e, "inhale");
    final isStopped = _contains(e, "stopped");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if(isInhale)...[
            Text(
              "Oops! You inhaled instead of exhaling.",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
          ]else...[
            Text(
              "Keep the ball in the range for longer",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
          ],

          const Spacer(),

          if (isStopped) ...[
            Text(
              "Here’s how to get it right",
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 18),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.30),
                letterSpacing: rh(context: context, px: -0.36),
              ),
            ),
            SizedBox(height: rh(context: context, px: 24)),
            TestFailedSuggestionItem(
              step: "1",
              text: "Sit comfortably upright with your feet flat on the ground and shoulders back.",
            ),
            SizedBox(height: rh(context: context, px: 24)),
            TestFailedSuggestionItem(
              step: "2",
              text: "Place only the tip of the Respyr device into your mouth.",
            ),
            SizedBox(height: rh(context: context, px: 24)),
            TestFailedSuggestionItem(
              step: "3",
              text: "Keep your breathing slow, steady, and gentle throughout the test.",
            ),
          ],
          SizedBox(height: rh(context: context, px: 45)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF308BF9),
                padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 18)),
                elevation: 0,
              ),
              child: Text(
                "START AGAIN",
                style: GoogleFonts.poppins(
                  fontSize: rh(context: context, px: 15),
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: rh(context: context, px: 1.10),
                  letterSpacing: rh(context: context, px: 0.30),
                ),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 19)),
        ],
      ),
    );
  }
}