import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class DemoBadge extends StatelessWidget {
  final String label;
  final bool compact;
  final Color? color;
  final IconData? icon;

  const DemoBadge({
    super.key,
    this.label = 'ВЕРИФИЦИРОВАНО',
    this.compact = false,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.success;
    final effectiveIcon = icon ?? Icons.verified_rounded;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: effectiveColor.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            effectiveIcon,
            size: compact ? 12 : 14,
            color: effectiveColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
