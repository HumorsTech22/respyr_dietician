import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/size/get_height.dart';

/// A horizontal bar that fills proportionally to show habit completion progress.
class HabitProgressBar extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const HabitProgressBar({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  double get _progress {
    if (totalCount <= 0) return 0;
    return (completedCount / totalCount).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      height: rh(context: context, px: 70),
      padding: EdgeInsets.all(rh(context: context, px: 5)),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            width:1,
            color: const Color(0xFFF5F7FA),

          ),
        ),

      ),
      child: Stack(
        children: [
          _ProgressFill(
            progress: _progress,
            radius: rh(context: context, px: 12),
          ),
          _ProgressLabel(
            completedCount: completedCount,
            totalCount: totalCount,
          ),
        ],
      ),
    );
  }
}

class _ProgressFill extends StatelessWidget {
  final double progress;
  final double radius;

  const _ProgressFill({required this.progress, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          widthFactor: progress,
          heightFactor: 1,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: ShapeDecoration(
              color: const Color(0xFFE0FFE7),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressLabel extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const _ProgressLabel({
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 13,
      bottom: 0,
      top: 0,
      child: Center(
        child: Text(
          '$completedCount/$totalCount completed',
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 34,
            fontWeight: FontWeight.w400,
            letterSpacing: -2.04,
          ),
        ),
      ),
    );
  }
}