import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../data/umrah_checklist_data.dart';
import '../providers/umrah_checklist_provider.dart';
import '../widgets/umrah_checklist_page.dart';

/// Packing list for the pilgrim, ticks saved on the device.
@RoutePage()
class UmrahChecklistScreen extends StatelessWidget {
  const UmrahChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UmrahChecklistPage(
      groups: UmrahChecklistData.groups,
      provider: umrahChecklistProvider,
    );
  }
}
