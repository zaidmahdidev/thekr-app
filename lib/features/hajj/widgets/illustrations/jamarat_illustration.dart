import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/umrah/widgets/illustrations/umrah_illustration_frame.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_segmented_control.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

enum _Pillar {
  small(
    'الصغرى',
    1,
    'تبدأ بها بعد الزوال: سبع حصيات مع التكبير. ثم تتقدم قليلاً وتستقبل القبلة وتدعو طويلاً رافعاً يديك.',
    0.52,
  ),
  middle(
    'الوسطى',
    2,
    'ثانياً: سبع حصيات مع التكبير. ثم تتقدم قليلاً وتستقبل القبلة وتدعو كذلك.',
    0.7,
  ),
  large(
    'الكبرى (العقبة)',
    3,
    'ثالثاً: سبع حصيات مع التكبير، ثم تنصرف دون وقوف ولا دعاء. وهي التي ترميها وحدها يوم العيد، والكعبة عن يسارك ومنى عن يمينك.',
    0.9,
  );

  const _Pillar(this.title, this.order, this.body, this.height);

  final String title;
  final int order;
  final String body;

  /// Relative height of the drawn pillar.
  final double height;
}

/// The three jamarat in the order they are stoned, from the one farthest from
/// Makkah to the one nearest to it. Switch between the day of sacrifice and the
/// days of tashreeq to see which are stoned and how many pebbles are needed.
class JamaratIllustration extends StatefulWidget {
  const JamaratIllustration({super.key});

  @override
  State<JamaratIllustration> createState() => _JamaratIllustrationState();
}

class _JamaratIllustrationState extends State<JamaratIllustration> {
  _Pillar? _selected;
  bool _eidDay = false;

  bool _active(_Pillar p) => !_eidDay || p == _Pillar.large;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = _selected;

    return UmrahIllustrationFrame(
      title: 'الجمرات الثلاث',
      infoTitle: selected?.title,
      infoBody: selected?.body,
      hint:
          'تُرمى في أيام التشريق من الأولى إلى الثالثة. اضغط على أي جمرة لتعرف كيف تُرمى.',
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UmrahSegmentedControl<bool>(
            values: const [true, false],
            selected: _eidDay,
            labelOf: (isEid) => isEid ? 'يوم النحر' : 'أيام التشريق',
            onChanged: (value) => setState(() => _eidDay = value),
          ),
          SizedBox(height: context.insets.sm),
          Text(
            _eidDay
                ? 'يوم النحر: جمرة العقبة وحدها بسبع حصيات.'
                : 'كل يوم من أيام التشريق: ثلاث جمرات بإحدى وعشرين حصاة.',
            style: context.textStyles.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'المجموع ${AppDigits.of(70)} حصاة لمن بقي إلى الثالث عشر، و${AppDigits.of(49)} للمتعجل.',
            style: context.textStyles.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      child: SizedBox(
        height: 214.w,
        child: Directionality(
          // The drawing reads from the first pillar to the last, right to left.
          textDirection: TextDirection.rtl,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final pillar in _Pillar.values)
                Expanded(
                  child: _PillarView(
                    pillar: pillar,
                    active: _active(pillar),
                    selected: pillar == selected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = pillar);
                    },
                  ),
                ),
              SizedBox(
                width: 54.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // In this right-to-left drawing the arrow points left.
                    AppIcon(
                      HugeIcons.strokeRoundedArrowRight01,
                      size: 26.w,
                      color: colors.secondary,
                    ),
                    Text(
                      'نحو مكة',
                      textAlign: TextAlign.center,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10.sp,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 28.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillarView extends StatelessWidget {
  const _PillarView({
    required this.pillar,
    required this.active,
    required this.selected,
    required this.onTap,
  });

  final _Pillar pillar;
  final bool active;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = selected ? colors.secondary : colors.primary;
    final maxHeight = 120.w;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: active ? 1 : 0.35,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 28.w,
              height: 22.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
              ),
              child: Text(
                AppDigits.of(pillar.order),
                style: context.textStyles.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                  height: 1.1,
                ),
              ),
            ),
            SizedBox(height: 4.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 34.w + pillar.height * 14.w,
              height: maxHeight * pillar.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18.r),
                  bottom: Radius.circular(4.r),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withValues(alpha: 0.85),
                    accent.withValues(alpha: 0.45),
                  ],
                ),
                border: Border.all(color: accent, width: selected ? 2.4 : 1.4),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: colors.secondary.withValues(alpha: 0.45),
                          blurRadius: 12.r,
                        ),
                      ]
                    : null,
              ),
            ),
            SizedBox(height: 4.w),
            SizedBox(
              height: 38.w,
              child: Text(
                pillar.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall?.copyWith(
                  color: selected ? colors.primary : colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
