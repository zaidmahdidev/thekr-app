import 'package:flutter/material.dart';
import 'package:thekr_app/features/husn_al_muslim/data/husin_almuslim_model.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/router/app_router.dart';

@RoutePage()
class HusinAlMuslimScreen extends StatelessWidget {
  const HusinAlMuslimScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'حُصن المسلم',
      body: ListView.builder(
        itemCount: husinAlMuslim.length,
        itemBuilder: (context, index) {
          String key = husinAlMuslim.keys.elementAt(index);
          return CustomCard(
            fun: () {
              context.router.push(
                HusinAlMuslimDetailsRoute(
                  title: key,
                  dhikrData: husinAlMuslim[key]!,
                ),
              );
            },
            leading: '${index + 1}',
            title: key,
          );
        },
      ),
    );
  }
}
