import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/features/umrah/models/umrah_models.dart';

/// Background a pilgrim should know before the rites. The rulings follow the
/// fatwas of Shaykh Ibn Baz (binbaz.org.sa) and the Permanent Committee, and
/// the schedule and numbers follow the Saudi Press Agency's Hajj coverage.
class HajjIntroData {
  HajjIntroData._();

  static const String meaning =
      'الحج في اللغة: القصد. وفي الشرع: قصد مكة المكرمة والمشاعر المقدسة في '
      'أيام مخصوصة لأداء مناسك مخصوصة، تبدأ بالإحرام وتنتهي بطواف الوداع.';

  static const String ruling =
      'الحج هو الركن الخامس من أركان الإسلام، وهو واجب على المسلم المكلّف '
      'المستطيع مرة واحدة في العمر. والواجب على من استطاع أن يبادر به ولا يؤخره.';

  static const UmrahDua ruleVerse = UmrahDua(
    title: 'فرضية الحج',
    text:
        'وَلِلَّهِ عَلَى النَّاسِ حِجُّ الْبَيْتِ مَنِ اسْتَطَاعَ إِلَيْهِ سَبِيلًا',
    source: 'سورة آل عمران: 97',
  );

  static const List<String> conditions = [
    'الإسلام والعقل والبلوغ.',
    'الاستطاعة: القدرة على نفقة الحج والسفر، وعلى السفر بدنياً.',
    'للمرأة محرم يسافر معها، على ما أفتى به ابن باز واللجنة الدائمة.',
  ];

  static const String timing =
      'للحج أشهر معلومات هي شوال وذو القعدة وعشر من ذي الحجة. وأعمال الحج '
      'الرئيسة تقع في الأيام من الثامن إلى الثالث عشر من ذي الحجة.';

  static const List<UmrahVirtue> virtues = [
    UmrahVirtue(
      text:
          'مَنْ حَجَّ فَلَمْ يَرْفُثْ وَلَمْ يَفْسُقْ رَجَعَ كَيَوْمِ وَلَدَتْهُ أُمُّهُ',
      source: 'متفق عليه',
    ),
    UmrahVirtue(
      text:
          'وَالْحَجُّ الْمَبْرُورُ لَيْسَ لَهُ جَزَاءٌ إِلَّا الْجَنَّةُ',
      source: 'متفق عليه',
    ),
  ];

  static const UmrahDua noObscenityVerse = UmrahDua(
    title: 'آداب الحاج',
    text:
        'الْحَجُّ أَشْهُرٌ مَعْلُومَاتٌ فَمَنْ فَرَضَ فِيهِنَّ الْحَجَّ فَلَا رَفَثَ وَلَا فُسُوقَ وَلَا جِدَالَ فِي الْحَجِّ',
    source: 'سورة البقرة: 197',
  );

  static const String pillarsNote =
      'من ترك ركناً لم يصحّ حجه. ومن ترك واجباً لزمه دم (ذبح شاة في مكة للفقراء) '
      'إلا أن يكون له عذر شرعي. وهذا التصنيف على ما أفتى به الشيخ ابن باز رحمه الله.';

  static const List<UmrahPillar> pillars = [
    UmrahPillar(
      title: 'الإحرام بالحج',
      meaning: 'نيّة الدخول في الحج في القلب.',
      kind: 'ركن',
      icon: HugeIcons.strokeRoundedShirt01,
    ),
    UmrahPillar(
      title: 'الوقوف بعرفة',
      meaning: 'الحضور في عرفة وقت الوقوف. قال ﷺ: «الحج عرفة».',
      kind: 'ركن',
      icon: HugeIcons.strokeRoundedMountain,
    ),
    UmrahPillar(
      title: 'طواف الإفاضة',
      meaning: 'الطواف بالبيت سبعاً بعد الوقوف بعرفة، ويسمى طواف الزيارة.',
      kind: 'ركن',
      icon: HugeIcons.strokeRoundedMosque01,
    ),
    UmrahPillar(
      title: 'السعي',
      meaning: 'المشي بين الصفا والمروة سبعة أشواط.',
      kind: 'ركن',
      icon: HugeIcons.strokeRoundedWalking,
    ),
    UmrahPillar(
      title: 'الإحرام من الميقات',
      meaning: 'أن تحرم من الميقات الذي تمر عليه.',
      kind: 'واجب',
      icon: HugeIcons.strokeRoundedLocation01,
    ),
    UmrahPillar(
      title: 'البقاء في عرفة إلى الغروب',
      meaning: 'لمن وقف نهاراً، فلا ينصرف قبل غروب الشمس.',
      kind: 'واجب',
      icon: HugeIcons.strokeRoundedSun03,
    ),
    UmrahPillar(
      title: 'المبيت بمزدلفة',
      meaning: 'المبيت بها بعد الانصراف من عرفة حتى صلاة الفجر.',
      kind: 'واجب',
      icon: HugeIcons.strokeRoundedMoon02,
    ),
    UmrahPillar(
      title: 'رمي الجمار',
      meaning: 'رمي جمرة العقبة يوم العيد، والجمرات الثلاث في أيام التشريق.',
      kind: 'واجب',
      icon: HugeIcons.strokeRoundedTarget02,
    ),
    UmrahPillar(
      title: 'المبيت بمنى',
      meaning: 'في ليلتي الحادي عشر والثاني عشر، وليلة الثالث عشر لمن لم يتعجل.',
      kind: 'واجب',
      icon: HugeIcons.strokeRoundedTent,
    ),
    UmrahPillar(
      title: 'الحلق أو التقصير',
      meaning: 'للرجل الحلق أو التقصير، وللمرأة التقصير.',
      kind: 'واجب',
      icon: HugeIcons.strokeRoundedScissor,
    ),
    UmrahPillar(
      title: 'طواف الوداع',
      meaning: 'لمن أراد مغادرة مكة بعد أعمال الحج.',
      kind: 'واجب',
      icon: HugeIcons.strokeRoundedDoor01,
    ),
  ];

  /// How the pilgrim is expected to prepare, in the Ministry's own words only
  /// where they are stable across seasons.
  static const String permitNote =
      'الحج في المملكة يتطلب تصريحاً رسمياً يُستخرج عبر منصة «نسك». وقد أكدت وزارة '
      'الحج والعمرة أن محاولة الحج بلا تصريح مخالفة للأنظمة. وتتغير الشروط '
      'والمواعيد من موسم إلى آخر، فراجع المصدر الرسمي قبل أن تحجز.';

  static const String nusukUrl = 'https://www.nusuk.sa';
  static const String ministryUrl = 'https://haj.gov.sa';
}
