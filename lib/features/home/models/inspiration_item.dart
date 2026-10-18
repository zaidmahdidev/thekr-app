import 'package:flutter/material.dart';

enum InspirationType {
  ayah,
  hadith,
  dhikr;

  String get label {
    switch (this) {
      case InspirationType.ayah:
        return 'آية اليوم';
      case InspirationType.hadith:
        return 'حديث اليوم';
      case InspirationType.dhikr:
        return 'ذكر اليوم';
    }
  }

  IconData get icon {
    switch (this) {
      case InspirationType.ayah:
        return Icons.auto_stories_rounded;
      case InspirationType.hadith:
        return Icons.format_quote_rounded;
      case InspirationType.dhikr:
        return Icons.auto_awesome_rounded;
    }
  }
}

/// Location of a verse in the Mushaf, used to draw it with the page font.
class AyahRef {
  final int surah;
  final int ayah;
  final int page;

  const AyahRef({required this.surah, required this.ayah, required this.page});
}

/// One daily inspiration (verse, hadith or dhikr) shown on the home screen.
class InspirationItem {
  final InspirationType type;

  /// Main text shown on the card, in the details sheet and when shared.
  final String content;

  /// Short line under the text on the card (source or virtue).
  final String footer;

  /// Source line used on the shared image and in the details sheet.
  final String source;

  /// Optional longer explanation, shown in the details sheet only.
  final String? note;

  /// Set for verses only.
  final AyahRef? ayah;

  const InspirationItem({
    required this.type,
    required this.content,
    required this.footer,
    required this.source,
    this.note,
    this.ayah,
  });
}
