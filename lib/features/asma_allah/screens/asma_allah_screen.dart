import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/features/asma_allah/data/asma_allah_data.dart';
import 'package:thekr_app/features/asma_allah/widgets/asma_allah_grid_item.dart';

@RoutePage()
class AsmaAllahScreen extends StatelessWidget {
  const AsmaAllahScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Standard Dart mapping to ensure reliability without external dependencies
    final List<AsmaAllah> asmaAllahList = asmaAllah.entries
        .toList()
        .asMap()
        .entries
        .map((e) => AsmaAllah.fromMapEntry(e.value, e.key))
        .toList();

    return AppScaffold(
      title: 'أسماء الله الحسنى',
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Quranic Verse Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: context.insets.xl,
                bottom: context.insets.lg,
                left: context.insets.lg,
                right: context.insets.lg,
              ),
              child: Column(
                children: [
                  Text(
                    'وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا',
                    textAlign: TextAlign.center,
                    style: context.textStyles.headlineMedium?.copyWith(
                      fontFamily: 'hafs',
                      color: context.colors.primary,
                      height: 1.5,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: context.insets.sm),
                  Container(
                    width: 40.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: context.colors.secondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(context.corners.sm),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid of Names
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: context.insets.md),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: context.insets.sm,
                mainAxisSpacing: context.insets.sm,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return AsmaAllahGridItem(item: asmaAllahList[index]);
              }, childCount: asmaAllahList.length),
            ),
          ),

          // Bottom spacing to respect design system
          SliverToBoxAdapter(child: SizedBox(height: context.insets.xl)),
        ],
      ),
    );
  }
}
