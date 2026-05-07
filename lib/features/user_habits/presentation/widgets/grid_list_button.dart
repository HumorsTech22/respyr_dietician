import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GridListButton extends StatelessWidget {
  final VoidCallback onTap;
  final String iconPath;
  const GridListButton({super.key, required this.onTap, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0xFFE1E6ED),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
        onPressed: onTap, 
        icon: SvgPicture.asset(iconPath)
    );
  }
}
