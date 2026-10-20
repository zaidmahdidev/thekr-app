import 'package:hugeicons/hugeicons.dart';
import '../models/umrah_models.dart';

/// The five miqats were set by the Prophet ﷺ in the hadith of Ibn Abbas
/// (Sahih al-Bukhari and Sahih Muslim). Distances are left out on purpose:
/// sources differ on them, and the person only needs to know the place.
class UmrahMiqatData {
  UmrahMiqatData._();

  /// Where the modern names and the approximate distances come from.
  static const String locationsNote =
      'أسماء المواقيت اليوم ومواقعها ومسافاتها التقريبية مأخوذة من وكالة الأنباء '
      'السعودية (قسم الحج)، وتتفاوت المصادر في أرقام المسافات قليلاً. '
      'والمخطط للاتجاهات فقط، وبينها تباعد لسهولة القراءة.';

  static const String generalEvidence =
      'عن ابن عباس رضي الله عنهما: «وقّت رسول الله ﷺ لأهل المدينة ذا الحليفة، '
      'ولأهل الشام الجحفة، ولأهل نجد قرن المنازل، ولأهل اليمن يلملم، '
      'وهنّ لهنّ ولمن أتى عليهنّ من غيرهنّ ممن أراد الحج والعمرة» — متفق عليه.';

  static const List<MiqatSpot> spots = [
    MiqatSpot(id: 'hulayfah', name: 'ذو الحليفة', bearing: 350),
    MiqatSpot(id: 'juhfah', name: 'الجحفة', bearing: 305),
    MiqatSpot(id: 'irq', name: 'ذات عرق', bearing: 38),
    MiqatSpot(id: 'qarn', name: 'قرن المنازل', bearing: 85),
    MiqatSpot(id: 'yalamlam', name: 'يلملم', bearing: 172),
  ];

