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

class UserThikrCard extends ConsumerWidget {
  final UserThikr thikr;

  const UserThikrCard({super.key, required this.thikr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _buildIconButton(context, Icons.delete_outline_rounded, Colors.red,
                  () {
                _confirmDelete(context, ref);
              }),
              _buildIconButton(
                  context, Icons.edit_outlined, context.colors.primary, () {
                _showEditSheet(context);
              }),
              const Spacer(),
              _buildIconButton(
                  context, Icons.copy_rounded, context.colors.textSecondary, () {
                Clipboard.setData(ClipboardData(text: thikr.text));
                showToast(text: 'تم النسخ');
              }),
              _buildIconButton(
                  context, Icons.share_rounded, context.colors.secondary, () {
                ShareService.showShareSheet(
                  context,
                  ref,
                  content: thikr.text,
                  subtitle: thikr.description,
                );
              }),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            thikr.text,
            style: context.textStyles.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (thikr.description != null) ...[
            SizedBox(height: 8.h),
            Text(
              thikr.description!,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.corners.md),
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Icon(icon, size: 20.r, color: color),
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
