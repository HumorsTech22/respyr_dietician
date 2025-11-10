import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showExhaleSessionTimeOutDialog({
  required BuildContext context,
  required VoidCallback onButtonPressed,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Exhale Session Timed Out!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEA5455),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  'Please start the test procedure from the beginning.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF595959),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  'Note: Will be redirect to dashboard screen, your food data will be stored securely in our database.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mulish(
                    color: Color(0xFF595959),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                const Divider(),
                // Action buttons
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.045,
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onButtonPressed,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ), // Default background
                      foregroundColor: WidgetStateProperty.all(
                        Colors.black,
                      ), // Default text color
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.blue.withAlpha(
                            47,
                          ); // Background color when pressed
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.blue.withAlpha(26);
                        }
                        return null;
                      }),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.mulish(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
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
