import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/features/umrah/models/umrah_models.dart';

/// Packing list for Hajj. The ids are stored with the user's ticks, so they must
/// stay stable even if a label is reworded.
class HajjChecklistData {
  HajjChecklistData._();

  static const List<ChecklistGroup> groups = [
    ChecklistGroup(
      title: 'الوثائق والتصاريح',
      icon: HugeIcons.strokeRoundedPassport,
      items: [
        ChecklistItem(
          id: 'hj_passport',
          label: 'جواز السفر ساري المفعول',
        ),
        ChecklistItem(
          id: 'hj_permit',
          label: 'تصريح الحج من منصة «نسك»',
          hint: 'لا يُسمح بالحج بلا تصريح رسمي.',
        ),
        ChecklistItem(
          id: 'hj_booking',
          label: 'ما يثبت تسجيلك وسكنك ومخيمك',
          hint: 'احتفظ ببياناتك ورقم التواصل مع مقدم الخدمة.',
        ),
        ChecklistItem(
          id: 'hj_health',
          label: 'التطعيمات المطلوبة',
          hint: 'حسب تعليمات الجهات الصحية في موسمك.',
        ),
        ChecklistItem(
          id: 'hj_copies',
          label: 'نسخ ورقية ورقمية من الوثائق',
        ),
      ],
    ),
    ChecklistGroup(
      title: 'ملابس الإحرام',
      icon: HugeIcons.strokeRoundedShirt01,
      items: [
        ChecklistItem(
          id: 'hj_ihram',
          label: 'إزاران ورداءان للإحرام (للرجال)',
          hint: 'يُستحب أن يكون معك طقم احتياطي.',
        ),
        ChecklistItem(
          id: 'hj_women',
          label: 'ملابس ساترة فضفاضة (للنساء)',
        ),
        ChecklistItem(
          id: 'hj_sandals',
          label: 'نعلان مريحان',
          hint: 'السنة للرجل أن يحرم في نعلين.',
        ),
        ChecklistItem(
          id: 'hj_belt',
          label: 'هميان أو حزام لحفظ النقود (للرجال)',
        ),
      ],
    ),
    ChecklistGroup(
      title: 'النظافة',
      icon: HugeIcons.strokeRoundedDroplet,
      items: [
        ChecklistItem(
          id: 'hj_soap',
          label: 'صابون وشامبو غير معطّرين',
          hint: 'الأحوط تجنّب العطر بعد الإحرام.',
        ),
        ChecklistItem(id: 'hj_wipes', label: 'مناديل ومعقّم غير معطّرين'),
        ChecklistItem(id: 'hj_tools', label: 'فرشاة ومعجون أسنان وسواك'),
        ChecklistItem(id: 'hj_towel', label: 'منشفة صغيرة سريعة الجفاف'),
      ],
    ),
    ChecklistGroup(
      title: 'الصحة',
      icon: HugeIcons.strokeRoundedMedicine01,
      items: [
        ChecklistItem(
          id: 'hj_meds',
          label: 'الأدوية الشخصية مع وصفاتها',
        ),
        ChecklistItem(
          id: 'hj_sunscreen',
          label: 'واقي شمس غير معطّر',
        ),
        ChecklistItem(
          id: 'hj_umbrella',
          label: 'مظلة للاستظلال',
          hint: 'الاستظلال بالمظلة جائز للمحرم.',
        ),
        ChecklistItem(
          id: 'hj_water',
          label: 'زجاجة ماء قابلة لإعادة التعبئة',
        ),
      ],
    ),
    ChecklistGroup(
      title: 'أغراض المشاعر',
      icon: HugeIcons.strokeRoundedBackpack01,
      items: [
        ChecklistItem(id: 'hj_bag', label: 'حقيبة ظهر صغيرة خفيفة'),
        ChecklistItem(
          id: 'hj_pebbles',
          label: 'كيس صغير لحفظ الحصى',
          hint: 'تلتقطها من مزدلفة أو منى، ولا تغسلها.',
        ),
        ChecklistItem(id: 'hj_prayer', label: 'سجادة صلاة صغيرة'),
        ChecklistItem(id: 'hj_charger', label: 'شاحن وبطارية محمولة'),
        ChecklistItem(id: 'hj_cash', label: 'نقود وبطاقة مصرفية'),
        ChecklistItem(
          id: 'hj_contact',
          label: 'بطاقة بعنوان المخيم ورقم المرافق',
          hint: 'تفيدك إن تهت في الزحام.',
        ),
      ],
    ),
  ];

  static int get totalItems =>
      groups.fold(0, (sum, group) => sum + group.items.length);
}
