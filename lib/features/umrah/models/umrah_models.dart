import 'package:thekr_app/core/widgets/app_icon.dart';

/// A dua or dhikr with where it comes from, so the user can tell a verse or an
/// authentic hadith from general guidance.
class UmrahDua {
  const UmrahDua({required this.title, required this.text, required this.source});

  final String title;
  final String text;
  final String source;
}

/// Interactive drawing shown in a lesson.
enum UmrahIllustrationKind { ihram, tawaf, sai }

/// One rite of Umrah, in the order it is performed.
class UmrahStep {
  const UmrahStep({
    required this.number,
    required this.title,
    required this.summary,
    required this.icon,
    required this.how,
    this.duas = const [],
    this.notes = const [],
    this.illustration,
  });

  /// 1-based position in the order the rites are performed.
  final int number;
  final String title;
  final String summary;
  final AppIconData icon;

  /// What to do, in order.
  final List<String> how;
  final List<UmrahDua> duas;
  final List<String> notes;

  /// Drawing that goes with this rite, if there is one.
  final UmrahIllustrationKind? illustration;
}

/// Who a miqat is for and where it is today.
class MiqatAnswer {
  const MiqatAnswer({
    required this.title,
    required this.place,
    required this.details,
    required this.evidence,
  });

  final String title;

  /// Where to ihram, in today's terms.
  final String place;
  final List<String> details;

  /// The text the ruling rests on.
  final String evidence;
}

/// How the pilgrim is arriving, which decides where the ihram is put on.
enum MiqatGroup {
  land('براً وبحراً'),
  air('جواً'),
  resident('مقيم قريب');

  const MiqatGroup(this.label);

  final String label;
}

/// One of the five miqats, placed on the schematic by its direction from Makkah.
class MiqatSpot {
  const MiqatSpot({
    required this.id,
    required this.name,
    required this.bearing,
  });

  final String id;
  final String name;

  /// Degrees clockwise from north, as seen from Makkah. Approximate; the
  /// schematic is for orientation only.
  final double bearing;
}

/// A traveller situation the miqat finder asks about.
class MiqatOrigin {
  const MiqatOrigin({
    required this.group,
    required this.label,
    required this.hint,
    required this.icon,
    required this.answer,
    this.spotId,
  });

  final MiqatGroup group;
  final String label;
  final String hint;
  final AppIconData icon;
  final MiqatAnswer answer;

  /// The miqat on the schematic this answer points to, if it is one of the five.
  final String? spotId;
}

enum ProhibitionGroup {
  everyone('على الجميع'),
  men('على الرجال فقط'),
  women('على النساء فقط');

  const ProhibitionGroup(this.label);

  final String label;
}

class Prohibition {
  const Prohibition({
    required this.group,
    required this.title,
    required this.detail,
    required this.icon,
  });

  final ProhibitionGroup group;
  final String title;
  final String detail;
  final AppIconData icon;
}

class ChecklistItem {
  const ChecklistItem({required this.id, required this.label, this.hint});

  final String id;
  final String label;
  final String? hint;
}

class ChecklistGroup {
  const ChecklistGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final AppIconData icon;
  final List<ChecklistItem> items;
}

/// A common mistake and the correct way, shown side by side.
class UmrahMistake {
  const UmrahMistake({required this.wrong, required this.right});

  final String wrong;
  final String right;
}

/// A statement of virtue with the text it comes from.
class UmrahVirtue {
  const UmrahVirtue({required this.text, required this.source});

  final String text;
  final String source;
}

/// A pillar or obligation of Umrah, explained in a line.
class UmrahPillar {
  const UmrahPillar({
    required this.title,
    required this.meaning,
    required this.kind,
    required this.icon,
  });

  final String title;
  final String meaning;

  /// "ركن" or "واجب".
  final String kind;
  final AppIconData icon;
}
