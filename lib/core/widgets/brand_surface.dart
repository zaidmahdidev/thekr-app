import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';

/// Colors that go with [BrandSurface]: a soft light card in light mode and a
/// deep green card in dark mode, so it never looks heavy on a light screen.
class BrandSurfaceStyle {
  final bool isDark;
  final Color text;
  final Color textMuted;

  /// Labels and icons.
  final Color accent;

  /// Ornament / frame / glow color.
  final Color gold;

  /// Small round buttons sitting on the surface.
  final Color controlBackground;
  final Color controlForeground;

  /// Call-to-action button.
  final Color ctaBackground;
  final Color ctaForeground;

  const BrandSurfaceStyle({
    required this.isDark,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.gold,
    required this.controlBackground,
    required this.controlForeground,
    required this.ctaBackground,
    required this.ctaForeground,
  });

  factory BrandSurfaceStyle.of(BuildContext context) {
    final colors = context.colors;
    if (context.isDarkMode) {
      return BrandSurfaceStyle(
        isDark: true,
        text: Colors.white,
        textMuted: Colors.white.withValues(alpha: 0.72),
        accent: colors.secondary,
        gold: colors.secondary,
        controlBackground: Colors.white.withValues(alpha: 0.14),
        controlForeground: Colors.white.withValues(alpha: 0.92),
        ctaBackground: colors.secondary,
        ctaForeground: Colors.white,
      );
    }
    return BrandSurfaceStyle(
      isDark: false,
      text: colors.textPrimary,
      textMuted: colors.textSecondary,
      accent: colors.primary,
      gold: colors.secondary,
      controlBackground: colors.primary.withValues(alpha: 0.08),
      controlForeground: colors.primary,
      ctaBackground: colors.primary,
      ctaForeground: Colors.white,
    );
  }
}

/// The app's signature surface: gradient, soft golden glow, a corner ornament and
/// a thin inner frame. Adapts to light / dark mode (see [BrandSurfaceStyle]).
class BrandSurface extends StatelessWidget {
  const BrandSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;

  static Color deepen(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final style = BrandSurfaceStyle.of(context);
    final primary = context.colors.primary;
    final surface = context.colors.surface;
    final r = radius ?? context.corners.xl;

    final List<Color> gradient = style.isDark
        ? [deepen(primary, 0.06), deepen(primary, 0.22)]
        : [Color.alphaBlend(primary.withValues(alpha: 0.1), surface), surface];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: style.isDark ? 0.3 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: gradient,
                  ),
                  border: Border.all(
                    color: style.isDark
                        ? Colors.transparent
                        : primary.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(r),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 0.9,
                    colors: [
                      style.gold.withValues(alpha: style.isDark ? 0.26 : 0.14),
                      style.gold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -34.w,
              bottom: -38.w,
              child: Opacity(
                opacity: style.isDark ? 0.14 : 0.09,
                child: Image.asset(AppAssets.bg, width: 130.w),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r - 5),
                    border: Border.all(
                      color: style.gold.withValues(
                        alpha: style.isDark ? 0.28 : 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ],
        ),
      ),
    );
  }
}
