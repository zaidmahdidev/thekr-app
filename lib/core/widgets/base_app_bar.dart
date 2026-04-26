import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final bool showBlur;

  const BaseAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.bottom,
    this.showBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final double customHeight = 75.h;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    final totalHeight = customHeight + bottomHeight + 2.h;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: showBlur ? 12 : 0,
          sigmaY: showBlur ? 12 : 0,
        ),
        child: Container(
          height: totalHeight,

          child: Stack(
            children: [
              AppBar(
                toolbarHeight: customHeight,
                title:
                    titleWidget ??
                    (title != null
                        ? Text(
                            title!,
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.textPrimary,
                              fontSize: 18.sp,
                              letterSpacing: 0.5,
                            ),
                          )
                        : null),
                actions: actions != null
                    ? [...actions!, SizedBox(width: 8.w)]
                    : null,
                leading: leading ?? _buildDefaultLeading(context),
                centerTitle: centerTitle,
                elevation: 0,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                bottom: bottom,
                iconTheme: IconThemeData(
                  color: context.colors.textPrimary,
                  size: 22.w,
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1.5.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        context.colors.primary.withValues(alpha: 0.3),
                        context.colors.primary.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildDefaultLeading(BuildContext context) {
    if (!Navigator.canPop(context)) return null;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: InkWell(
          onTap: () => context.maybePop(),
          borderRadius: BorderRadius.circular(context.corners.rc360),
          child: Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.corners.rc360),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16.w),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(70.h + (bottom?.preferredSize.height ?? 0) + 2.h);
  }
}
