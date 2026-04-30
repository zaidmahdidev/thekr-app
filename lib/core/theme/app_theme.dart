import 'package:flutter/material.dart';
import 'app_theme_extension.dart';
import 'tokens/design_tokens.dart';
import 'tokens/typography.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.light.primary,
      primarySwatch: AppColors.primarySwatch,
      colorScheme:
          ColorScheme.fromSwatch(
            primarySwatch: AppColors.primarySwatch,
          ).copyWith(
            primary: AppColors.light.primary,
            secondary: AppColors.light.secondary,
            surface: AppColors.light.surface,
            error: AppColors.light.error,
          ),
      scaffoldBackgroundColor: AppColors.light.background,
      useMaterial3: false,
      fontFamily: 'Tajawal',
      appBarTheme: AppBarTheme(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF0E645C),
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
          colors: AppColors.light,
          corners: AppCorners.defaultValues(),
          insets: AppInsets.defaultValues(),
          shadows: AppShadows.light(),
        ),
      ],
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.dark.primary,
      primarySwatch: AppColors.primarySwatch,
      colorScheme:
          ColorScheme.fromSwatch(
            primarySwatch: AppColors.primarySwatch,
            brightness: Brightness.dark,
          ).copyWith(
            primary: AppColors.dark.primary,
            secondary: AppColors.dark.secondary,
            surface: AppColors.dark.surface,
            error: AppColors.dark.error,
          ),
      scaffoldBackgroundColor: AppColors.dark.background,
      useMaterial3: false,
      fontFamily: 'Tajawal',
      appBarTheme: AppBarTheme(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF0E645C),
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
          colors: AppColors.dark,
          corners: AppCorners.defaultValues(),
          insets: AppInsets.defaultValues(),
          shadows: AppShadows.dark(),
        ),
      ],
    );
  }
}
