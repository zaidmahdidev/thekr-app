import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/widgets/thikr_card.dart';

/// A hadith (or any text) with its explanation, without a counter.
class CustomAzkarWidget extends ConsumerWidget {
  const CustomAzkarWidget({Key? key, required this.details, this.bless})
    : super(key: key);

  final String details;
  final String? bless;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThikrCard(
      text: details,
      footnote: bless,
      actions: ThikrAction.copyAndShare(
        context,
        ref,
        text: details,
        footnote: bless,
      ),
    );
  }
}
