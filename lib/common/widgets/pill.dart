import 'package:flutter/material.dart';

enum PillVariant { filled, outline, soft }

class Pill extends StatelessWidget {
  final String label;
  final PillVariant variant;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;

  const Pill({
    super.key,
    required this.label,
    this.variant = PillVariant.filled,
    this.icon,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.radius = 999, // big radius = pill
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Colors per variant
    final Color bg, fg, border;
    switch (variant) {
      case PillVariant.filled:
        bg = cs.primary;
        fg = cs.onPrimary;
        border = Colors.transparent;
        break;
      case PillVariant.outline:
        bg = Colors.transparent;
        fg = cs.primary;
        border = cs.primary.withOpacity(0.4);
        break;
      case PillVariant.soft:
        bg = cs.primary.withOpacity(0.1);
        fg = cs.primary;
        border = Colors.transparent;
        break;
    }

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
              height: 1.1,
            ),
          ),
        ),
      ],
    );

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: child,
    );

    // Ripple if tappable
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}
