import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_extension.dart';
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
