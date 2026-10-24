import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_mistakes_page.dart';
import '../data/hajj_special_data.dart';

/// Mistakes many pilgrims make in Hajj, each with the correct way next to it.
@RoutePage()
class HajjMistakesScreen extends StatelessWidget {
  const HajjMistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UmrahMistakesPage(mistakes: HajjSpecialData.mistakes);
  }
}
