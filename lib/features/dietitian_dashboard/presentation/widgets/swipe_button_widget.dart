import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SwipeButtonWidget extends StatefulWidget {
  /// Called when user completes the swipe.
  final VoidCallback? onSwiped;

  const SwipeButtonWidget({super.key, this.onSwiped});

  @override
  State<SwipeButtonWidget> createState() => _SwipeButtonWidgetState();
}

class _SwipeButtonWidgetState extends State<SwipeButtonWidget> {
  double _dragPosition = 0.0;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double height = 65.0;
    const double width = 220.0;
    const double padding = 7.0;
    const double dragThreshold = 0.50; // 50% of the track

    final maxDrag = width - height - (padding * 1.5);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(60),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // background gradient
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
          // subtle overlay gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [Colors.grey.shade300, const Color(0xFFD0D0D0), Colors.grey.shade300],
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
                child: Text("Slide to start test",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.30,
                  ),
                )
            ),
          ),

          // draggable knob
          Positioned(
            left: padding + _dragPosition,
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
                  // ✅ "Return" on swiped
                  if (widget.onSwiped != null) {
                    widget.onSwiped!();
                  } else {
                    // Try to pop this route with a true result (safe in dialogs/screens)
                    Navigator.of(context).maybePop(true);
                  }
                  // (Optional) reset after a short delay for visual polish when staying on the same page
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (!_isDisposed && mounted) {
                      setState(() => _dragPosition = 0.0);
                    }
                  });
                } else {
                  if (!mounted) return;
                  setState(() => _dragPosition = 0.0);
                }
              },
              child: Container(
                width: height - 8,
                height: height - 8,
                decoration: ShapeDecoration(
                  color: const Color(0xFF308BF9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25000),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 8.40,
                      offset: Offset(0, 0),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
