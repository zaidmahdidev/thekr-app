import 'package:flutter/material.dart';
import 'tokens/design_tokens.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final AppColors colors;
  final AppCorners corners;
  final AppInsets insets;
  final AppShadows shadows;

  const AppThemeExtension({
    required this.colors,
    required this.corners,
    required this.insets,
    required this.shadows,
  });

  /// Used when a widget sits under a Theme that does not carry the app's
  /// extension (for example a sheet or dialog built by a package).
  static final AppThemeExtension fallbackLight = AppThemeExtension(
    colors: AppColors.light,
    corners: AppCorners.defaultValues(),
    insets: AppInsets.defaultValues(),
    shadows: AppShadows.light(),
  );

  static final AppThemeExtension fallbackDark = AppThemeExtension(
    colors: AppColors.dark,
    corners: AppCorners.defaultValues(),
    insets: AppInsets.defaultValues(),
    shadows: AppShadows.dark(),
  );

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    AppColors? colors,
    AppCorners? corners,
    AppInsets? insets,
    AppShadows? shadows,
  }) {
    return AppThemeExtension(
      colors: colors ?? this.colors,
      corners: corners ?? this.corners,
      insets: insets ?? this.insets,
      shadows: shadows ?? this.shadows,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      colors: colors,
      corners: corners,
      insets: insets,
      shadows: shadows,
    );
  }
}
