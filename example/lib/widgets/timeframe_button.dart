import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A compact pill-style timeframe selector button (`1M`, `3M`, `ALL`, ...).
class TimeframeButton extends StatelessWidget {
  const TimeframeButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.palette,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? palette.surfaceRaised : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? palette.textPrimary : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
