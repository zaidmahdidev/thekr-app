import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

/// Reading sizes for the guide's explanatory text. They are the font size the
/// user chose for the app, used the same way the adhkar cards use it, so the
/// instructions and the duas on one page match and both follow the setting.
class UmrahTextStyles {
  const UmrahTextStyles(this.size);

  /// The app's font size setting, in logical pixels.
  final double size;

  /// Instructions and explanations.
  TextStyle body(BuildContext context, {Color? color, FontWeight? weight}) {
    return context.textStyles.bodyLarge!.copyWith(
      fontSize: size,
      height: 1.9,
      color: color,
      fontWeight: weight,
    );
  }

  /// Sources, hints and other secondary lines.
  TextStyle small(BuildContext context, {Color? color}) {
    return context.textStyles.bodySmall!.copyWith(
      // Same proportion as the source line under an adhkar card.
      fontSize: size * 0.76,
      height: 1.7,
      color: color,
    );
  }

  /// Headings inside a card.
  TextStyle title(BuildContext context, {Color? color}) {
    return context.textStyles.titleSmall!.copyWith(
      fontSize: size * 1.05,
      fontWeight: FontWeight.bold,
      height: 1.5,
      color: color,
    );
  }
}

final umrahTextProvider = Provider<UmrahTextStyles>((ref) {
  final fontSize = ref.watch(settingsProvider.select((s) => s.fontSize));
  return UmrahTextStyles(fontSize);
});
