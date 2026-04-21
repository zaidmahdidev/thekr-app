import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/features/home/data/daily_content_data.dart';

class DailyAyahCard extends StatelessWidget {
  const DailyAyahCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic to select an ayah based on the day of the year
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final ayahIndex = dayOfYear % dailyAyahs.length;
    final ayah = dailyAyahs[ayahIndex];

    return Container(
      margin: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        boxShadow: context.shadows.low,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary.withValues(alpha: 0.05),
            context.colors.surface,
          ],
        ),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.router.push(SurahRoute(currentPage: ayah.page));
          },
          borderRadius: BorderRadius.circular(context.corners.xl),
          child: Padding(
            padding: EdgeInsets.all(context.insets.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: context.colors.primary.withValues(alpha: 0.3),
                      size: 32,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.insets.sm,
                        vertical: context.insets.sm / 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.corners.md),
                      ),
                      child: Text(
                        'آية اليوم',
                        style: AppTypography.label.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.insets.md),
                Text(
                  ayah.text,
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(
                    height: 1.6,
                    color: context.colors.textPrimary,
                    fontFamily: 'hafs',
                  ),
                ),
                SizedBox(height: context.insets.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 1,
                      color: context.colors.primary.withValues(alpha: 0.2),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.insets.sm,
                      ),
                      child: Text(
                        '${ayah.surah} - [${ayah.ayahNumber}]',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 1,
                      color: context.colors.primary.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
