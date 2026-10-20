import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/services/remote_config_service.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Section a station belongs to; drives the filter chips and the row icon.
enum RadioCategory {
  reciters('القراء', HugeIcons.strokeRoundedMic01),
  mixed('تلاوات متنوعة', HugeIcons.strokeRoundedRadio01),
  adhkar('أذكار وسكينة', HugeIcons.strokeRoundedMoon02),
  knowledge('تفسير وعلوم', HugeIcons.strokeRoundedBook02),
  translations('ترجمات المعاني', HugeIcons.strokeRoundedGlobe02);

  const RadioCategory(this.label, this.icon);

  final String label;
  final AppIconData icon;
}

/// A live audio station. The list is bundled with the app so it shows (and can
/// be searched) without a connection; only playing needs the network.
class RadioStation {
  const RadioStation({
    required this.id,
    required this.name,
    required this.category,
    this.directUrl,
    this.note,
  });

  /// A station on the mp3quran radio network, identified by its stream slug.
  const RadioStation.qurango(
    String slug,
    String name,
    RadioCategory category, {
    String? note,
  }) : this(
         id: slug,
         name: name,
         category: category,
         note: note,
       );

  final String id;
  final String name;
  final RadioCategory category;
  /// Full stream address, for a station that is not on the qurango network.
  final String? directUrl;

  /// Stream address. Qurango stations build it from the base address kept in
  /// Remote Config, so a moved server can be fixed without an app update.
  String get url =>
      directUrl ?? '${RemoteConfigService().radioBaseUrl}/$id';

  /// Short qualifier shown under the name, e.g. "مجوّد" or "رواية ورش".
  final String? note;

  String get subtitle => note ?? category.label;

  /// Name stripped of diacritics and letter variants, for forgiving search.
  String get searchKey => normalizeArabic('$name ${note ?? ''}');

  static final RegExp _marks = RegExp('[ً-ٰٟـ]');

  static String normalizeArabic(String input) {
    return input
        .replaceAll(_marks, '')
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .toLowerCase()
        .trim();
  }

  /// Bundled stations minus the ones switched off remotely.
  static List<RadioStation> get available {
    final disabled = RemoteConfigService().radioDisabledIds;
    if (disabled.isEmpty) return all;
    return all.where((s) => !disabled.contains(s.id)).toList();
  }

  static RadioStation? byId(String? id) {
    if (id == null) return null;
    for (final station in available) {
      if (station.id == id) return station;
    }
    return null;
  }

