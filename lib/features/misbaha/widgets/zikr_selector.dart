import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../providers/misbaha_provider.dart';
import 'add_zikr_dialog.dart';
import 'package:thekr_app/core/extensions/ui_extension.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

/// Pill showing the current dhikr. Tap to choose another one from a sheet that
/// also shows how many times each dhikr was counted.
class OrnamentalZikrSelector extends StatelessWidget {
  final Zikr currentZikr;

  const OrnamentalZikrSelector({super.key, required this.currentZikr});

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ZikrSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(context.corners.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.corners.xl),
        onTap: () => _openSheet(context),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.insets.md,
            vertical: context.insets.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.corners.xl),
            border: Border.all(
              color: context.colors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  currentZikr.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              AppIcon(
                HugeIcons.strokeRoundedArrowDown01,
                color: context.colors.secondary,
                size: 20.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZikrSheet extends ConsumerWidget {
  const _ZikrSheet();

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final text = await showAddZikrDialog(context);
    if (text == null) return;
    final problem = ref.read(misbahaProvider.notifier).addCustom(text);
    if (problem != null) {
      showToast(text: problem);
    } else if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void _delete(BuildContext context, WidgetRef ref, Zikr zikr) {
    context.showConfirmDialog(
      title: 'حذف الذكر',
      message: 'هل تريد حذف «${zikr.label}» وعدّاده؟',
      onYes: () {
        Navigator.of(context).pop();
        ref.read(misbahaProvider.notifier).deleteCustom(zikr);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(misbahaProvider);
    final canAdd = state.customAzkar.length < maxCustomAzkar;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.insets.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: context.insets.md),
                decoration: BoxDecoration(
                  color: context.colors.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.corners.sm),
                ),
              ),
              Text(
                'اختر الذكر',
                style: context.textStyles.titleSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.insets.sm),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final zikr in state.azkar)
                      _ZikrTile(
                        zikr: zikr,
                        count: state.zikrCounts[zikr.id] ?? 0,
                        selected: zikr == state.currentZikr,
                        onTap: () {
                          Navigator.pop(context);
                          ref.read(misbahaProvider.notifier).setZikr(zikr);
                        },
                        onDelete: zikr.isCustom
                            ? () => _delete(context, ref, zikr)
                            : null,
                      ),
                  ],
                ),
              ),
              SizedBox(height: context.insets.sm),
              TextButton.icon(
                onPressed: canAdd ? () => _add(context, ref) : null,
                icon: AppIcon(
                  HugeIcons.strokeRoundedAdd01,
                  size: 20.sp,
                  color: canAdd
                      ? context.colors.primary
                      : context.colors.textSecondary,
                ),
                label: Text(
                  canAdd ? 'إضافة ذكر خاص' : 'وصلت إلى الحد الأعلى',
                  style: context.textStyles.titleSmall?.copyWith(
                    color: canAdd
                        ? context.colors.primary
                        : context.colors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZikrTile extends StatelessWidget {
  const _ZikrTile({
    required this.zikr,
    required this.count,
    required this.selected,
    required this.onTap,
    this.onDelete,
  });

  final Zikr zikr;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Material(
        color: selected
            ? context.colors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(context.corners.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.lg),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.md,
              vertical: context.insets.sm + 2.h,
            ),
            child: Row(
              children: [
                AppIcon(
                  selected
                      ? HugeIcons.strokeRoundedRadioButton
                      : HugeIcons.strokeRoundedCircle,
                  size: 20.sp,
                  color: selected
                      ? context.colors.primary
                      : context.colors.textSecondary,
                ),
                SizedBox(width: context.insets.md),
                Expanded(
                  child: Text(
                    zikr.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.titleSmall?.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                Text(
                  AppDigits.of(count),
                  style: context.textStyles.labelLarge?.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'حذف',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                    icon: AppIcon(
                      HugeIcons.strokeRoundedDelete02,
                      size: 20.sp,
                      color: context.colors.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
