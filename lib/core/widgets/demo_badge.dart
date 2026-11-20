import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class DemoBadge extends StatelessWidget {
  final String label;
  final bool compact;

  const DemoBadge({super.key, this.label = 'DEMO MODE', this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.18),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: AppColors.warning, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.science_outlined,
            size: compact ? 12 : 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
