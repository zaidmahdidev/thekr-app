import 'package:flutter/material.dart';
import 'package:thekr_app/core/theme/tokens/design_tokens.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

/// Fixed artwork palettes for share card templates.
///
/// These intentionally do NOT follow `context.colors`: a card is exported as an
/// image and must look identical whatever theme (light / dark / desert / forest)
/// the sender happens to use.
class ShareCardPalette {
  final List<Color> gradient;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final Color text;
  final Color accent;
  final double ornamentOpacity;
  final bool doubleFrame;

  const ShareCardPalette({
    required this.gradient,
    required this.text,
    required this.accent,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.ornamentOpacity = 0.1,
    this.doubleFrame = false,
  });

  static ShareCardPalette of(ShareTemplate template) {
    switch (template) {
      case ShareTemplate.classic:
        return const ShareCardPalette(
          gradient: [Color(0xFFFFFBEC), Color(0xFFF7EBCB)],
          text: Color(0xFF2D5A5A),
          accent: Color(0xFFB8905F),
          doubleFrame: true,
        );
      case ShareTemplate.luxury:
        return const ShareCardPalette(
          gradient: [Color(0xFF2C2C2C), Color(0xFF050505)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          text: Color(0xFFF3DC95),
          accent: Color(0xFFD4AF37),
          ornamentOpacity: 0.14,
          doubleFrame: true,
        );
      case ShareTemplate.spiritual:
        return const ShareCardPalette(
          gradient: [Color(0xFFE0F2FE), Color(0xFFF5FBFF)],
          text: Color(0xFF0C4A6E),
          accent: Color(0xFF0EA5E9),
        );
      case ShareTemplate.emerald:
        return ShareCardPalette(
          gradient: [
            AppColors.primarySwatch[500]!,
            AppColors.primarySwatch[900]!,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          text: const Color(0xFFFFFFFF),
          accent: const Color(0xFFF2C86B),
          ornamentOpacity: 0.16,
          doubleFrame: true,
        );
      case ShareTemplate.dawn:
        return const ShareCardPalette(
          gradient: [Color(0xFF3B2A6B), Color(0xFF9B4F78), Color(0xFFF0A065)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          text: Color(0xFFFFFFFF),
          accent: Color(0xFFFFE2A8),
          ornamentOpacity: 0.12,
        );
      case ShareTemplate.minimal:
        return const ShareCardPalette(
          gradient: [Color(0xFFFFFFFF), Color(0xFFF4F4F5)],
          text: Color(0xFF18181B),
          accent: Color(0xFF71717A),
          ornamentOpacity: 0.05,
        );
    }
  }
}
