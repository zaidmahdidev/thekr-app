import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/theme/tokens/app_fonts.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../data/prophets_data.dart';
import '../models/prophet_story.dart';
import '../widgets/prophet_grid_item.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

@RoutePage()
class ProphetsListScreen extends StatefulWidget {
  const ProphetsListScreen({super.key});

  @override
  State<ProphetsListScreen> createState() => _ProphetsListScreenState();
}

class _ProphetsListScreenState extends State<ProphetsListScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<ProphetStory> get _filtered {
    final query = _controller.text.trim();
    if (query.isEmpty) return ProphetsData.stories;
    return ProphetsData.stories
        .where((p) => p.name.contains(query) || p.title.contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      title: 'قصص الأنبياء',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.insets.md,
              context.insets.md,
              context.insets.md,
              context.insets.sm,
            ),
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              style: context.textStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'ابحث عن نبي...',
                prefixIcon: const AppIcon(HugeIcons.strokeRoundedSearch01),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'مسح',
                        icon: const AppIcon(HugeIcons.strokeRoundedCancel01),
                        onPressed: () => setState(_controller.clear),
                      ),
                filled: true,
                fillColor: context.colors.surface,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.corners.xl),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد نتائج',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      const columns = 3;
                      final spacing = context.insets.sm;
                      final cellWidth =
                          (constraints.maxWidth -
                              context.insets.md * 2 -
                              spacing * (columns - 1)) /
                          columns;
                      // As tall as the content (circle, name, a two-line
                      // title), which grows with the system font size. Never
                      // shorter than the old shape.
                      final textScale = MediaQuery.textScalerOf(
                        context,
                      ).scale(1);
                      final lines =
                          (13.sp * AppFonts.lineHeight + 2 * 11.sp * 1.2) *
                          textScale;
                      final content =
                          context.insets.sm * 2 +
                          48.w +
                          context.insets.sm +
                          lines +
                          2.h;
                      final cellHeight =
                          content + context.insets.sm > cellWidth / 0.75
                          ? content + context.insets.sm
                          : cellWidth / 0.75;
                      return GridView.builder(
                        padding: EdgeInsets.all(context.insets.md),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: cellHeight,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            ProphetGridItem(prophet: items[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
