import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SwipeButtonWidget extends StatefulWidget {
  final VoidCallback? onSwiped;
  final TimeOfDay cutoffTime;

  const SwipeButtonWidget({
    super.key,
    this.onSwiped,
    this.cutoffTime = const TimeOfDay(hour: 13, minute: 0),
  });

  @override
  State<SwipeButtonWidget> createState() => _SwipeButtonWidgetState();
}

class _SwipeButtonWidgetState extends State<SwipeButtonWidget> {
  double _dragPosition = 0.0;
  Timer? _timer;
  String _statusText = "";
  bool _isDisposed = false;
  bool _timeOver = false;

  @override
  void initState() {
    super.initState();
    _updateStatusText();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateStatusText();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }

  void _updateStatusText() {
    final now = DateTime.now();

    final target = DateTime(
      now.year,
      now.month,
      now.day,
      widget.cutoffTime.hour,
      widget.cutoffTime.minute,
    );

    final diff = target.difference(now);

    if (diff.isNegative) {
      if (_statusText != "You missed" || _timeOver == false) {
        setState(() {
          _statusText = "You missed";
          _timeOver = true;
          _dragPosition = 0.0;
        });
      }
      return;
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    String newText;

    if (hours > 0) {
      // ✅ 1 hour or more → no seconds
      newText = "$hours hr : ${minutes} min left";
    } else {
      // ✅ less than 1 hour → show seconds
      if (minutes > 0) {
        newText = "$minutes min : ${seconds}s left";
      } else {
        newText = "${seconds}s left";
      }
    }

    if (newText != _statusText || _timeOver == true) {
      setState(() {
        _statusText = newText;
        _timeOver = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double height = 65.0;
    const double width = 220.0;
    const double padding = 7.0;
    const double knobSize = height - 8;
    const double dragThreshold = 0.50;

    final maxDrag = width - height - (padding * 1.5);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(60),
      ),
      child: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white54, Colors.grey.shade300],
              ),
            ),
          ),

          // TEXT (centered but not behind knob)
          Center(
            child: Padding(
              padding: EdgeInsets.only(left: knobSize + 15, right: 15),
              child: Text(
                _statusText,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.30,
                ),
              ),
            ),
          ),

          // DRAGGABLE KNOB
          Positioned(
            left: padding + _dragPosition,
            top: (height - knobSize) / 2,
            child: AbsorbPointer(
              absorbing: _timeOver,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (!mounted) return;
                  setState(() {
                    _dragPosition += details.delta.dx;
                    _dragPosition = _dragPosition.clamp(0.0, maxDrag);
                  });
                },
                onHorizontalDragEnd: (_) {
                  final passed = _dragPosition > (maxDrag * dragThreshold);
                  if (passed) {
                    widget.onSwiped?.call();
                    Future.delayed(Duration.zero, () {
                      if (!_isDisposed && mounted) {
                        setState(() => _dragPosition = 0.0);
                      }
                    });
                  } else {
                    if (mounted) setState(() => _dragPosition = 0.0);
                  }
                },
                child: Container(
                  width: knobSize,
                  height: knobSize,
                  decoration: BoxDecoration(
                    color: _timeOver ? Colors.grey : const Color(0xFF308BF9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 8.4,
                        offset: Offset(0, 0),
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
