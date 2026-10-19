import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/widgets/thikr_card.dart';

/// A supplication of Husn al-Muslim, with its counter.
class HusnAlMuslimItemWidget extends ConsumerWidget {
  final String text;
  final String footnote;
  final int currentCount;
  final int originalCount;
  final VoidCallback onTap;

  const HusnAlMuslimItemWidget({
    Key? key,
    required this.text,
    required this.footnote,
    required this.currentCount,
    required this.originalCount,
    required this.onTap,
  }) : super(key: key);

  void _handleTap() {
    HapticFeedback.lightImpact();
    HapticFeedback.vibrate();
    if (currentCount == 1) {
      HapticFeedback.heavyImpact();
    }
    onTap();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThikrCard(
      text: text,
      footnote: footnote,
      currentCount: currentCount,
      originalCount: originalCount,
      onTap: _handleTap,
      actions: ThikrAction.copyAndShare(
        context,
        ref,
        text: text,
        footnote: footnote,
      ),
    );
  }
}
