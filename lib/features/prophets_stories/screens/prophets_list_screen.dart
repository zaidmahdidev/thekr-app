import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/tokens/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../data/prophets_data.dart';
import '../widgets/prophet_grid_item.dart';

@RoutePage()
class ProphetsListScreen extends StatelessWidget {
  const ProphetsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'قصص الأنبياء',
      body: GridView.builder(
        padding: EdgeInsets.all(context.insets.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: context.insets.sm,
          mainAxisSpacing: context.insets.sm,
        ),
        itemCount: ProphetsData.stories.length,
        itemBuilder: (context, index) {
          final prophet = ProphetsData.stories[index];
          return ProphetGridItem(prophet: prophet);
        },
      ),
    );
  }
}

