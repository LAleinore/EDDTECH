import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const String fontFamily =
      '.SF Pro Text'; // iOS system default font fallback

  static TextTheme textTheme({
    required bool isDark,
    required double fontScale,
    required bool highContrast,
  }) {
    final textColor = highContrast
        ? (isDark
              ? AppColors.highContrastTextDark
              : AppColors.highContrastTextLight)
        : (isDark ? AppColors.textDark : AppColors.textLight);
    final secondaryColor = highContrast
        ? textColor
        : (isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight);

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32 * fontScale,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.6,
      ),
      displayMedium: TextStyle(
        fontSize: 28 * fontScale,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.4,
      ),
      headlineLarge: TextStyle(
        fontSize: 24 * fontScale,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20 * fontScale,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontSize: 18 * fontScale,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11 * fontScale,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
    );
  }
}
