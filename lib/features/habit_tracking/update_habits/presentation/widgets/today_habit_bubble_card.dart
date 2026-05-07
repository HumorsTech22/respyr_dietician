import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/habit_tracking/data/model/client_habit_status_response_model.dart';

import 'bubbles/bubble_layout.dart';
import 'bubbles/bubble_pop_item.dart';
import 'habit_progress_bar.dart';

/// The main "Today's To-do List" card showing habits as scattered bubbles.
///
/// Layout:
///   - "Your Habits" eyebrow
///   - "Today's To-do List" title
///   - Hint text
///   - Bubble cluster (taps fire [onHabitCompleted])
///   - Progress bar
///   - "View All Habits" link
class TodayHabitBubbleCard extends StatefulWidget {
  /// Maximum number of bubbles shown at once.
  static const int maxBubbles = 5;

  final ClientHabitStatusResponse response;
  final void Function(ClientHabitData habit, int index)? onHabitCompleted;
  final VoidCallback? onViewAll;

  const TodayHabitBubbleCard({
    super.key,
    required this.response,
    this.onHabitCompleted,
    this.onViewAll,
  });

  @override
  State<TodayHabitBubbleCard> createState() => _TodayHabitBubbleCardState();
}

class _TodayHabitBubbleCardState extends State<TodayHabitBubbleCard> {
  /// While true, all bubbles ignore taps. Used to debounce taps while
  /// a pop animation is running.
  bool _isLocked = false;

  /// Locks all bubbles, waits for the pop animation to finish, then
  /// fires [onUnlocked]. Total wait is 450 ms (300 ms pop + buffer).
  Future<void> _lockAndWait(VoidCallback onUnlocked) async {
    setState(() => _isLocked = true);
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _isLocked = false);
    onUnlocked();
  }

  void _handleBubblePopped(ClientHabitData habit, int index) {
    _lockAndWait(() => widget.onHabitCompleted?.call(habit, index));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EyebrowText(),
        const SizedBox(height: 20),
        const _TitleText(),
        const SizedBox(height: 32),
        Column(
          children: [
            const _HintText(),
            _BubbleCluster(
              response: widget.response,
              isLocked: _isLocked,
              onBubblePopped: _handleBubblePopped,
            ),
            HabitProgressBar(
              completedCount: widget.response.completedHabits,
              totalCount: widget.response.totalHabits,
            ),
            const SizedBox(height: 19),
            _ViewAllButton(onTap: widget.onViewAll),
          ],
        ),
      ],
    );
  }
}

class _EyebrowText extends StatelessWidget {
  const _EyebrowText();

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

class _TitleText extends StatelessWidget {
  const _TitleText();

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

class _HintText extends StatelessWidget {
  const _HintText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tap bubbles to mark progress',
      style: GoogleFonts.poppins(
        color: const Color(0xFFC193FF),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
      ),
    );
  }
}

/// The scattered bubble cluster. Lays out active habits via [BubbleLayout]
/// and renders each one as a [BubblePopItem] inside an [AnimatedPositioned]
/// so they smoothly slide into their new slots when one is popped.
class _BubbleCluster extends StatelessWidget {
  static const double _height = 430;

  final ClientHabitStatusResponse response;
  final bool isLocked;
  final void Function(ClientHabitData habit, int index) onBubblePopped;

  const _BubbleCluster({
    required this.response,
    required this.isLocked,
    required this.onBubblePopped,
  });

  List<ClientHabitData> get _activeHabits => response.data
      .take(TodayHabitBubbleCard.maxBubbles)
      .where((h) => !h.isTracked)
      .toList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final List<ClientHabitData> habits = _activeHabits;
          final List<BubblePlacement> placements = BubbleLayout.compute(
            habits: habits,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          );

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: List<Widget>.generate(habits.length, (i) {
              final ClientHabitData habit = habits[i];
              final BubblePlacement b = placements[i];

              return AnimatedPositioned(
                key: ValueKey(habit.habitId),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                left: b.topLeft.dx,
                top: b.topLeft.dy,
                child: BubblePopItem(
                  item: habit,
                  size: b.diameter,
                  isLocked: isLocked,
                  onPopCompleted: () => onBubblePopped(habit, i),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ViewAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              splashFactory: NoSplash.splashFactory,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 33.03,
                  height: 32,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFF6715D2),
                      ),
                      borderRadius: BorderRadius.circular(33),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_right,
                    size: 15,
                    color: Color(0xFF6715D2),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'View All Habits',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6715D2),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                    letterSpacing: -0.30,
                  ),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}