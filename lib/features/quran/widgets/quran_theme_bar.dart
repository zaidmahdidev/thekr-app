import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../providers/quran_provider.dart';

class QuranThemeBar extends ConsumerWidget {
  final int currentPage;
  final VoidCallback onThemeSelected;

  const QuranThemeBar({
    super.key,
    required this.currentPage,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: 90.h,
      left: 50.w,
      right: 50.w,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * -10),
              child: child,
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ThemeOption(
                currentPage: currentPage,
                theme: QuranTheme.light,
                color: const Color(0xFFFFFDF5),
                onSelected: onThemeSelected,
              ),
              _ThemeOption(
                currentPage: currentPage,
                theme: QuranTheme.dark,
                color: const Color(0xFF1F2125),
                onSelected: onThemeSelected,
              ),
              _ThemeOption(
                currentPage: currentPage,
                theme: QuranTheme.blueGrey,
                color: const Color(0xFF343A41),
                onSelected: onThemeSelected,
              ),
              _ThemeOption(
                currentPage: currentPage,
                theme: QuranTheme.sepia,
                color: const Color(0xFFF4ECD8),
                onSelected: onThemeSelected,
              ),
              _ThemeOption(
                currentPage: currentPage,
                theme: QuranTheme.green,
                color: const Color(0xFFE8F5E9),
                onSelected: onThemeSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends ConsumerWidget {
  final int currentPage;
  final QuranTheme theme;
  final Color color;
  final VoidCallback onSelected;

  const _ThemeOption({
    required this.currentPage,
    required this.theme,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(quranProvider(currentPage)).readingTheme;
    final isSelected = currentTheme == theme;

    return GestureDetector(
      onTap: () {
        ref.read(quranProvider(currentPage).notifier).setTheme(theme);
        onSelected();
      },
      child: Container(
        width: 35.w,
        height: 35.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 1.5.w : 1.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: theme == QuranTheme.dark || theme == QuranTheme.blueGrey
                    ? Colors.white
                    : context.colors.primary,
                size: 18.sp,
              )
            : null,
      ),
    );
  }
}
