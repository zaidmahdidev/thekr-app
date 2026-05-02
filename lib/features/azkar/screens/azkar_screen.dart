import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:thekr_app/features/azkar/data/azkar_model.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/core/router/app_router.dart';

@RoutePage()
class AzkarScreen extends StatelessWidget {
  const AzkarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> categories = azkarList.keys.cast<String>().toList();

    return AppScaffold(
      title: 'أذكار المسلم',
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final String key = categories[index];

          return CustomCard(
            leading: '${index + 1}',
            title: key,
            fun: () {
              context.router.push(
                AzkarListRoute(azkarList: azkarList[key]!, type: key),
              );
            },
          );
        },
      ),
    );
  }
}