  static const List<RadioStation> all = [
    // Mixed / general
    RadioStation.qurango(
      'mix',
      'إذاعة القرآن الكريم - متنوعة',
      RadioCategory.mixed,
      note: 'تلاوات لمختلف القراء',
    ),
    RadioStation.qurango(
      'salma',
      'تلاوات خاشعة',
      RadioCategory.mixed,
    ),
    RadioStation.qurango(
      'tarateel',
      'تراتيل قصيرة متميزة',
      RadioCategory.mixed,
    ),
    RadioStation.qurango(
      'albaqarah',
      'سورة البقرة بأصوات القراء',
      RadioCategory.mixed,
    ),
    RadioStation.qurango('Surah_Al-Mulk', 'سورة الملك', RadioCategory.mixed),
    RadioStation.qurango('roqiah', 'الرقية الشرعية', RadioCategory.mixed),
    RadioStation.qurango('eid', 'تكبيرات العيد', RadioCategory.mixed),

    // Reciters
    RadioStation.qurango('mishary_alafasi', 'مشاري العفاسي', RadioCategory.reciters),
    RadioStation.qurango('maher', 'ماهر المعيقلي', RadioCategory.reciters),
    RadioStation.qurango('saud_alshuraim', 'سعود الشريم', RadioCategory.reciters),
    RadioStation.qurango('abdulrahman_alsudaes', 'عبدالرحمن السديس', RadioCategory.reciters),
    RadioStation.qurango('yasser_aldosari', 'ياسر الدوسري', RadioCategory.reciters),
    RadioStation.qurango('saad_alghamdi', 'سعد الغامدي', RadioCategory.reciters),
    RadioStation.qurango('ahmad_alajmy', 'أحمد العجمي', RadioCategory.reciters),
    RadioStation.qurango(
      'abdulbasit_abdulsamad',
      'عبدالباسط عبدالصمد',
      RadioCategory.reciters,
      note: 'مرتّل',
    ),
    RadioStation.qurango(
      'abdulbasit_abdulsamad_mojawwad',
      'عبدالباسط عبدالصمد',
      RadioCategory.reciters,
      note: 'مجوّد',
    ),
    RadioStation.qurango(
      'abdulbasit_abdulsamad_warsh',
      'عبدالباسط عبدالصمد',
      RadioCategory.reciters,
      note: 'رواية ورش',
    ),
    RadioStation.qurango(
      'mohammed_siddiq_alminshawi',
      'محمد صديق المنشاوي',
      RadioCategory.reciters,
      note: 'مرتّل',
    ),
    RadioStation.qurango(
      'mohammed_siddiq_alminshawi_mojawwad',
      'محمد صديق المنشاوي',
      RadioCategory.reciters,
      note: 'مجوّد',
    ),
    RadioStation.qurango(
      'mahmoud_khalil_alhussary',
      'محمود خليل الحصري',
      RadioCategory.reciters,
      note: 'مرتّل',
    ),
    RadioStation.qurango(
      'mahmoud_khalil_alhussary_mojawwad',
      'محمود خليل الحصري',
      RadioCategory.reciters,
      note: 'مجوّد',
    ),
    RadioStation.qurango(
      'mahmoud_ali__albanna',
      'محمود علي البنا',
      RadioCategory.reciters,
      note: 'مرتّل',
    ),
    RadioStation.qurango('mustafa_ismail', 'مصطفى إسماعيل', RadioCategory.reciters),
    RadioStation.qurango('mohammed_ayyub', 'محمد أيوب', RadioCategory.reciters),
    RadioStation.qurango('mohammed_jibreel', 'محمد جبريل', RadioCategory.reciters),
    RadioStation.qurango('mohammad_altablaway', 'محمد الطبلاوي', RadioCategory.reciters),
    RadioStation.qurango('abdullah_aljohany', 'عبدالله عواد الجهني', RadioCategory.reciters),
    RadioStation.qurango('abdullah_basfer', 'عبدالله بصفر', RadioCategory.reciters),
    RadioStation.qurango('abdullah_khayyat', 'عبدالله خياط', RadioCategory.reciters),
    RadioStation.qurango('buajan', 'عبدالله البعيجان', RadioCategory.reciters),
    RadioStation.qurango('abdulmohsen_alqasim', 'عبدالمحسن القاسم', RadioCategory.reciters),
    RadioStation.qurango('abdulmohsin_alharthy', 'عبدالمحسن الحارثي', RadioCategory.reciters),
    RadioStation.qurango('a_binhameed', 'أحمد طالب بن حميد', RadioCategory.reciters),
    RadioStation.qurango('ali_alhuthaifi', 'علي بن عبدالرحمن الحذيفي', RadioCategory.reciters),
    RadioStation.qurango('ali_jaber', 'علي جابر', RadioCategory.reciters),
    RadioStation.qurango('salah_albudair', 'صلاح البدير', RadioCategory.reciters),
    RadioStation.qurango('hani_arrifai', 'هاني الرفاعي', RadioCategory.reciters),
    RadioStation.qurango('nasser_alqatami', 'ناصر القطامي', RadioCategory.reciters),
    RadioStation.qurango('fares_abbad', 'فارس عباد', RadioCategory.reciters),
    RadioStation.qurango('omar_alqazabri', 'عمر القزابري', RadioCategory.reciters),
    RadioStation.qurango('khalid_aljileel', 'خالد الجليل', RadioCategory.reciters),
    RadioStation.qurango('khaled_alqahtani', 'خالد القحطاني', RadioCategory.reciters),
    RadioStation.qurango('ibrahim_alakdar', 'إبراهيم الأخضر', RadioCategory.reciters),
    RadioStation.qurango('ahmad_nauina', 'أحمد نعينع', RadioCategory.reciters),
    RadioStation.qurango('bandar_balilah', 'بندر بليلة', RadioCategory.reciters),
    RadioStation.qurango('bader', 'بدر التركي', RadioCategory.reciters),
    RadioStation.qurango('hazza', 'هزاع البلوشي', RadioCategory.reciters),
    RadioStation.qurango('yasser_alqurashi', 'ياسر القرشي', RadioCategory.reciters),
    RadioStation.qurango('yasser_almazroyee', 'ياسر المزروعي', RadioCategory.reciters),
    RadioStation.qurango('nasser_almajed', 'ناصر الماجد', RadioCategory.reciters),
    RadioStation.qurango('abdulrahman_almajed', 'عبدالرحمن الماجد', RadioCategory.reciters),
    RadioStation.qurango('mohammed_allohaidan', 'محمد اللحيدان', RadioCategory.reciters),
    RadioStation.qurango('waleed_alnaehi', 'وليد النائحي', RadioCategory.reciters),
    RadioStation.qurango('tawfeeq_assayegh', 'توفيق الصايغ', RadioCategory.reciters),
    RadioStation.qurango('majed_alzamel', 'ماجد الزامل', RadioCategory.reciters),
    RadioStation.qurango('zaki_daghistani', 'زكي داغستاني', RadioCategory.reciters),
    RadioStation.qurango('adel_alkhalbany', 'عادل الكلباني', RadioCategory.reciters),
    RadioStation.qurango('abdul_aziz_alahmad', 'عبدالعزيز الأحمد', RadioCategory.reciters),

    // Adhkar
    RadioStation.qurango('athkar_sabah', 'أذكار الصباح', RadioCategory.adhkar),
    RadioStation.qurango('athkar_masa', 'أذكار المساء', RadioCategory.adhkar),
    RadioStation.qurango('sakeenah', 'آيات السكينة', RadioCategory.adhkar),

    // Knowledge
    RadioStation.qurango('tafseer', 'تفسير القرآن الكريم', RadioCategory.knowledge),
    RadioStation.qurango('mukhtasartafsir', 'المختصر في تفسير القرآن', RadioCategory.knowledge),
    RadioStation.qurango('tabri', 'الخلاصة من تفسير الطبري', RadioCategory.knowledge),
    RadioStation.qurango('gareeb-quran', 'تفسير غريب القرآن', RadioCategory.knowledge),
    RadioStation.qurango('alanbiya', 'قصص الأنبياء', RadioCategory.knowledge),
    RadioStation.qurango('sahabah', 'صور من حياة الصحابة والتابعين', RadioCategory.knowledge),
    RadioStation.qurango('fi_zilal_alsiyra', 'في ظلال السيرة النبوية', RadioCategory.knowledge),
    RadioStation.qurango('almukhtasar_fi_alsiyra', 'المختصر في السيرة النبوية', RadioCategory.knowledge),
    RadioStation.qurango('shmaeel', 'الشمائل المحمدية', RadioCategory.knowledge),
    RadioStation.qurango('riyad', 'رياض الصالحين', RadioCategory.knowledge),
    RadioStation.qurango('saheh-bokharee', 'صحيح البخاري', RadioCategory.knowledge),
    RadioStation.qurango('saheh-muslim', 'صحيح مسلم', RadioCategory.knowledge),
    RadioStation.qurango('fatwa', 'الفتاوى العامة', RadioCategory.knowledge),
    RadioStation.qurango('ramadan', 'فضل شهر رمضان', RadioCategory.knowledge),

    // Translations
    RadioStation.qurango(
      'translation_quran_english_basit',
      'ترجمة المعاني - الإنجليزية',
      RadioCategory.translations,
      note: 'English',
    ),
    RadioStation.qurango(
      'translation_quran_french',
      'ترجمة المعاني - الفرنسية',
      RadioCategory.translations,
      note: 'Français',
    ),
    RadioStation.qurango(
      'translation_quran_spanish_afs',
      'ترجمة المعاني - الإسبانية',
      RadioCategory.translations,
      note: 'Español',
    ),
    RadioStation.qurango(
      'translation_quran_german',
      'ترجمة المعاني - الألمانية',
      RadioCategory.translations,
      note: 'Deutsch',
    ),
    RadioStation.qurango(
      'translation_quran_turkish',
      'ترجمة المعاني - التركية',
      RadioCategory.translations,
      note: 'Türkçe',
    ),
    RadioStation.qurango(
      'translation_quran_urdu_basit',
      'ترجمة المعاني - الأوردية',
      RadioCategory.translations,
      note: 'اردو',
    ),
    RadioStation.qurango(
      'translation_quran_Russia',
      'ترجمة المعاني - الروسية',
      RadioCategory.translations,
      note: 'Русский',
    ),
    RadioStation.qurango(
      'translation_quran_farsi',
      'ترجمة المعاني - الفارسية',
      RadioCategory.translations,
      note: 'فارسی',
    ),
  ];
}
