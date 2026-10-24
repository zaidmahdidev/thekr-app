import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_checklist_page.dart';
import '../data/hajj_checklist_data.dart';
import '../providers/hajj_providers.dart';

/// Packing list for the pilgrim, ticks saved on the device.
@RoutePage()
class HajjChecklistScreen extends StatelessWidget {
  const HajjChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UmrahChecklistPage(
      groups: HajjChecklistData.groups,
      provider: hajjChecklistProvider,
    );
  }
}
