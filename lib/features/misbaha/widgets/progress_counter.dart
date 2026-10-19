import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';

/// Big counter with a ring that fills up to the round target.
class ProgressCounter extends StatelessWidget {
  const ProgressCounter({super.key, required this.count, required this.target});

  final int count;

  /// Round size; 0 means no target (no ring progress).
  final int target;

  double get _progress {
    if (target <= 0 || count == 0) return 0;
    final remainder = count % target;
    // Keep the ring full at the moment a round is completed.
    return remainder == 0 ? 1 : remainder / target;
  }

  @override
  Widget build(BuildContext context) {
    final size = 150.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.surface.withValues(alpha: 0.85),
              border: Border.all(
                color: context.colors.secondary.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: context.shadows.low,
            ),
          ),
          SizedBox(
            width: size - 14.w,
            height: size - 14.w,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              builder: (context, value, _) => CircularProgressIndicator(
                value: target > 0 ? value : 0,
                strokeWidth: 5.w,
                strokeCap: StrokeCap.round,
                backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(context.colors.secondary),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Text(
                    _format(count),
                    style: context.textStyles.displayLarge?.copyWith(
                      fontSize: 44.sp,
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              Text(
                target > 0 ? 'من ${QuranText.digits(target)}' : 'تسبيحة',
                style: context.textStyles.labelMedium?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Arabic digits with a thousands separator.
  static String _format(int number) {
    final grouped = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return grouped.split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : QuranText.digits(d);
    }).join();
  }
}
