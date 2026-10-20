import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../data/umrah_intro_data.dart';
import '../widgets/umrah_mistakes_page.dart';

/// Mistakes many pilgrims make in Umrah, each with the correct way next to it.
@RoutePage()
class UmrahMistakesScreen extends StatelessWidget {
  const UmrahMistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UmrahMistakesPage(mistakes: UmrahIntroData.mistakes);
  }
}
