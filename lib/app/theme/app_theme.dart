import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData getTheme({
    required bool isDark,
    double fontScale = 1.0,
    bool highContrast = false,
  }) {
    final baseBg = highContrast
        ? (isDark
              ? AppColors.highContrastBgDark
              : AppColors.highContrastBgLight)
        : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
    final baseSurface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final typography = AppTypography.textTheme(
      isDark: isDark,
      fontScale: fontScale,
      highContrast: highContrast,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: baseBg,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryDark,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: baseSurface,
        onSurface: isDark ? AppColors.textDark : AppColors.textLight,
      ),
      textTheme: typography,
      appBarTheme: AppBarTheme(
        backgroundColor: baseBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: typography.titleLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: baseSurface,
        elevation: highContrast ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: highContrast
              ? BorderSide(
                  color: isDark ? Colors.white : Colors.black,
                  width: 1.5,
                )
              : BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: typography.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16 * fontScale,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: typography.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16 * fontScale,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: highContrast
              ? BorderSide(
                  color: isDark ? Colors.white70 : Colors.black45,
                  width: 1,
                )
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: typography.bodyMedium,
      ),
    );
  }
}
