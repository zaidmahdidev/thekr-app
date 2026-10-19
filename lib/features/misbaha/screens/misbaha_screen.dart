import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/extensions/ui_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import '../providers/misbaha_provider.dart';
import '../widgets/misbaha_painter.dart';
import '../widgets/progress_counter.dart';
import '../widgets/zikr_selector.dart';
import '../widgets/reset_button.dart';
import '../widgets/bead_color_picker.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Electronic tasbih: tap anywhere to count. Beads slide along the string, the
/// ring fills up to the round target and a strong vibration marks each round.
@RoutePage()
class MisbahaScreen extends ConsumerStatefulWidget {
  const MisbahaScreen({super.key});

  @override
  ConsumerState<MisbahaScreen> createState() => _MisbahaScreenState();
}

class _MisbahaScreenState extends ConsumerState<MisbahaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scroll;

  @override
  void initState() {
    super.initState();
    // The painter listens to this controller directly, so counting repaints only
    // the beads, not the whole screen.
    _scroll = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: ref.read(misbahaProvider).totalCount.toDouble(),
      upperBound: 1000000000.0,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _handleReset() {
    context.showConfirmDialog(
      title: 'تصفير العداد',
      message: 'هل تريد تصفير عدّاد هذا الذكر؟',
      onYes: () {
        Navigator.of(context).pop();
        HapticFeedback.mediumImpact();
        ref.read(misbahaProvider.notifier).reset();
      },
    );
  }

  void _onTotalChanged(int? previous, int next) {
    if (next == previous) return;
    _scroll.animateTo(
      next.toDouble(),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
    );

    // A round was just completed by counting (not by switching dhikr).
    if (previous != null && next == previous + 1) {
      final state = ref.read(misbahaProvider);
      if (state.target > 0 && state.count % state.target == 0) {
        HapticFeedback.heavyImpact();
        Future.delayed(
          const Duration(milliseconds: 140),
          HapticFeedback.heavyImpact,
        );
        showToast(
          text: 'أتممت ${QuranText.digits(state.target)} تسبيحة',
          backgroundColor: context.colors.secondary,
          textColor: Colors.white,
        );
      }
    }
  }

  void _pickTarget(int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _TargetSheet(
        current: current,
        onSelected: (value) {
          Navigator.pop(sheetContext);
          ref.read(misbahaProvider.notifier).setTarget(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(misbahaProvider.select((s) => s.totalCount), _onTotalChanged);

    final state = ref.watch(misbahaProvider);
    final rounds = state.target > 0 ? state.count ~/ state.target : 0;

    return AppScaffold(
      title: 'المسبحة الإلكترونية',
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(misbahaProvider.notifier).increment();
        },
        child: Stack(
          children: [
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _scroll,
                builder: (context, _) => CustomPaint(
                  size: Size(1.sw, 1.sh),
                  painter: InfiniteLoopBeadPainter(
                    scrollProgress: _scroll.value,
                    primaryColor: context.colors.primary,
                    secondaryColor: context.colors.secondary,
                    beadType: state.beadType,
                  ),
                ),
              ),
            ),
            Positioned(
              // Physical right: the beads run down the left side of the screen.
              right: context.insets.lg,
              top: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 150.w,
                      child: OrnamentalZikrSelector(
                        currentZikr: state.currentZikr,
                        counts: state.zikrCounts,
                        onChanged: (zikr) =>
                            ref.read(misbahaProvider.notifier).setZikr(zikr),
                      ),
                    ),
                    SizedBox(height: context.insets.md),
                    ProgressCounter(count: state.count, target: state.target),
                    SizedBox(height: context.insets.md),
                    SizedBox(
                      width: 150.w,
                      child: Row(
                        children: [
                          Expanded(
                            child: _InfoChip(
                              icon: HugeIcons.strokeRoundedFlag01,
                              label: state.target > 0
                                  ? 'الهدف ${QuranText.digits(state.target)}'
                                  : 'بدون هدف',
                              onTap: () => _pickTarget(state.target),
                            ),
                          ),
                          if (state.target > 0) ...[
                            SizedBox(width: context.insets.sm),
                            _InfoChip(
                              icon: HugeIcons.strokeRoundedRepeat,
                              label: QuranText.digits(rounds),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: context.insets.md),
                    MinimalistResetButton(onReset: _handleReset),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: context.insets.lg,
              child: BeadColorPicker(
                currentType: state.beadType,
                onSelected: (type) =>
                    ref.read(misbahaProvider.notifier).setBeadType(type),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.onTap});

  final AppIconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(context.corners.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.corners.xl),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.corners.xl),
            border: Border.all(
              color: context.colors.secondary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(icon, size: 14.sp, color: context.colors.secondary),
              SizedBox(width: 4.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: context.textStyles.labelMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
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

class _TargetSheet extends StatelessWidget {
  const _TargetSheet({required this.current, required this.onSelected});

  final int current;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                'هدف الجولة',
                style: context.textStyles.titleSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.insets.md),
              Wrap(
                spacing: context.insets.sm,
                runSpacing: context.insets.sm,
                alignment: WrapAlignment.center,
                children: [
                  for (final value in misbahaTargets)
                    ChoiceChip(
                      label: Text(
                        value == 0 ? 'بدون هدف' : QuranText.digits(value),
                      ),
                      selected: value == current,
                      selectedColor: context.colors.primary,
                      labelStyle: TextStyle(
                        color: value == current
                            ? context.colors.surface
                            : context.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => onSelected(value),
                    ),
                ],
              ),
              SizedBox(height: context.insets.md),
            ],
          ),
        ),
      ),
    );
  }
}
