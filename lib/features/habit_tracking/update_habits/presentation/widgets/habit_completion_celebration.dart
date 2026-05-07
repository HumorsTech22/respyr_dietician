import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/size/get_height.dart';

/// "Perfect score" celebration card shown when the user has completed
/// all of their habits for the day.
///
/// Layout: a white rounded rectangle with a large purple circle peeking
/// up from the bottom, the score on top, and a streak/share section below.
class HabitCompletionCelebration extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final int streakDays;
  final VoidCallback? onShare;

  const HabitCompletionCelebration({
    super.key,
    required this.completedCount,
    required this.totalCount,
    this.streakDays = 0,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(),
        SizedBox(height: rh(context: context, px: 20)),
        _Title(),
        const SizedBox(height: 32),
        _CelebrationCard(
          completedCount: completedCount,
          totalCount: totalCount,
          streakDays: streakDays,
          onShare: onShare,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Your Habits',
      style: GoogleFonts.poppins(
        color: const Color(0xFF6715D2),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        height: 1.0,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "Today's To-do List",
      style: GoogleFonts.poppins(
        color: const Color(0xFF6715D2),
        fontSize: 25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.50,
        height: 1.0,
      ),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final int streakDays;
  final VoidCallback? onShare;

  const _CelebrationCard({
    required this.completedCount,
    required this.totalCount,
    required this.streakDays,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 483,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const _BackgroundCircle(),
            _ScoreSection(
              completedCount: completedCount,
              totalCount: totalCount,
            ),
            _StreakSection(
              streakDays: streakDays,
              onShare: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

/// The big purple circle peeking up from the bottom of the card.
class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      bottom: -330,
      left: -80,
      right: -80,
      child: SizedBox(
        height: 628,
        child: InnerShadow(
          shadows: [
            BoxShadow(
              color: Color(0xFFF8F3FF),
              offset: Offset(12, 36),
              blurRadius: 58.1,
              spreadRadius: -11,
              blurStyle: BlurStyle.inner,
            ),
          ],
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF9647FF),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// The "X out of Y" score, centered toward the top of the card.
class _ScoreSection extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const _ScoreSection({
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            'Habit Board',
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.20,
              height: 1,
            ),
          ),
          Text(
            'Perfect score! 🎉',
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.26,
              letterSpacing: -0.40,
            ),
          ),
          const SizedBox(height: 60),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Text(
                '$completedCount',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 100,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'out of $totalCount',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFA1A1A1),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Streak text + share button, sitting on top of the purple circle.
class _StreakSection extends StatelessWidget {
  final int streakDays;
  final VoidCallback? onShare;

  const _StreakSection({required this.streakDays, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 25,
      child: Column(
        children: [
          Text(
            '🔥 Keep it going!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          // const SizedBox(height: 6),
          // Text(
          //   'Keep it going!',
          //   style: GoogleFonts.poppins(
          //     color: Colors.white,
          //     fontSize: 15,
          //     fontWeight: FontWeight.w600,
          //     height: 1.0,
          //     letterSpacing: -0.30,
          //   ),
          // ),
          const SizedBox(height: 38),
          _ShareButton(onTap: onShare),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ShareButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        height: 61,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE1E6ED)),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.share, color: Colors.white, size: 15),
            const SizedBox(width: 13),
            Text(
              'Share',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.10,
                letterSpacing: 0.30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}