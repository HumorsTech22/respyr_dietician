import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showBluetoothEnableDialog({
  required BuildContext context,
  required VoidCallback onButtonPressed,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  "assets/images/device_connection/bluetooth_disconnected.svg",
                  width: 280,
                  height: 280,
                ),
                Text(
                  'Turn on bluetooth',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'To connect your device to app make sure your bluetooth is on',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      onButtonPressed();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: const Color(0xFF308BF9),
                    ),
                    child: Text(
                      'Turn on bluetooth',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.10,
                        letterSpacing: 0.30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}
