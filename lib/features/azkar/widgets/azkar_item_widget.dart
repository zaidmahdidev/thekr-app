import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/widgets/thikr_card.dart';

/// A thikr of the adhkar lists, with its counter.
class AzkarItemWidget extends ConsumerWidget {
  final String details;
  final String? bless;
  final int currentCount;
  final int originalCount;
  final VoidCallback onTap;

  const AzkarItemWidget({
    Key? key,
    required this.details,
    this.bless,
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
      text: details,
      footnote: bless,
      currentCount: currentCount,
      originalCount: originalCount,
      onTap: _handleTap,
      actions: ThikrAction.copyAndShare(
        context,
        ref,
        text: details,
        footnote: bless,
      ),
    );
  }
}
