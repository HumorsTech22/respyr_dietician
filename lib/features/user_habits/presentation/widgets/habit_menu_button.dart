import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HabitMenuButton extends StatelessWidget {
  final VoidCallback onTapped;
  const HabitMenuButton({super.key, required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onTapped,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: SvgPicture.asset("assets/images/icons/ic_todo_menu.svg")
    );
  }
}
