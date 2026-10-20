import 'package:hugeicons/hugeicons.dart';
import '../models/umrah_models.dart';

/// What is forbidden once the intention for Umrah is made, and what is still
/// allowed. Based on the fatwas of the Permanent Committee and Shaykh Ibn Baz.
class UmrahProhibitionsData {
  UmrahProhibitionsData._();

  static const String penaltyNote =
      'من وقع في شيء من هذه المحظورات فعليه أن يسأل أهل العلم عمّا يلزمه من فدية؛ '
      'فالحكم يختلف بين الجاهل والناسي والمتعمد والمضطر.';

  static const List<Prohibition> all = [
    Prohibition(
      group: ProhibitionGroup.everyone,
      title: 'إزالة الشعر',
      detail: 'حلق شعر الرأس أو أي موضع من الجسم، أو نتفه أو قصّه.',
      icon: HugeIcons.strokeRoundedScissor,
    ),
    Prohibition(
      group: ProhibitionGroup.everyone,
      title: 'تقليم الأظافر',
      detail: 'قصّ الأظافر أو إزالتها. أما إن انكسر ظفر وآذاك فلا حرج في إزالته (ابن باز).',
      icon: HugeIcons.strokeRoundedScissor01,
    ),
    Prohibition(
      group: ProhibitionGroup.everyone,
      title: 'الطيب',
      detail:
          'استعمال العطر والبخور والدهن المطيّب في البدن أو الثوب بعد الإحرام. أما الصابون ومعجون الأسنان ذو الرائحة الخفيفة فقد قال ابن باز لا حرج فيه ولا فدية، لأنه لا يسمى طيباً، وتركه أحوط.',
      icon: HugeIcons.strokeRoundedPerfume,
    ),
    Prohibition(
      group: ProhibitionGroup.everyone,
      title: 'عقد النكاح والخِطبة',
      detail: 'لا يعقد المحرم نكاحاً لنفسه ولا لغيره، ولا يخطب امرأة.',
      icon: HugeIcons.strokeRoundedUserMultiple,
    ),
    Prohibition(
      group: ProhibitionGroup.everyone,
      title: 'الجماع ومقدماته',
      detail: 'يحرم الجماع، وكذلك المباشرة والتقبيل بشهوة. والجماع قبل تمام السعي يفسد العمرة، وبعده وقبل التقصير لا يفسدها وفيه فدية.',
      icon: HugeIcons.strokeRoundedAlert02,
    ),
    Prohibition(
      group: ProhibitionGroup.everyone,
      title: 'صيد البر',
      detail: 'قتل صيد البر أو إيذاؤه أو تنفيره أو الإعانة على صيده.',
      icon: HugeIcons.strokeRoundedCancel01,
    ),
    Prohibition(
      group: ProhibitionGroup.men,
      title: 'تغطية الرأس',
      detail:
          'تغطية الرأس بما يلامسه كالطاقية والغترة والعمامة. ويجوز الاستظلال بالمظلة أو السقف أو الخيمة.',
      icon: HugeIcons.strokeRoundedMan,
    ),
    Prohibition(
      group: ProhibitionGroup.men,
      title: 'لبس المخيط',
      detail:
          'لبس القميص والسراويل والثياب المفصّلة على الجسم أو العضو. والسنة أن يحرم الرجل في نعلين. فإن لم يجدهما فلبس الخفين رخّص فيه ابن باز، واختلف العلماء في وجوب قطعهما، ورجّح أن القطع منسوخ.',
      icon: HugeIcons.strokeRoundedShirt01,
    ),
    Prohibition(
      group: ProhibitionGroup.women,
      title: 'النقاب والقفازان',
      detail:
          'لا تلبس المرأة النقاب على وجهها ولا القفازين في يديها. وتستر وجهها عن الرجال الأجانب بما ليس نقاباً، كأن تُسدل الخمار.',
      icon: HugeIcons.strokeRoundedWoman,
    ),
  ];

  /// Common questions: things that are allowed.
  static const List<String> allowed = [
    'الاغتسال وتنظيف الجسد وتغيير ثياب الإحرام.',
    'لبس الساعة والحزام والهميان لحفظ النقود، وكذلك الخاتم لغير الذهب للرجل.',
    'لبس النعلين، وهو السنة للرجل.',
    'الاستظلال بالمظلة وسقف السيارة والخيمة، فلا حرج في ذلك عند ابن باز.',
    'التجارة والبيع والشراء، والأكل والشرب، والنوم.',
  ];
}
