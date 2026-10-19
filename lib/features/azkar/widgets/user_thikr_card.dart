import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/extensions.dart';
import 'package:thekr_app/core/widgets/thikr_card.dart';
import 'package:thekr_app/features/azkar/models/user_thikr.dart';
import 'package:thekr_app/features/azkar/providers/user_azkar_provider.dart';
import 'package:thekr_app/features/azkar/widgets/add_thikr_sheet.dart';

import 'package:hugeicons/hugeicons.dart';

class UserThikrCard extends ConsumerWidget {
  final UserThikr thikr;

  const UserThikrCard({super.key, required this.thikr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThikrCard(
      text: thikr.text,
      footnote: thikr.description,
      actions: [
        ThikrAction(
          icon: HugeIcons.strokeRoundedEdit02,
          tooltip: 'تعديل',
          onTap: () => _showEditSheet(context),
        ),
        ThikrAction(
          icon: HugeIcons.strokeRoundedDelete02,
          tooltip: 'حذف',
          color: context.colors.error,
          onTap: () => _confirmDelete(context, ref),
        ),
        ...ThikrAction.copyAndShare(
          context,
          ref,
          text: thikr.text,
          footnote: thikr.description,
          isCustomText: true,
          copiedMessage: 'تم نسخ الذكر',
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    context.showConfirmDialog(
      title: 'حذف الذكر',
      message: 'هل أنت متأكد من حذف هذا الذكر؟',
      onYes: () {
        ref.read(userAzkarProvider.notifier).deleteThikr(thikr.id);
        context.pop();
      },
    );
  }

  void _showEditSheet(BuildContext context) {
    context.showSheet(
      title: 'تعديل الذكر',
      child: AddThikrSheet(existingThikr: thikr),
    );
  }
}
