import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/habit_tracking/data/model/client_habit_status_response_model.dart';

import 'bubble_text_formatter.dart';

/// Animation timing constants for the pop interaction.
class _BubblePopTiming {
  static const Duration popDuration = Duration(milliseconds: 300);
  static const Curve popCurve = Curves.easeInOutCubic;
  static const double popScale = 1.12;
}

/// A single round purple bubble that scales up and fades out when tapped.
///
/// The pop animation runs locally (300 ms), then [onPopCompleted] fires.
/// The parent is expected to lock other bubbles for the duration of the
/// animation via [isLocked].
class BubblePopItem extends StatefulWidget {
  final ClientHabitData item;
  final double size;
  final VoidCallback onPopCompleted;
  final bool isLocked;

  const BubblePopItem({
    super.key,
    required this.item,
    required this.size,
    required this.onPopCompleted,
    required this.isLocked,
  });

  @override
  State<BubblePopItem> createState() => _BubblePopItemState();
}

class _BubblePopItemState extends State<BubblePopItem> {
  bool _isPopping = false;

  Future<void> _pop() async {
    if (widget.isLocked || _isPopping) return;

    setState(() => _isPopping = true);
    await Future.delayed(_BubblePopTiming.popDuration);

    if (!mounted) return;
    widget.onPopCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pop,
      child: AnimatedScale(
        scale: _isPopping ? _BubblePopTiming.popScale : 1.0,
        duration: _BubblePopTiming.popDuration,
        curve: _BubblePopTiming.popCurve,
        child: AnimatedOpacity(
          opacity: _isPopping ? 0.0 : 1.0,
          duration: _BubblePopTiming.popDuration,
          curve: Curves.easeInCubic,
          child: RepaintBoundary(
            child: _BubbleSurface(
              size: widget.size,
              child: _BubbleContent(item: widget.item),
            ),
          ),
        ),
      ),
    );
  }
}

/// The visual surface of a bubble: round, purple, with inner shadows.
class _BubbleSurface extends StatelessWidget {
  final double size;
  final Widget child;

  const _BubbleSurface({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: const Color(0xFFB388EB),
        shape: OvalBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0xFFE3CDFF),
          ),
        ),
      ),
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.18),
        decoration: inset.BoxDecoration(
          color: const Color(0xFFB66BFF),
          shape: BoxShape.circle,
          boxShadow: [
            inset.BoxShadow(
              color: const Color(0xFF9647FF),
              offset: const Offset(-5, -6),
              blurRadius: 5.6,
              inset: true,
            ),
            inset.BoxShadow(
              color: Colors.white.withValues(alpha: 0.90),
              offset: const Offset(10, 25),
              blurRadius: 41.1,
              spreadRadius: -11,
              inset: true,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// The text content (title + frequency subtitle) inside a bubble.
class _BubbleContent extends StatelessWidget {
  final ClientHabitData item;

  const _BubbleContent({required this.item});

  String get _subtitle {
    if (item.frequencyType == 'daily') return 'Everyday';
    if (item.frequencyType == 'weekly') return '${item.targetCount} x week';
    return item.frequencyType;
  }

  @override
  Widget build(BuildContext context) {
    final String title = BubbleTextFormatter.formatTitle(item.habitName);

    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 3,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -0.32,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _subtitle,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}