import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Round arrow button used to move between days and months (same look as the
/// calendar's navigation buttons).
class PrayerNavButton extends StatelessWidget {
  const PrayerNavButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final AppIconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: context.colors.primary.withValues(alpha: 0.1),
      ),
      icon: AppIcon(icon, color: context.colors.primary),
    );
  }
}
