import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApiFailedDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onClose;

  const ApiFailedDialog({
    super.key,
    this.title = "API Failed",
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 24,
              offset: Offset(0, 12),
              color: Color(0x1A000000),
            ),
          ],
          border: Border.all(color: const Color(0xFFEFEFF4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, size: 30,),
            const SizedBox(height: 10),
            Text(
              "Result generation failed.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
              ),
            ),

            const SizedBox(height: 14),
            Text(
              "This may be due to a slow internet connection or the server not responding.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.30,
                letterSpacing: -0.24,
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0E0E6)),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0xFFC7C6CE),
                        ),
                        borderRadius: BorderRadius.circular(25.50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      "Go back",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}