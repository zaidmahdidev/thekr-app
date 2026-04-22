import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'base_app_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? context.colors.background,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar ?? (title != null ? BaseAppBar(title: title) : null),
      drawer: drawer,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle Mesh Gradient Blobs
          Positioned(
            bottom: 0.h,
            left: 0.w,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                AppAssets.bg,
                width: 300.w,
                color: context.colors.primary,
              ),
            ),
          ),
          PositionedDirectional(
            top: -100,
            end: -50,
            child: _buildGradientBlob(
              context.colors.primary.withValues(alpha: 0.09),
              300,
            ),
          ),
          PositionedDirectional(
            bottom: -50,
            start: -100,
            child: _buildGradientBlob(
              context.colors.secondary.withValues(alpha: 0.09),
              350,
            ),
          ),
          // Main Content
          body,
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildGradientBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
