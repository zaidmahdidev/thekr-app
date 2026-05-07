import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/extensions.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/azkar/models/user_thikr.dart';
import 'package:thekr_app/features/azkar/providers/user_azkar_provider.dart';
import 'package:thekr_app/features/azkar/widgets/add_thikr_sheet.dart';

import 'package:thekr_app/features/settings/providers/settings_provider.dart';

class UserThikrCard extends ConsumerWidget {
  final UserThikr thikr;

  const UserThikrCard({super.key, required this.thikr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final fontSize = settings.fontSize;

    return MyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionIcon(
                icon: Icons.edit_outlined,
                color: Colors.blue,
                onTap: () => _showEditSheet(context),
              ),
              _ActionIcon(
                icon: Icons.delete_outline_rounded,
                color: Colors.red,
                onTap: () => _confirmDelete(context, ref),
              ),
              const Spacer(),
              _ActionIcon(
                icon: Icons.copy_rounded,
                color: context.colors.textSecondary,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: thikr.text));
                  showToast(text: 'تم نسخ الذكر');
                },
              ),
              _ActionIcon(
                icon: Icons.share_outlined,
                color: context.colors.secondary,
                onTap: () => ShareService.showShareSheet(
                  context,
                  ref,
                  content: thikr.text,
                  subtitle: thikr.description,
                  isCustomText: true,
                ),
              ),
            ],
          ),
          SizedBox(height: context.insets.md),
          Text(
            thikr.text,
            style: context.textStyles.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.6,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
          ),
          if (thikr.description != null && thikr.description!.isNotEmpty) ...[
            SizedBox(height: context.insets.sm),
            Text(
              thikr.description!,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                fontSize: fontSize * 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
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

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.corners.md),
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Icon(icon, size: 20.r, color: color),
      ),
    );
  }
}
