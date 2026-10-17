import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/home/data/daily_content_data.dart';

/// Text tab: write your own text or fill it with a random verse / hadith / dhikr.
class ShareTextPanel extends StatelessWidget {
  const ShareTextPanel({
    super.key,
    required this.contentController,
    required this.sourceController,
  });

  final TextEditingController contentController;
  final TextEditingController sourceController;

  static final Random _random = Random();

  void _fill(String text, String source) {
    contentController.text = text;
    sourceController.text = source;
  }

  void _randomAyah() {
    final ayah = dailyAyahs[_random.nextInt(dailyAyahs.length)];
    _fill('﴿${ayah.text}﴾', 'سورة ${ayah.surah} - آية ${ayah.ayahNumber}');
  }

  void _randomHadith() {
    final hadith = dailyHadiths[_random.nextInt(dailyHadiths.length)];
    _fill(hadith.text, hadith.source);
  }

  void _randomDhikr() {
    final dhikr = dailyAdhkars[_random.nextInt(dailyAdhkars.length)];
    _fill(dhikr.text, dhikr.reward);
  }

  InputDecoration _decoration(
    BuildContext context, {
    required String hint,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.corners.lg),
      borderSide: BorderSide(
        color: context.colors.primary.withValues(alpha: 0.15),
      ),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: context.textStyles.bodySmall?.copyWith(
        color: context.colors.textSecondary,
      ),
      filled: true,
      fillColor: context.colors.background,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.insets.md,
        vertical: context.insets.sm + 2.h,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: context.colors.primary, width: 1.5),
      ),
      suffixIcon: suffix,
      counterText: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _QuickChip(
                icon: Icons.menu_book_rounded,
                label: 'آية عشوائية',
                onTap: _randomAyah,
              ),
              _QuickChip(
                icon: Icons.format_quote_rounded,
                label: 'حديث',
                onTap: _randomHadith,
              ),
              _QuickChip(
                icon: Icons.auto_awesome_rounded,
                label: 'ذكر',
                onTap: _randomDhikr,
              ),
            ],
          ),
        ),
        SizedBox(height: context.insets.sm),
        TextField(
          controller: contentController,
          minLines: 3,
          maxLines: 3,
          maxLength: 500,
          textAlign: TextAlign.start,
          textInputAction: TextInputAction.newline,
          style: context.textStyles.bodyMedium?.copyWith(height: 1.6),
          decoration: _decoration(
            context,
            hint: 'اكتب آية أو حديثاً أو خاطرة إيمانية...',
          ),
        ),
        SizedBox(height: context.insets.sm),
        TextField(
          controller: sourceController,
          maxLines: 1,
          maxLength: 80,
          style: context.textStyles.bodySmall,
          decoration: _decoration(
            context,
            hint: 'المصدر (اختياري) مثل: سورة البقرة - آية 152',
          ),
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: context.insets.sm),
      child: Material(
        color: context.colors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.corners.xl),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.xl),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.insets.md),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: context.colors.secondary),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: context.textStyles.labelMedium?.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
