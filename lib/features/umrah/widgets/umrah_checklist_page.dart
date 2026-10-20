import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/extensions/ui_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_checklist_provider.dart';
import '../providers/umrah_text.dart';
import 'umrah_font_actions.dart';

/// A packing list with ticks that are saved on the device. Shared by the Umrah
/// and the Hajj guides: each passes its own groups and its own saved ticks.
class UmrahChecklistPage extends ConsumerWidget {
  const UmrahChecklistPage({
    super.key,
    required this.groups,
    required this.provider,
    this.title = 'قائمة التجهيز',
  });

  final List<ChecklistGroup> groups;
  final StateNotifierProvider<ChecklistNotifier, Set<String>> provider;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checked = ref.watch(provider);
    final total = groups.fold<int>(0, (sum, group) => sum + group.items.length);
    final notifier = ref.read(provider.notifier);

    return AppScaffold(
      appBar: BaseAppBar(
        title: title,
        actions: [
          ...umrahFontActions(ref),
          if (checked.isNotEmpty)
            IconButton(
              tooltip: 'مسح العلامات',
              onPressed: () => context.showConfirmDialog(
                title: 'مسح العلامات',
                message: 'هل تريد إلغاء تحديد كل العناصر؟',
                onYes: () {
                  Navigator.of(context).pop();
                  notifier.clear();
                },
              ),
              icon: const AppIcon(HugeIcons.strokeRoundedRefresh),
            ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.lg + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _Summary(done: checked.length, total: total),
          SizedBox(height: context.insets.md),
          for (final group in groups)
            _Group(
              group: group,
              checked: checked,
              onToggle: (id) {
                HapticFeedback.selectionClick();
                notifier.toggle(id);
              },
            ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final complete = done >= total;
    final accent = complete ? colors.success : colors.primary;

    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  complete ? 'كل شيء جاهز، سفراً ميسّراً' : 'تجهيزاتك',
                  style: context.textStyles.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
              Text(
                '${QuranText.digits(done)} / ${QuranText.digits(total)}',
                style: context.textStyles.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.insets.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.corners.sm),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: total == 0 ? 0 : done / total),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8.h,
                backgroundColor: accent.withValues(alpha: 0.15),
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.group,
    required this.checked,
    required this.onToggle,
  });

  final ChecklistGroup group;
  final Set<String> checked;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final done = group.items.where((i) => checked.contains(i.id)).length;

    return Container(
      margin: EdgeInsets.only(bottom: context.insets.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
        boxShadow: context.shadows.low,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.insets.md,
              context.insets.md,
              context.insets.md,
              context.insets.sm,
            ),
            child: Row(
              children: [
                AppIcon(group.icon, size: 22.w, color: colors.primary),
                SizedBox(width: context.insets.sm),
                Expanded(
                  child: Text(
                    group.title,
                    style: context.textStyles.titleSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
                Text(
                  '${QuranText.digits(done)}/${QuranText.digits(group.items.length)}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          for (final item in group.items)
            _ItemRow(
              item: item,
              isChecked: checked.contains(item.id),
              onTap: () => onToggle(item.id),
            ),
          SizedBox(height: context.insets.sm),
        ],
      ),
    );
  }
}

class _ItemRow extends ConsumerWidget {
  const _ItemRow({
    required this.item,
    required this.isChecked,
    required this.onTap,
  });

  final ChecklistItem item;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.insets.md,
          vertical: context.insets.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.w,
              height: 24.w,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? colors.success : Colors.transparent,
                border: Border.all(
                  color: isChecked
                      ? colors.success
                      : colors.textSecondary.withValues(alpha: 0.5),
                  width: 1.6,
                ),
              ),
              child: isChecked
                  ? Center(
                      child: AppIcon(
                        HugeIcons.strokeRoundedTick02,
                        size: 15.w,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: context.insets.sm + 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: text
                        .body(
                          context,
                          color: isChecked
                              ? colors.textSecondary
                              : colors.textPrimary,
                        )
                        .copyWith(
                          decoration: isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                    child: Text(item.label),
                  ),
                  if (item.hint != null)
                    Text(
                      item.hint!,
                      style: text.small(context, color: colors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
