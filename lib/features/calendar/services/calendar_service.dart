import 'package:hijri/hijri_calendar.dart';
import 'package:thekr_app/features/calendar/models/islamic_occasion.dart';

/// One day of the calendar with everything the UI shows for it.
class CalendarDay {
  final DateTime date;
  final HijriCalendar hijri;
  final List<IslamicOccasion> occasions;

  /// Recommended (non-obligatory) fasting reasons for the day, e.g. Monday.
  final List<String> fastingHints;

  const CalendarDay({
    required this.date,
    required this.hijri,
    required this.occasions,
    required this.fastingHints,
  });

  bool get isFriday => date.weekday == DateTime.friday;
  bool get hasEid => occasions.any((o) => o.kind == OccasionKind.eid);
  bool get hasSpecial => occasions.any((o) => o.kind == OccasionKind.special);
  bool get hasFasting => fastingHints.isNotEmpty;
}

/// A coming occasion with the number of days left.
class UpcomingOccasion {
  final IslamicOccasion occasion;
  final DateTime date;
  final HijriCalendar hijri;
  final int daysLeft;

  const UpcomingOccasion({
    required this.occasion,
    required this.date,
    required this.hijri,
    required this.daysLeft,
  });
}

/// Hijri / Gregorian calendar logic and the list of Islamic occasions.
///
/// Dates follow the Umm al-Qura calendar used by the `hijri` package, so a
/// date can differ by a day from the actual moon sighting in some countries.
class CalendarService {
  CalendarService._();

  static const int minHijriYear = 1357;
  static const int maxHijriYear = 1500;

  static const List<String> weekdayNames = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  static const List<String> gregorianMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static const List<IslamicOccasion> occasions = [
    IslamicOccasion(
      title: 'رأس السنة الهجرية',
      note: 'بداية العام الهجري الجديد.',
      kind: OccasionKind.special,
      month: 1,
      dayFrom: 1,
    ),
    IslamicOccasion(
      title: 'تاسوعاء وعاشوراء',
      note:
          'يُستحب صيام التاسع والعاشر من المحرّم، وصيام عاشوراء يكفّر السنة الماضية.',
      kind: OccasionKind.fasting,
      month: 1,
      dayFrom: 9,
      dayTo: 10,
    ),
    IslamicOccasion(
      title: 'بداية شهر رمضان',
      note: 'شهر الصيام والقرآن، أعاننا الله على صيامه وقيامه.',
      kind: OccasionKind.special,
      month: 9,
      dayFrom: 1,
    ),
    IslamicOccasion(
      title: 'العشر الأواخر من رمضان',
      note: 'تُلتمس ليلة القدر في الليالي الوتر منها، فأكثر من الدعاء والقيام.',
      kind: OccasionKind.special,
      month: 9,
      dayFrom: 21,
      dayTo: 30,
    ),
    IslamicOccasion(
      title: 'عيد الفطر المبارك',
      note: 'تقبّل الله منا ومنكم. لا يجوز صيام يوم العيد.',
      kind: OccasionKind.eid,
      month: 10,
      dayFrom: 1,
    ),
    IslamicOccasion(
      title: 'صيام ست من شوال',
      note: 'من صام رمضان ثم أتبعه ستاً من شوال كان كصيام الدهر.',
      kind: OccasionKind.fasting,
      month: 10,
      dayFrom: 2,
      dayTo: 7,
    ),
    IslamicOccasion(
      title: 'العشر من ذي الحجة',
      note:
          'أفضل أيام الدنيا؛ يُستحب فيها الإكثار من العمل الصالح والذكر والصيام.',
      kind: OccasionKind.special,
      month: 12,
      dayFrom: 1,
      dayTo: 9,
    ),
    IslamicOccasion(
      title: 'يوم عرفة',
      note: 'يُستحب صيامه لغير الحاج، وهو يكفّر السنة الماضية والباقية.',
      kind: OccasionKind.fasting,
      month: 12,
      dayFrom: 9,
    ),
    IslamicOccasion(
      title: 'عيد الأضحى المبارك',
      note: 'تقبّل الله منا ومنكم. يوم النحر وأعظم أيام العام. لا يجوز صيامه.',
      kind: OccasionKind.eid,
      month: 12,
      dayFrom: 10,
    ),
    IslamicOccasion(
      title: 'أيام التشريق',
      note: 'أيام أكل وشرب وذكر لله، ولا يجوز صيامها.',
      kind: OccasionKind.special,
      month: 12,
      dayFrom: 11,
      dayTo: 13,
    ),
  ];

