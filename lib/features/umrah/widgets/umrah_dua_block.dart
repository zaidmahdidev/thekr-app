import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/thikr_card.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_text.dart';

/// A dua with its title above and its source under it, on the app's adhkar
/// card, so it can be copied and shared. Used by the Umrah and Hajj lessons.
class UmrahDuaBlock extends ConsumerWidget {
  const UmrahDuaBlock({required this.dua});

  final UmrahDua dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: context.insets.sm,
            right: context.insets.sm,
            left: context.insets.sm,
          ),
          child: Text(
            dua.title,
            style: text.title(context, color: context.colors.primary),
          ),
        ),
        ThikrCard(
          text: dua.text,
          footnote: dua.source,
          actions: ThikrAction.copyAndShare(
            context,
            ref,
            text: dua.text,
            footnote: dua.source,
          ),
        ),
      ],
    );
  }
}
