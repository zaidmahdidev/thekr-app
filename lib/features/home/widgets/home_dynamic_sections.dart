import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

class HomeDynamicSections extends StatelessWidget {
  const HomeDynamicSections({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = now.weekday;

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.md,
        vertical: context.insets.sm,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // 1. Friday Sunan (Visible on Friday)
          if (weekday == DateTime.friday) const FridaySunanCard(),

          // 2. Fasting Reminder (Visible on Sunday for Monday, Wednesday for Thursday)
          if (weekday == DateTime.sunday || weekday == DateTime.wednesday)
            FastingReminderCard(isForMonday: weekday == DateTime.sunday),
        ]),
      ),
    );
  }
}

class FridaySunanCard extends StatelessWidget {
  const FridaySunanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseDynamicCard(
      title: 'سنن يوم الجمعة',
      subtitle: 'نور ما بين الجمعتين',
      icon: Icons.auto_awesome,
      color: Colors.amber.shade700,
      items: const [
        'قراءة سورة الكهف',
        'كثرة الصلاة على النبي ﷺ',
        'الاغتسال والتطيب',
        'ساعة الاستجابة',
      ],
    );
  }
}

class FastingReminderCard extends StatelessWidget {
  final bool isForMonday;
  const FastingReminderCard({super.key, required this.isForMonday});

  @override
  Widget build(BuildContext context) {
    final dayName = isForMonday ? 'الاثنين' : 'الخميس';
    return _BaseDynamicCard(
      title: 'تذكير بصيام غدٍ',
      subtitle: 'صيام يوم $dayName',
      icon: Icons.wb_sunny_outlined,
      color: context.colors.secondary,
      description:
          'عن النبي ﷺ قال: "تُعْرَضُ الأعمالُ يومَ الاثنين والخميس، فَأُحِبُّ أَنْ يُعْرَضَ عَملي وأنا صائم".',
    );
  }
}

class _BaseDynamicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String>? items;
  final String? description;

  const _BaseDynamicCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.items,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(bottom: context.insets.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        boxShadow: context.shadows.low,
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.md,
              vertical: context.insets.sm,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.corners.xl),
                topRight: Radius.circular(context.corners.xl),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: context.insets.sm),
                Text(
                  title,
                  style: context.textStyles.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.insets.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description != null)
                  Text(
                    description!,
                    style: context.textStyles.bodyMedium?.copyWith(
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (items != null)
                  Wrap(
                    spacing: context.insets.sm,
                    runSpacing: context.insets.sm,
                    children: items!
                        .map(
                          (item) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(
                                context.corners.sm,
                              ),
                              border: Border.all(
                                color: color.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              item,
                              style: context.textStyles.bodySmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
