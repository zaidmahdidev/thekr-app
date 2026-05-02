import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showHandle;
  final bool showBackgroundOrnament;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.showBackgroundOrnament = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: Stack(
        children: [
          if (showBackgroundOrnament)
            Positioned(
              bottom: -50.w,
              left: -50.w,
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(AppAssets.bg, width: 250.w),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.insets.lg,
              context.insets.sm,
              context.insets.lg,
              context.insets.lg + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showHandle)
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: context.insets.lg),
                    decoration: BoxDecoration(
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(context.corners.sm),
                    ),
                  ),
                if (title != null) ...[
                  Text(
                    title!,
                    style: context.textStyles.titleSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.insets.lg),
                ],
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showHandle = true,
    bool showBackgroundOrnament = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AppBottomSheet(
        title: title,
        showHandle: showHandle,
        showBackgroundOrnament: showBackgroundOrnament,
        child: child,
      ),
    );
  }
}
