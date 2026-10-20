import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:readmore/readmore.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/utils/constants/app_icons.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

/// A small round button shown at the top of a [ThikrCard].
class ThikrAction {
  const ThikrAction({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
  });

  final AppIconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  /// Defaults to the primary color.
  final Color? color;

  /// Copy and share, the actions every thikr has.
  static List<ThikrAction> copyAndShare(
    BuildContext context,
    WidgetRef ref, {
    required String text,
    String? footnote,
    bool isCustomText = false,
    String copiedMessage = 'تم النسخ',
  }) {
    return [
      ThikrAction(
        icon: HugeIcons.strokeRoundedCopy01,
        tooltip: 'نسخ',
        onTap: () {
          HapticFeedback.lightImpact();
          Clipboard.setData(ClipboardData(text: text));
          showToast(text: copiedMessage);
        },
      ),
      ThikrAction(
        icon: AppIcons.share,
        tooltip: 'مشاركة',
        onTap: () => ShareService.showShareSheet(
          context,
          ref,
          content: text,
          subtitle: footnote,
          isCustomText: isCustomText,
        ),
      ),
    ];
  }
}

/// The card of one thikr (adhkar, Husn al-Muslim, hadith, the user's own adhkar).
///
/// With [originalCount] it works as a counter: tapping the card counts down and
/// the ring at the bottom shows what is left.
class ThikrCard extends ConsumerStatefulWidget {
  const ThikrCard({
    super.key,
    required this.text,
    this.footnote,
    this.actions = const [],
    this.onTap,
    this.currentCount,
    this.originalCount,
  });

  final String text;
  final String? footnote;
  final List<ThikrAction> actions;
  final VoidCallback? onTap;
  final int? currentCount;
  final int? originalCount;

  bool get _hasCounter => currentCount != null && originalCount != null;

  @override
  ConsumerState<ThikrCard> createState() => _ThikrCardState();
}

class _ThikrCardState extends ConsumerState<ThikrCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(settingsProvider).fontSize;
    final colors = context.colors;
    final done = widget._hasCounter && widget.currentCount == 0;
    final accent = done ? colors.success : colors.primary;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.insets.sm / 2,
        horizontal: context.insets.sm,
      ),
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.corners.xl),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.surface,
                  Color.alphaBlend(
                    accent.withValues(alpha: 0.04),
                    colors.surface,
                  ),
                ],
              ),
              border: Border.all(color: accent.withValues(alpha: done ? 0.4 : 0.12)),
              boxShadow: context.shadows.low,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.insets.md,
                context.insets.md,
                context.insets.md,
                context.insets.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    // Uthmani Quran text needs the Quran font to show its marks.
                    style: QuranText.style(
                      context.textStyles.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 2.2,
                        fontSize: fontSize,
                        color: colors.textPrimary,
                      ),
                      widget.text,
                    ),
                  ),
                  if (_hasFootnote) ...[
                    SizedBox(height: context.insets.sm),
                    _buildFootnote(context, fontSize),
                  ],
                  SizedBox(height: context.insets.sm),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasFootnote =>
      widget.footnote != null && widget.footnote!.trim().isNotEmpty;

  /// One slim row: the counter on the start side, the actions on the other.
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        if (widget._hasCounter) _buildCounter(context),
        const Spacer(),
        for (final action in widget.actions) ...[
          SizedBox(width: context.insets.sm / 2),
          _ActionButton(action: action),
        ],
      ],
    );
  }

  Widget _buildFootnote(BuildContext context, double fontSize) {
    final colors = context.colors;
    final small = fontSize * 0.76;
    final link = context.textStyles.bodyMedium?.copyWith(
      color: colors.secondary,
      fontWeight: FontWeight.bold,
      fontSize: small,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.md,
        vertical: context.insets.sm - 2.h,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border(
          right: BorderSide(
            color: colors.secondary.withValues(alpha: 0.7),
            width: 3,
          ),
        ),
      ),
      child: ReadMoreText(
        widget.footnote!.trim(),
        trimLines: 2,
        textAlign: TextAlign.justify,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'قراءة المزيد',
        trimExpandedText: ' قراءة أقل',
        lessStyle: link,
        moreStyle: link,
        style: context.textStyles.bodyMedium?.copyWith(
          color: colors.textSecondary,
          height: 1.6,
          fontSize: small,
        ),
      ),
    );
  }

  Widget _buildCounter(BuildContext context) {
    final colors = context.colors;
    final total = widget.originalCount!;
    final left = widget.currentCount!;
    final progress = total == 0 ? 1.0 : (total - left) / total;
    final done = left == 0;
    final ringColor = done ? colors.success : colors.secondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40.w,
          height: 40.w,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                      backgroundColor: colors.primary.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(ringColor),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: done
                        ? AppIcon(
                            HugeIcons.strokeRoundedTick02,
                            key: const ValueKey('done'),
                            color: colors.success,
                            size: 22.sp,
                          )
                        : Text(
                            '$left',
                            key: ValueKey(left),
                            style: context.textStyles.titleMedium?.copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(width: context.insets.sm),
        Text(
          done ? 'تم بحمد الله' : 'من $total',
          style: context.textStyles.bodySmall?.copyWith(
            color: done ? colors.success : colors.textSecondary,
            fontWeight: done ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final ThikrAction action;

  @override
  Widget build(BuildContext context) {
    final color = action.color ?? context.colors.primary;

    return Tooltip(
      message: action.tooltip ?? '',
      child: Material(
        color: color.withValues(alpha: 0.08),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: action.onTap,
          child: SizedBox(
            width: 34.w,
            height: 34.w,
            child: Center(child: AppIcon(action.icon, color: color, size: 19.sp)),
          ),
        ),
      ),
    );
  }
}
