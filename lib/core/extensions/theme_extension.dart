import 'package:flutter/material.dart';
import '../theme/app_theme_extension.dart';
import '../theme/tokens/design_tokens.dart';

extension ThemeContextExtension on BuildContext {
  AppThemeExtension get _themeExtension {
    final theme = Theme.of(this);
    return theme.extension<AppThemeExtension>() ??
        (theme.brightness == Brightness.dark
            ? AppThemeExtension.fallbackDark
            : AppThemeExtension.fallbackLight);
  }

  AppColors get colors => _themeExtension.colors;
  AppCorners get corners => _themeExtension.corners;
  AppInsets get insets => _themeExtension.insets;
  AppShadows get shadows => _themeExtension.shadows;

  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
