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
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('أذكار المسلم')),
      body: ListView.builder(
        itemCount: azkarList.length,
        itemBuilder: (context, index) {
          String key = azkarList.keys.elementAt(index);

          return CustomContainer(
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