  // ------------------------------------------------------------- conversion

  static HijriCalendar hijriOf(DateTime date) {
    HijriCalendar.setLocal('ar');
    return HijriCalendar.fromDate(date);
  }

  static int daysInHijriMonth(int year, int month) =>
      HijriCalendar().getDaysInMonth(year, month);

  static DateTime gregorianOf(int hYear, int hMonth, int hDay) =>
      HijriCalendar().hijriToGregorian(hYear, hMonth, hDay);

  static String hijriMonthName(int month) {
    HijriCalendar.setLocal('ar');
    final h = HijriCalendar()
      ..hYear = 1447
      ..hMonth = month
      ..hDay = 1;
    return h.getLongMonthName();
  }

  // ------------------------------------------------------------------- days

  static CalendarDay day(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final hijri = hijriOf(d);
    final list = occasions
        .where((o) => o.occursOn(hijri.hMonth, hijri.hDay))
        .toList();
    return CalendarDay(
      date: d,
      hijri: hijri,
      occasions: list,
      fastingHints: _fastingHints(d, hijri, list),
    );
  }

  /// Recommended fasting for a day, with the forbidden days excluded.
  static List<String> _fastingHints(
    DateTime date,
    HijriCalendar hijri,
    List<IslamicOccasion> todays,
  ) {
    final m = hijri.hMonth;
    final d = hijri.hDay;

    // Ramadan is obligatory; Eid and Tashreeq days must not be fasted.
    final isRamadan = m == 9;
    final isForbidden = (m == 10 && d == 1) || (m == 12 && d >= 10 && d <= 13);
    if (isRamadan || isForbidden) return const [];

    final hints = <String>[];
    if (date.weekday == DateTime.monday) hints.add('صيام يوم الاثنين');
    if (date.weekday == DateTime.thursday) hints.add('صيام يوم الخميس');
    if (d >= 13 && d <= 15) hints.add('الأيام البيض');
    return hints;
  }

  // ------------------------------------------------------------------ month

  /// Cells of a month grid starting on Saturday: `null` for the empty slots
  /// before the first day.
  static List<DateTime?> hijriMonthCells(int year, int month) {
    final first = gregorianOf(year, month, 1);
    final count = daysInHijriMonth(year, month);
    return [
      ...List<DateTime?>.filled(_saturdayIndex(first), null),
      for (int i = 0; i < count; i++)
        DateTime(first.year, first.month, first.day + i),
    ];
  }

  static List<DateTime?> gregorianMonthCells(int year, int month) {
    final first = DateTime(year, month, 1);
    final count = DateTime(year, month + 1, 0).day;
    return [
      ...List<DateTime?>.filled(_saturdayIndex(first), null),
      for (int i = 1; i <= count; i++) DateTime(year, month, i),
    ];
  }

  /// Saturday = 0 ... Friday = 6.
  static int _saturdayIndex(DateTime date) => (date.weekday + 1) % 7;

  // --------------------------------------------------------------- upcoming

  /// The next [limit] special days (eid and seasons), starting from [from].
  static List<UpcomingOccasion> upcoming(DateTime from, {int limit = 4}) {
    final start = DateTime(from.year, from.month, from.day);
    final result = <UpcomingOccasion>[];
    final seen = <String>{};

    for (int i = 0; i <= 400 && result.length < limit; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      final hijri = hijriOf(date);
      for (final o in occasions) {
        if (o.kind == OccasionKind.fasting) continue;
        if (hijri.hMonth == o.month &&
            hijri.hDay == o.dayFrom &&
            seen.add(o.title)) {
          result.add(
            UpcomingOccasion(
              occasion: o,
              date: date,
              hijri: hijri,
              daysLeft: i,
            ),
          );
        }
      }
    }
    return result;
  }
}
