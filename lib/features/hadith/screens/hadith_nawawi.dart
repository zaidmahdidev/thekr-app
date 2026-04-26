import 'package:flutter/material.dart';
import 'package:thekr_app/features/hadith/data/hadith_nawawi_model.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/features/hadith/widgets/custom_azkar_widget.dart';

@RoutePage()
class HadithNawawiScreen extends StatelessWidget {
  const HadithNawawiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الأربعين النووية',
      body: Scrollbar(
        child: ListView.builder(
          itemCount: hadithNawawi.length,
          itemBuilder: (context, index) {
            final hadith = hadithNawawi[index]['hadith'];
            final description = hadithNawawi[index]['description'];

            return CustomAzkarWidget(details: hadith, bless: description);
          },
        ),
      ),
    );
  }
}
