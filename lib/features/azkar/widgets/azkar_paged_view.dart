import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/azkar/widgets/azkar_item_widget.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

/// The horizontal layout of an adhkar list: one thikr per page, swiped
/// sideways, with a bar below showing the position and previous / next buttons.
class AzkarPagedView extends StatefulWidget {
  const AzkarPagedView({
    super.key,
    required this.items,
    required this.controller,
    required this.onTapItem,
  });

  /// The adhkar with their counters (`zekr`, `bless`, `currentCount`, `originalCount`).
  final List<Map<String, dynamic>> items;
  final PageController controller;
  final ValueChanged<int> onTapItem;

  @override
  State<AzkarPagedView> createState() => _AzkarPagedViewState();
}

class _AzkarPagedViewState extends State<AzkarPagedView> {
  int _page = 0;

  void _goTo(int page) {
    widget.controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.length;

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: widget.controller,
            itemCount: total,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: context.insets.sm),
                  child: AzkarItemWidget(
                    details: item['zekr'],
                    bless: item['bless'],
                    currentCount: item['currentCount'],
                    originalCount: item['originalCount'],
                    onTap: () => widget.onTapItem(index),
                  ),
                ),
              );
            },
          ),
        ),
        _PagerBar(
          page: _page,
          total: total,
          onPrevious: _page > 0 ? () => _goTo(_page - 1) : null,
          onNext: _page < total - 1 ? () => _goTo(_page + 1) : null,
        ),
      ],
    );
  }
}

class _PagerBar extends StatelessWidget {
  const _PagerBar({
    required this.page,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.md,
        ),
        child: Row(
          children: [
            // Forced LTR so the arrows are not mirrored by the RTL layout: the
            // previous button sits on the right and points right.
            _ArrowButton(
              icon: HugeIcons.strokeRoundedArrowRight01,
              onTap: onPrevious,
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.insets.md,
                    vertical: context.insets.sm / 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(context.corners.xl),
                  ),
                  child: Text(
                    '${AppDigits.of(page + 1)} / ${AppDigits.of(total)}',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            _ArrowButton(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              onTap: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final AppIconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onTap != null;

    return Material(
      color: colors.primary.withValues(alpha: enabled ? 0.1 : 0.04),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44.w,
          height: 44.w,
          child: Center(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: AppIcon(
                icon,
                size: 20.sp,
                color: enabled
                    ? colors.primary
                    : colors.textSecondary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
