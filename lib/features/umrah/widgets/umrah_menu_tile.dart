import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../providers/umrah_text.dart';

/// Full-width entry to a section of the guide: big icon, title, one line of
/// what it holds. Wide and plain on purpose, so it is easy to read and tap.
class UmrahMenuTile extends ConsumerWidget {
  const UmrahMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final AppIconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  /// Small text on the leading circle, e.g. a lesson number. Replaces the icon.
  final String? badge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: context.insets.sm + 2.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.xl),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(context.insets.sm + 4.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(context.corners.xl),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              boxShadow: context.shadows.low,
            ),
            child: Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: badge != null
                        ? Text(
                            badge!,
                            style: context.textStyles.titleLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          )
                        : AppIcon(icon, size: 26.w, color: color),
                  ),
                ),
                SizedBox(width: context.insets.sm + 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.title(context)),
                      Text(
                        subtitle,
                        style: text.small(context, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                AppIcon(
                  HugeIcons.strokeRoundedArrowRight01,
                  size: 22.w,
                  color: colors.textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
