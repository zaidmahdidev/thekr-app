import 'package:flutter/material.dart';
import 'app_theme_extension.dart';
import 'tokens/design_tokens.dart';
import 'tokens/typography.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

class AppTheme {
  static ThemeData light(AppThemeType type) {
    final colors = _getColors(type, Brightness.light);
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: colors.primary,
      primarySwatch: AppColors.primarySwatch,
      colorScheme:
          ColorScheme.fromSwatch(
            primarySwatch: AppColors.primarySwatch,
          ).copyWith(
            primary: colors.primary,
            secondary: colors.secondary,
            surface: colors.surface,
            error: colors.error,
          ),
      scaffoldBackgroundColor: colors.background,
      useMaterial3: false,
      fontFamily: 'Tajawal',
      appBarTheme: AppBarTheme(
        toolbarHeight: 80,
        backgroundColor: colors.primary,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTypography.h3.copyWith(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.h1,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        titleLarge: AppTypography.h3,
        titleMedium: AppTypography.h3,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.label,
        labelSmall: AppTypography.button,
      ),
      extensions: [
        AppThemeExtension(
          colors: colors,
          corners: AppCorners.defaultValues(),
          insets: AppInsets.defaultValues(),
          shadows: AppShadows.light(),
        ),
      ],
    );
  }

  static ThemeData dark(AppThemeType type) {
    final colors = _getColors(type, Brightness.dark);
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: colors.primary,
      primarySwatch: AppColors.primarySwatch,
      colorScheme:
          ColorScheme.fromSwatch(
            primarySwatch: AppColors.primarySwatch,
            brightness: Brightness.dark,
          ).copyWith(
            primary: colors.primary,
            secondary: colors.secondary,
            surface: colors.surface,
            error: colors.error,
          ),
      scaffoldBackgroundColor: colors.background,
      useMaterial3: false,
      fontFamily: 'Tajawal',
      appBarTheme: AppBarTheme(
        toolbarHeight: 80,
        backgroundColor: colors.primary,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTypography.h3.copyWith(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.h1.copyWith(color: Colors.white),
        headlineLarge: AppTypography.h1.copyWith(color: Colors.white),
        headlineMedium: AppTypography.h2.copyWith(color: Colors.white),
        titleLarge: AppTypography.h3.copyWith(color: Colors.white),
        titleMedium: AppTypography.h3.copyWith(color: Colors.white),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.white),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: Colors.white),
        bodySmall: AppTypography.bodySmall.copyWith(color: Colors.white),
        labelLarge: AppTypography.label.copyWith(color: Colors.white),
        labelSmall: AppTypography.button.copyWith(color: Colors.white),
      ),
      extensions: [
        AppThemeExtension(
          colors: colors,
          corners: AppCorners.defaultValues(),
          insets: AppInsets.defaultValues(),
          shadows: AppShadows.dark(),
        ),
      ],
    );
  }

  static AppColors _getColors(AppThemeType type, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (type) {
      case AppThemeType.defaultTheme:
        return isDark ? AppColors.dark : AppColors.light;
      case AppThemeType.desert:
        return isDark ? AppColors.desertDark : AppColors.desertLight;
      case AppThemeType.forest:
        return isDark ? AppColors.forestDark : AppColors.forestLight;
    }
  }
}
