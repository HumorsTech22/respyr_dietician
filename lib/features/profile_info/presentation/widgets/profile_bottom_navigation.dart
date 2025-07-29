import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileBottomNavigation extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String? nextLabel; // optional label for the next button

  const ProfileBottomNavigation({
    super.key,
    this.onNext,
    this.onBack,
    this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom + 5;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset > 5 ? bottomInset : 30,
        left: 26,
        right: 26,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left_outlined,
              size: 26,
              color: Colors.black,
            ),
            onPressed: onBack,
          ),
          InkWell(
            onTap: onNext,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding:
                  nextLabel != null
                      ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                      : const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF308BF9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  if (nextLabel != null) ...[
                    Text(
                      nextLabel!,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.30,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(
                    Icons.chevron_right_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
