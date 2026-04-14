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
