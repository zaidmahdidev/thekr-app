import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/umrah/models/umrah_models.dart';

/// Interactive drawing shown in a Hajj lesson.
enum HajjIllustrationKind { mashaar, daySequence, jamarat }

/// A rite inside a day, with the steps to perform it.
class HajjRite {
  const HajjRite({required this.title, required this.steps});

  final String title;
  final List<String> steps;
}

/// One stage of Hajj, written as a lesson. Duas and mistakes reuse the Umrah
/// guide's models, since both guides present them the same way.
class HajjDay {
  const HajjDay({
    required this.number,
    required this.dayLabel,
    required this.title,
    required this.summary,
    required this.icon,
    required this.rites,
    this.duas = const [],
    this.notes = const [],
    this.illustration,
  });

  /// 1-based position of the lesson.
  final int number;

  /// Short date name shown on the map and overview, e.g. "9 ذو الحجة".
  final String dayLabel;
  final String title;
  final String summary;
  final AppIconData icon;
  final List<HajjRite> rites;
  final List<UmrahDua> duas;
  final List<String> notes;
  final HajjIllustrationKind? illustration;
}

/// One of the three ways of performing Hajj.
class HajjType {
  const HajjType({
    required this.title,
    required this.talbiyah,
    required this.how,
    required this.hady,
    required this.exitsIhram,
    required this.icon,
    this.isBest = false,
  });

  final String title;

  /// What the pilgrim says when he makes the intention.
  final String talbiyah;
  final List<String> how;

  /// Whether a sacrifice is owed and a word on it.
  final String hady;
  final String exitsIhram;
  final AppIconData icon;
  final bool isBest;
}

/// A group of special cases (women, the sick, sacrifice, penalties...).
class HajjSpecialTopic {
  const HajjSpecialTopic({
    required this.title,
    required this.icon,
    required this.points,
    required this.source,
  });

  final String title;
  final AppIconData icon;
  final List<String> points;
  final String source;
}