  static const List<MiqatOrigin> origins = [
    MiqatOrigin(
      label: 'من المدينة المنورة',
      group: MiqatGroup.land,
      spotId: 'hulayfah',
      hint: 'وما يمرّ بطريقها',
      icon: HugeIcons.strokeRoundedMosque03,
      answer: MiqatAnswer(
        title: 'ذو الحليفة',
        place: 'أبيار علي، قرب المدينة المنورة، ونحو 450 كم من مكة المكرمة',
        details: [
          'هو ميقات أهل المدينة ومن يمر به من غيرهم.',
          'هو أبعد المواقيت عن مكة.',
        ],
        evidence: 'حديث ابن عباس في الصحيحين: «ولأهل المدينة ذو الحليفة».',
      ),
    ),
    MiqatOrigin(
      label: 'من الشام ومصر والمغرب',
      group: MiqatGroup.land,
      spotId: 'juhfah',
      hint: 'وبقية إفريقيا عبر طريق رابغ',
      icon: HugeIcons.strokeRoundedRoute01,
      answer: MiqatAnswer(
        title: 'الجحفة',
        place: 'قرب مدينة رابغ، شمال غربي مكة ونحو 180 كم منها',
        details: [
          'هو ميقات أهل الشام، ويمرّ به القادمون من مصر والمغرب وعموم إفريقيا برّاً.',
          'اندثرت الجحفة القديمة، فيحرم الناس اليوم من رابغ وهي قبلها بقليل، وإحرامهم منها صحيح.',
          'إن مررت به وأنت في الطائرة فأحرم عند محاذاته.',
        ],
        evidence: 'حديث ابن عباس في الصحيحين: «ولأهل الشام الجحفة».',
      ),
    ),
    MiqatOrigin(
      label: 'من نجد والطائف والخليج',
      group: MiqatGroup.land,
      spotId: 'qarn',
      hint: 'ومن يأتي من الجهة الشرقية',
      icon: HugeIcons.strokeRoundedLocation01,
      answer: MiqatAnswer(
        title: 'قرن المنازل',
        place: 'السيل الكبير، على طريق الطائف ونحو 75 كم من مكة',
        details: [
          'هو ميقات أهل نجد ومن يمر به من الخليج ومن الطائف.',
          'يُعرف اليوم بالسيل الكبير، ويحرم القادمون من الطائف وجنوب المملكة من وادي محرم في أعلى السيل.',
        ],
        evidence: 'حديث ابن عباس في الصحيحين: «ولأهل نجد قرن المنازل».',
      ),
    ),
    MiqatOrigin(
      label: 'من اليمن والجنوب',
      group: MiqatGroup.land,
      spotId: 'yalamlam',
      hint: 'وتهامة وما يمر بطريقها',
      icon: HugeIcons.strokeRoundedNavigation03,
      answer: MiqatAnswer(
        title: 'يلملم',
        place: 'السعدية، جنوب مكة على طريق اليمن ونحو 130 كم منها',
        details: [
          'هو ميقات أهل اليمن ومن يمر به من الجنوب.',
          'يُعرف اليوم بالسعدية.',
        ],
        evidence: 'حديث ابن عباس في الصحيحين: «ولأهل اليمن يلملم».',
      ),
    ),
    MiqatOrigin(
      label: 'من العراق والمشرق',
      group: MiqatGroup.land,
      spotId: 'irq',
      hint: 'وشمال شرق المملكة',
      icon: HugeIcons.strokeRoundedCompass01,
      answer: MiqatAnswer(
        title: 'ذات عرق',
        place: 'الضريبة، شمال شرقي مكة ونحو 90 إلى 100 كم منها',
        details: [
          'هو ميقات أهل العراق ومن يمر به من المشرق.',
          'يُعرف اليوم بالضريبة.',
        ],
        evidence:
            'ثبت من حديث عائشة رضي الله عنها (رواه أبو داود والنسائي). وفي صحيح مسلم عن جابر مع شك الراوي في رفعه. وحدّه عمر رضي الله عنه لأهل العراق كما في صحيح البخاري.',
      ),
    ),
    MiqatOrigin(
      label: 'قادم بالطائرة',
      group: MiqatGroup.air,
      hint: 'من خارج المملكة إلى جدة أو المدينة',
      icon: HugeIcons.strokeRoundedAirplane01,
      answer: MiqatAnswer(
        title: 'عند محاذاة أقرب ميقات',
        place: 'أثناء الرحلة، قبل الوصول إلى جدة',
        details: [
          'انوِ الإحرام عند محاذاة الميقات أو قبلها بقليل احتياطاً لسرعة الطائرة. وكثيراً ما يُنبّه الطيار إلى ذلك.',
          'الأيسر أن تغتسل وتلبس ثياب الإحرام قبل الإقلاع أو في المطار، وتنوي عند المحاذاة.',
          'جدة ميقات لأهلها والمقيمين بها فقط. فلا تؤخّر إحرامك إليها إن حاذيت ميقاتاً قبلها. ويحرم منها من لم يحاذِ ميقاتاً قبل وصوله إليها.',
          'إن كنت ستنزل المدينة أولاً فأحرم من ذي الحليفة عند خروجك منها.',
        ],
        evidence: 'فتاوى الشيخ عبدالعزيز بن باز رحمه الله في إحرام القادم جواً وفي أن جدة ليست ميقاتاً للوافدين.',
      ),
    ),
    MiqatOrigin(
      label: 'أسكن في جدة أو بين الميقات ومكة',
      group: MiqatGroup.resident,
      hint: 'ومن داخل حدود المواقيت',
      icon: HugeIcons.strokeRoundedHotel01,
      answer: MiqatAnswer(
        title: 'من مكان سكنك',
        place: 'من بيتك أو مقر إقامتك',
        details: [
          'من كان مسكنه دون الميقات أحرم من مسكنه.',
          'هذا لمن كان مقيماً هناك، لا للقادم من خارج المملكة.',
        ],
        evidence: 'حديث ابن عباس في الصحيحين: «ومن كان دونهن فمن أهله».',
      ),
    ),
    MiqatOrigin(
      label: 'أقيم في مكة المكرمة',
      group: MiqatGroup.resident,
      hint: 'وأريد أداء العمرة',
      icon: HugeIcons.strokeRoundedMosque02,
      answer: MiqatAnswer(
        title: 'من أدنى الحِلّ',
        place: 'خارج حدود الحرم، كالتنعيم',
        details: [
          'يخرج المقيم في مكة إلى الحِلّ، أي خارج حدود الحرم، ثم يحرم بالعمرة.',
          'أشهر مواضع الإحرام لأهل مكة التنعيم، وفيه مسجد عائشة رضي الله عنها.',
        ],
        evidence: 'حديث عائشة رضي الله عنها في الصحيحين: أن النبي ﷺ أمر أخاها عبدالرحمن أن يُعمرها من التنعيم.',
      ),
    ),
  ];
}
