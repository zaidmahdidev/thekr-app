import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/umrah/providers/umrah_text.dart';
import 'package:thekr_app/features/umrah/widgets/illustrations/umrah_illustration_frame.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Act {
  stoning(
    'رمي جمرة العقبة',
    'سبع حصيات مع التكبير',
    HugeIcons.strokeRoundedTarget02,
    true,
  ),
  sacrifice(
    'الهدي',
    'للمتمتع والقارن، ولا يدخل في حساب التحلل',
    HugeIcons.strokeRoundedCoins01,
    false,
  ),
  shaving(
    'الحلق أو التقصير',
    'للرجل الحلق أو التقصير، وللمرأة التقصير',
    HugeIcons.strokeRoundedScissor,
    true,
  ),
  tawaf(
    'طواف الإفاضة والسعي',
    'والسعي على المتمتع ومن لم يسعَ عند القدوم',
    HugeIcons.strokeRoundedMosque01,
    true,
  );

  const _Act(this.title, this.subtitle, this.icon, this.countsForRelease);

  final String title;
  final String subtitle;
  final AppIconData icon;

  /// Whether it counts toward the first and second release from ihram.
  final bool countsForRelease;
}

/// The five acts of the day of sacrifice, in their Sunnah order. Tick the acts
/// in any order to see when the first and the second release from ihram
/// happen: order does not matter, only which acts are done.
class DaySequenceIllustration extends StatefulWidget {
  const DaySequenceIllustration({super.key});

  @override
  State<DaySequenceIllustration> createState() =>
      _DaySequenceIllustrationState();
}

class _DaySequenceIllustrationState extends State<DaySequenceIllustration> {
  final Set<_Act> _done = {};

  int get _counted => _done.where((a) => a.countsForRelease).length;

  (String, String) get _status {
    if (_counted >= 3) {
      return (
        'التحلل الثاني',
        'أتممت الرمي والحلق أو التقصير والطواف مع السعي، فحلّ لك كل ما حُرم بالإحرام حتى الجماع.',
      );
    }
    if (_counted == 2) {
      return (
        'التحلل الأول',
        'فعلت اثنين من الثلاثة، فحلّ لك لبس المخيط والطيب وكل ما حُرم بالإحرام إلا الجماع.',
      );
    }
    return (
      'لم تتحلل بعد',
      'التحلل الأول يحصل بفعل اثنين من ثلاثة: الرمي، والحلق أو التقصير، والطواف مع السعي.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return UmrahIllustrationFrame(
      title: 'أعمال يوم النحر والتحلل',
      infoTitle: _done.isEmpty ? null : status.$1,
      infoBody: _done.isEmpty ? null : status.$2,
      hint:
          'السنة في الترتيب: الرمي ثم الهدي ثم الحلق ثم الطواف. ولا حرج في تقديم بعضها على بعض. اضغط على كل عمل تفعله لترى متى تتحلل.',
      child: Column(
        children: [
          for (final (index, act) in _Act.values.indexed)
            Padding(
              padding: EdgeInsets.only(bottom: context.insets.sm),
              child: _ActTile(
                number: index + 1,
                act: act,
                done: _done.contains(act),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (!_done.add(act)) _done.remove(act);
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ActTile extends ConsumerWidget {
  const _ActTile({
    required this.number,
    required this.act,
    required this.done,
    required this.onTap,
  });

  final int number;
  final _Act act;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;
    final accent = done ? colors.success : colors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.corners.lg),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.all(context.insets.sm + 2.w),
          decoration: BoxDecoration(
            color: done
                ? colors.success.withValues(alpha: 0.08)
                : colors.background,
            borderRadius: BorderRadius.circular(context.corners.lg),
            border: Border.all(
              color: done
                  ? colors.success
                  : colors.textSecondary.withValues(alpha: 0.2),
              width: done ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? accent : accent.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: done
                      ? AppIcon(
                          HugeIcons.strokeRoundedTick02,
                          size: 20.w,
                          color: Colors.white,
                        )
                      : AppIcon(act.icon, size: 20.w, color: accent),
                ),
              ),
              SizedBox(width: context.insets.sm + 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_digit(number)}. ${act.title}',
                      style: text.title(context, color: accent),
                    ),
                    Text(
                      act.subtitle,
                      style: text.small(context, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _digit(int n) => const ['٠', '١', '٢', '٣', '٤', '٥'][n];
}
