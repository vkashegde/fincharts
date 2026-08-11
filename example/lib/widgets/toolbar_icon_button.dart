import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A compact, terminal-style icon button used in the chart toolbar —
/// highlights with a soft accent fill/border when [selected].
class ToolbarIconButton extends StatelessWidget {
  const ToolbarIconButton({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.palette,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final AppPalette palette;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: selected ? AppColors.accent : palette.textSecondary,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(
      message: tooltip!,
      waitDuration: const Duration(milliseconds: 400),
      child: button,
    );
  }
}
