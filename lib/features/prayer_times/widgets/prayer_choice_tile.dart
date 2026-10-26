import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/settings/widgets/settings_tile.dart';

/// One option of a single-choice list: a tick when chosen, an empty circle
/// otherwise. Same row as the rest of the settings.
class PrayerChoiceTile extends StatelessWidget {
  const PrayerChoiceTile({
    super.key,
    required this.title,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SettingsTile(
      title: title,
      subtitle: detail,
      icon: selected
          ? HugeIcons.strokeRoundedCheckmarkCircle02
          : HugeIcons.strokeRoundedCircle,
      iconColor: selected ? colors.primary : colors.textSecondary,
      onTap: onTap,
      trailing: const SizedBox.shrink(),
    );
  }
}
