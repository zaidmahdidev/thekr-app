import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../providers/umrah_text.dart';

/// A paragraph in a bordered card, for plain explanations.
class UmrahTextCard extends ConsumerWidget {
  const UmrahTextCard(this.text);

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.watch(umrahTextProvider);
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
        boxShadow: context.shadows.low,
      ),
      child: Text(text, style: styles.body(context)),
    );
  }
}
