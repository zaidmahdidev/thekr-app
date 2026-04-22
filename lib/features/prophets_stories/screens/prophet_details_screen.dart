import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/tokens/typography.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../models/prophet_story.dart';

@RoutePage()
class ProphetDetailsScreen extends StatelessWidget {
  final ProphetStory prophet;

  const ProphetDetailsScreen({super.key, required this.prophet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          // Premium Header with Background
          SliverAppBar(
            expandedHeight: 170.h,
            pinned: true,
            backgroundColor: context.colors.primary,
            leading: IconButton(
              onPressed: () => context.maybePop(),
              icon: Container(
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
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                prophet.name,
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(AppAssets.bg, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          context.colors.primary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        AppAssets.around,
                        width: 150.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content List
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.all(context.insets.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Brief Section
                    _GlassSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prophet.title,
                            style: AppTypography.h2.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          SizedBox(height: context.insets.md),
                          Text(
                            prophet.brief,
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.colors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.insets.lg),

                    // Quranic Verses Section
                    if (prophet.quranVerses.isNotEmpty) ...[
                      _SectionTitle(title: 'آيات من القرآن الكريم'),
                      ...prophet.quranVerses.map(
                        (verse) => Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: context.insets.md),
                          padding: EdgeInsets.all(context.insets.lg),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(
                              context.corners.md,
                            ),
                            border: Border.all(
                              color: context.colors.primary.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Text(
                            verse,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLarge.copyWith(
                              color: context.colors.primary,
                              fontFamily: 'Amiri',
                              fontSize: 18.sp,
                              height: 1.8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: context.insets.lg),
                    ],

                    // Full Story Section
                    _SectionTitle(title: 'قصة النبي'),
                    _GlassSection(
                      child: Text(
                        prophet.fullStory,
                        style: AppTypography.bodyLarge.copyWith(
                          color: context.colors.textPrimary,
                          fontSize: 16.sp,
                          height: 1.8,
                        ),
                      ),
                    ),
                    SizedBox(height: context.insets.lg),

                    // Lessons Section
                    if (prophet.lessons.isNotEmpty) ...[
                      _SectionTitle(title: 'الدروس والعبَر'),
                      _GlassSection(
                        child: Column(
                          children: prophet.lessons
                              .map(
                                (lesson) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: context.insets.sm,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Icon(
                                          Icons.verified,
                                          size: 16,
                                          color: context.colors.secondary,
                                        ),
                                      ),
                                      SizedBox(width: context.insets.sm),
                                      Expanded(
                                        child: Text(
                                          lesson,
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                                color:
                                                    context.colors.textPrimary,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(height: context.insets.xl),
                    ],
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.insets.md,
        right: context.insets.md,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: context.insets.sm),
          Text(
            title,
            style: AppTypography.h3.copyWith(color: context.colors.primary),
          ),
        ],
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  final Widget child;
  const _GlassSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(context.corners.xl),
        boxShadow: context.shadows.low,
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.corners.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: EdgeInsets.all(context.insets.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
