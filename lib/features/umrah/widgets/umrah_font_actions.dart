import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

/// Zoom in / zoom out buttons for an app bar, changing the same app-wide font
/// size the adhkar screens use.
List<Widget> umrahFontActions(WidgetRef ref) {
  void change(double delta) {
    final current = ref.read(settingsProvider).fontSize;
    final next = (current + delta).clamp(14.0, 26.0);
    if (next != current) {
      ref.read(settingsProvider.notifier).updateFontSize(next);
    }
  }

  return [
    IconButton(
      tooltip: 'تكبير الخط',
      icon: const AppIcon(HugeIcons.strokeRoundedZoomIn),
      onPressed: () => change(2),
    ),
    IconButton(
      tooltip: 'تصغير الخط',
      icon: const AppIcon(HugeIcons.strokeRoundedZoomOut),
      onPressed: () => change(-2),
    ),
  ];
}
