import 'package:flutter/material.dart';

/// A black snackbar-like bar with an "UNDO" action.
///
/// Shown for a few seconds after a habit bubble is popped, giving the
/// user a chance to revert before the change is committed to the server.
class HabitUndoBar extends StatelessWidget {
  final String habitName;
  final VoidCallback onUndo;

  const HabitUndoBar({
    super.key,
    required this.habitName,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$habitName marked as done',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onUndo,
            child: const Text(
              'UNDO',
              style: TextStyle(
                color: Color(0xFF8EC5FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}