import 'package:flutter/material.dart';

/// Shared color palette for the example app's chrome.
///
/// Deliberately mirrors `FinancialChartThemeData.dark()`/`.light()` from
/// the package itself so the surrounding toolbar/header UI and the chart
/// canvas read as one continuous surface instead of a plain app wrapped
/// around an unrelated-looking widget.
abstract final class AppColors {
  static const Color backgroundDark = Color(0xFF131722);
  static const Color surfaceDark = Color(0xFF1E222D);
  static const Color surfaceRaisedDark = Color(0xFF2A2E39);
  static const Color borderDark = Color(0xFF2A2E39);
  static const Color textPrimaryDark = Color(0xFFD1D4DC);
  static const Color textSecondaryDark = Color(0xFF787B86);

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F6F8);
  static const Color surfaceRaisedLight = Color(0xFFE0E3EB);
  static const Color borderLight = Color(0xFFE0E3EB);
  static const Color textPrimaryLight = Color(0xFF131722);
  static const Color textSecondaryLight = Color(0xFF787B86);

  static const Color accent = Color(0xFF2962FF);
  static const Color bullish = Color(0xFF26A69A);
  static const Color bearish = Color(0xFFEF5350);
}

/// A resolved set of chrome colors for the current [Brightness], so pages
/// don't each re-derive the dark/light branch.
class AppPalette {
  const AppPalette._({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  factory AppPalette.of({required bool dark}) {
    return dark
        ? const AppPalette._(
            background: AppColors.backgroundDark,
            surface: AppColors.surfaceDark,
            surfaceRaised: AppColors.surfaceRaisedDark,
            border: AppColors.borderDark,
            textPrimary: AppColors.textPrimaryDark,
            textSecondary: AppColors.textSecondaryDark,
          )
        : const AppPalette._(
            background: AppColors.backgroundLight,
            surface: AppColors.surfaceLight,
            surfaceRaised: AppColors.surfaceRaisedLight,
            border: AppColors.borderLight,
            textPrimary: AppColors.textPrimaryLight,
            textSecondary: AppColors.textSecondaryLight,
          );
  }

  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
}
