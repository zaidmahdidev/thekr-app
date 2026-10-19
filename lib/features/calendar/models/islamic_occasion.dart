import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

enum OccasionKind {
  /// Eid days.
  eid,

  /// Special days and seasons (new year, Ramadan, Arafah...).
  special,

  /// Recommended fasting days.
  fasting,

  /// Weekly sunnah (Friday).
  sunnah;

  String get label {
    switch (this) {
      case OccasionKind.eid:
        return 'عيد';
      case OccasionKind.special:
        return 'مناسبة';
      case OccasionKind.fasting:
        return 'صيام مستحب';
      case OccasionKind.sunnah:
        return 'سنة';
    }
  }

  /// Accent color of the kind, from the app tokens.
  Color color(BuildContext context) {
    switch (this) {
      case OccasionKind.eid:
        return context.colors.secondary;
      case OccasionKind.special:
        return context.colors.primary;
      case OccasionKind.fasting:
        return context.colors.success;
      case OccasionKind.sunnah:
        return context.colors.textSecondary;
    }
  }

  AppIconData get icon {
    switch (this) {
      case OccasionKind.eid:
        return HugeIcons.strokeRoundedPartyPopper;
      case OccasionKind.special:
        return HugeIcons.strokeRoundedStar;
      case OccasionKind.fasting:
        return HugeIcons.strokeRoundedRestaurant01;
      case OccasionKind.sunnah:
        return HugeIcons.strokeRoundedMosque01;
    }
  }
}

/// A Hijri occasion: [month] (1-12) and the days [dayFrom]..[dayTo].
class IslamicOccasion {
  final String title;
  final String note;
  final OccasionKind kind;
  final int month;
  final int dayFrom;
  final int dayTo;

  const IslamicOccasion({
    required this.title,
    required this.note,
    required this.kind,
    required this.month,
    required this.dayFrom,
    int? dayTo,
  }) : dayTo = dayTo ?? dayFrom;

  bool occursOn(int hMonth, int hDay) =>
      hMonth == month && hDay >= dayFrom && hDay <= dayTo;
}
